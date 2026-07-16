//
//  AppOrientationDelegate.swift
//  MinimalTimer
//

import SwiftUI
import UIKit

/// 앱의 화면 방향을 런타임에 제어한다. 기본은 세로 고정이며,
/// 가로모드가 허용된 타이머를 메인 화면에서 보고 있을 때만 가로를 허용한다.
final class AppOrientationDelegate: NSObject, UIApplicationDelegate {
    static var supportedMask: UIInterfaceOrientationMask = .portrait

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AppOrientationDelegate.supportedMask
    }

    /// 가로 허용 여부를 반영하고, 필요하면 현재 화면을 즉시 회전시킨다.
    @MainActor
    static func apply(allowsLandscape: Bool) {
        supportedMask = allowsLandscape ? [.portrait, .landscape] : .portrait
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: supportedMask))
    }
}
