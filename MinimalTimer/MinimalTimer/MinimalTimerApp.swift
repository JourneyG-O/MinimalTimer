//
//  MinimalTimerApp.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import SwiftUI

@main
struct MinimalTimerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTimerRootView(vm: .init())
        }
    }
}
