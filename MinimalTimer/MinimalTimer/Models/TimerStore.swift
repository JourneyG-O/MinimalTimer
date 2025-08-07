//
//  TimerStore.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/20/25.
//

import Foundation
import SwiftUI

struct TimerModelDTO: Codable {
    var id: UUID
    var title: String
    var totalTime: TimeInterval
    var currentTime: TimeInterval
    var colorHex: String
    var isTickAlwaysVisible: Bool
    var isVibrationEnabled: Bool
    var isSoundEnaved: Bool
    var isRepeatEnaved: Bool
}

extension TimerModel {
    func toDTO() -> TimerModelDTO {
        TimerModelDTO(
            id: id,
            title: title,
            totalTime: totalTime,
            currentTime: currentTime,
            colorHex: color.toHex(),
            isTickAlwaysVisible: isTickAlwaysVisible,
            isVibrationEnabled: isVibrationEnabled,
            isSoundEnaved: isSoundEnaved,
            isRepeatEnaved: isRepeatEnaved
        )
    }
}

extension TimerModelDTO {
    func toModel() -> TimerModel {
        TimerModel(
            id: id,
            title: title,
            totalTime: totalTime,
            currentTime: currentTime,
            color: Color(hex: colorHex),
            isTickAlwaysVisible: isTickAlwaysVisible,
            isVibrationEnabled: isVibrationEnabled,
            isSoundEnaved: isSoundEnaved,
            isRepeatEnaved: isRepeatEnaved
        )
    }
}

class TimerStore {
    private let timerKey = "savedTimers"
    private let selectedIndexKey = "selectedTimerIndex"

    func save(timers: [TimerModel], selectedIndex: Int) {
        let dtos = timers.map { $0.toDTO() }
        if let encoded = try? JSONEncoder().encode(dtos) {
            UserDefaults.standard.set(encoded, forKey: timerKey)
        }
        UserDefaults.standard.set(selectedIndex, forKey: selectedIndexKey)
    }

    func load() -> ([TimerModel], Int) {
        var timers: [TimerModel] = []
        var index: Int = 0

        if let data = UserDefaults.standard.data(forKey: timerKey),
           let decoded = try? JSONDecoder().decode([TimerModelDTO].self, from: data) {
            timers = decoded.map { $0.toModel() }
        } else {
            timers = TimerStore.defaultTimers
        }

        index = UserDefaults.standard.integer(forKey: selectedIndexKey)

        return (timers, index)
    }

    static var defaultTimers: [TimerModel] {
        return [
            TimerModel(title: "표준 타이머", totalTime: 60 * 60, currentTime: 60 * 60, color: .yellow),
            TimerModel(title: "긴 타이머", totalTime: 120 * 60, currentTime: 120 * 60, color: .blue),
            TimerModel(title: "짧은 타이머", totalTime: 5 * 60, currentTime: 5 * 60, color: .red)
        ]
    }
}

// Color -> Hex 변환 유틸리티
extension Color {
    func toHex() -> String {
        UIColor(self).toHex() ?? "#000000"
    }

    init(hex: String) {
        self = Color(UIColor(hex: hex))
    }
}

// UIColor 변환 유틸리티 (iOS용)
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    func toHex() -> String? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}
