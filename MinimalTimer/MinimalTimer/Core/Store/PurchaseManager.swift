import StoreKit
import SwiftUI

enum PurchaseError: LocalizedError {
    case productUnavailable
    case purchasePending
    case verificationFailed(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return String(localized: "purchase.error.productUnavailable", defaultValue: "상품을 불러오지 못했습니다.")
        case .purchasePending:
            return String(localized: "purchase.error.pending", defaultValue: "구매가 보류중입니다.")
        case .verificationFailed(let error):
            return error.localizedDescription
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

@MainActor
final class PurchaseManager: ObservableObject, PurchaseGating {
    static let shared = PurchaseManager()

    private static let premiumStateKey = "isPremium"
    private let secureStore = KeychainStore()

    @Published var product: Product?
    @Published var isPremium: Bool = KeychainStore().bool(forKey: PurchaseManager.premiumStateKey) {
        didSet {
            secureStore.setBool(isPremium, forKey: Self.premiumStateKey)
        }
    }
    @Published var isLoading: Bool = false
    @Published var lastError: PurchaseError?

    let premiumProductID = "app.stannum.minitime.premium"

    init() {
        migrateLegacyEntitlementIfNeeded()
        Task { [weak self] in
            guard let self else { return }
            await self.bootstrap()
        }
        listenForEntitlements()
    }

    /// 이전 버전은 결제 권한을 UserDefaults 평문으로 저장했다.
    /// 최초 실행 1회에 한해 Keychain으로 이관하고 평문 값을 제거한다.
    private func migrateLegacyEntitlementIfNeeded() {
        guard secureStore.data(forKey: Self.premiumStateKey) == nil else { return }
        if UserDefaults.standard.bool(forKey: Self.premiumStateKey) {
            secureStore.setBool(true, forKey: Self.premiumStateKey)
            isPremium = true
        }
        UserDefaults.standard.removeObject(forKey: Self.premiumStateKey)
    }

    private func bootstrap() async {
        await refreshProducts()
        await recalculateEntitlements()
    }

    func refreshProducts() async {
        isLoading = true
        lastError = nil
        do {
            let products = try await Product.products(for: [premiumProductID])
            product = products.first
            isLoading = false
        } catch {
            isLoading = false
            lastError = .underlying(error)
        }
    }

    func purchase() async -> Bool {
        lastError = nil
        guard let product else {
            lastError = .productUnavailable
            return false
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Update entitlement based on transaction state before finishing
                    await updateEntitlementFrom(transaction)
                    await transaction.finish()
                    return isPremium
                case .unverified(_, let error):
                    lastError = .verificationFailed(error)
                    return false
                }
            case .userCancelled:
                lastError = nil
                return false
            case .pending:
                lastError = .purchasePending
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = .underlying(error)
            return false
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            // After sync, recompute entitlements
            await recalculateEntitlements()
        } catch {
            lastError = .underlying(error)
        }
    }

    /// Recalculate entitlement using current transactions for the premium product.
    private func recalculateEntitlements() async {
        var hasPremium = false
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            switch entitlement {
            case .verified(let transaction):
                if transaction.productID == premiumProductID {
                    if isTransactionActive(transaction) {
                        hasPremium = true
                        break
                    }
                }
            case .unverified(_, _):
                // ignore unverified
                break
            }
        }
        isPremium = hasPremium
    }

    /// Update entitlement from a specific transaction considering state (revoked/expired/refunded).
    private func updateEntitlementFrom(_ transaction: StoreKit.Transaction) async {
        guard transaction.productID == premiumProductID else { return }
        isPremium = isTransactionActive(transaction)
    }

    /// Determine if a transaction currently grants access.
    private func isTransactionActive(_ transaction: StoreKit.Transaction) -> Bool {
        // Non-consumable: any verified, non-revoked transaction grants entitlement.
        // If you later switch to auto-renewable subscription, check `expirationDate`, `revocationDate`, etc.
        if let revocationDate = transaction.revocationDate {
            // Revoked (refund) — no access
            if revocationDate <= Date() { return false }
        }
        if let expirationDate = transaction.expirationDate {
            // For subscriptions: require expiration in the future
            return expirationDate > Date()
        }
        // For non-consumable (no expiration): verified = active
        return true
    }

    private func listenForEntitlements() {
        Task { [weak self] in
            guard let self else { return }
            for await update in StoreKit.Transaction.updates {
                switch update {
                case .verified(let transaction):
                    if transaction.productID == self.premiumProductID {
                        await self.updateEntitlementFrom(transaction)
                        await transaction.finish()
                    }
                case .unverified(_, _):
                    continue
                }
            }
        }
    }

    var localizedPrice: String {
        guard let product else { return "" }
        return product.displayPrice
    }
}
