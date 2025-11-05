//
//  MinimalTimerApp.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import SwiftUI

@main
struct MinimalTimerApp: App {
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            MainTimerRootView(vm: .init())
                .environmentObject(purchaseManager)
        }
    }
}
