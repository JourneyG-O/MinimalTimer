import SwiftUI

/// Environment key for premium entitlement state.
private struct IsPremiumKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    /// Indicates whether the current user has premium entitlement.
    var isPremium: Bool {
        get { self[IsPremiumKey.self] }
        set { self[IsPremiumKey.self] = newValue }
    }
}
