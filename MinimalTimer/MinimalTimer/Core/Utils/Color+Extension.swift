//
//  Color+Extension.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/15/25.
//

import SwiftUI
import UIKit

// MARK: - 1. CustomColor.swift
// Color 대신 이 열거형을 사용합니다.
enum CustomColor: String, CaseIterable, Hashable, Codable {
    case dynamicForeground // 라이트: 검은색, 다크: 흰색

    // 고정된 색상 (Static Color)
    case red, orange, yellow, green, mint, blue, indigo, purple, pink, brown, gray

    // 실제 Color 값으로 변환하는 연산 프로퍼티
    var toColor: Color {
        switch self {
        case .dynamicForeground:
            return Color(UIColor { trait in
                trait.userInterfaceStyle == .dark ? .white : .black
            })
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .mint: return .mint
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        case .gray: return .gray
        }
    }
}

extension Color {
    static func invertedForeground(for scheme: ColorScheme) -> Color {
        scheme == .light ? .white : .black
    }
}
