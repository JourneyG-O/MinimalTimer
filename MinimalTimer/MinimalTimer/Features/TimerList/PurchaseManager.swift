import StoreKit
import SwiftUI

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    // MARK: - Published State
    @Published var product: Product?
    @Published var isPremium: Bool = UserDefaults.standard.bool(forKey: "isPremium") {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }
    @Published var isLoading: Bool = false
    @Published var lastError: String?

    // MARK: - Configuration
    let premiumProductID = "minimal.timer.premium"

    // MARK: - Init
    init() {
        Task { [weak self] in
            guard let self else { return }
            await self.bootstrap()
        }
        listenForEntitlements()
    }

    // MARK: - Bootstrap
    private func bootstrap() async {
        await refreshProducts()
        await recalculateEntitlements()
    }

    // MARK: - Product Loading
    func refreshProducts() async {
        await MainActor.run { isLoading = true; lastError = nil }
        do {
            let products = try await Product.products(for: [premiumProductID])
            await MainActor.run {
                self.product = products.first
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.lastError = error.localizedDescription
            }
        }
    }

    // MARK: - Purchasing
    func purchase() async -> Bool {
        guard let product = product else {
            lastError = "상품을 불러오지 못했습니다."
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
                    lastError = error.localizedDescription
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                // The purchase is pending (e.g., Ask to Buy)
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    // MARK: - Restore
    func restore() async {
        do {
            try await AppStore.sync()
            // After sync, recompute entitlements
            await recalculateEntitlements()
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: - Entitlement Calculation
    /// Recalculate entitlement using current transactions for the premium product.
    private func recalculateEntitlements() async {
        var hasPremium = false
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            switch entitlement {
            case .verified(let t):
                if t.productID == premiumProductID {
                    if isTransactionActive(t) {
                        hasPremium = true
                    }
                }
            case .unverified(_, _):
                // ignore unverified
                break
            }
        }
        await MainActor.run { self.isPremium = hasPremium }
    }

    /// Update entitlement from a specific transaction considering state (revoked/expired/refunded).
    private func updateEntitlementFrom(_ transaction: StoreKit.Transaction) async {
        guard transaction.productID == premiumProductID else { return }
        let active = isTransactionActive(transaction)
        await MainActor.run { self.isPremium = active }
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

    // MARK: - Updates Listener
    private func listenForEntitlements() {
        Task.detached { [weak self] in
            guard let self else { return }
            for await update in StoreKit.Transaction.updates {
                switch update {
                case .verified(let t):
                    if t.productID == self.premiumProductID {
                        await self.updateEntitlementFrom(t)
                        await t.finish()
                    }
                case .unverified(_, _):
                    continue
                }
            }
        }
    }

    // MARK: - Price
    var localizedPrice: String {
        guard let p = product else { return "" }
        return p.displayPrice
    }
}

