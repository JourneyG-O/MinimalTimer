//
//  PurchaseGating.swift
//  MinimalTimer
//

import Foundation

/// 결제 권한 조회를 추상화해 ViewModel이 구체 결제 구현에 직접 의존하지 않도록 한다.
protocol PurchaseGating: AnyObject {
    @MainActor var isPremium: Bool { get }
}
