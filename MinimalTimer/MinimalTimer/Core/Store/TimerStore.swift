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
    var lastUserSetTime: TimeInterval?
    var color: String
    var isTitleAlwaysVisible: Bool
    var isTickAlwaysVisible: Bool
    var isMuted: Bool
    var isRepeatEnabled: Bool
}

extension TimerModel {
    func toDTO() -> TimerModelDTO {
        TimerModelDTO(
            id: id,
            title: title,
            totalTime: totalTime,
            currentTime: currentTime,
            lastUserSetTime: lastUserSetTime,
            color: self.color.rawValue,
            isTitleAlwaysVisible: isTitleAlwaysVisible,
            isTickAlwaysVisible: isTickAlwaysVisible,
            isMuted: isMuted,
            isRepeatEnabled: isRepeatEnabled
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
            lastUserSetTime: lastUserSetTime,
            color: CustomColor(rawValue: self.color) ?? .red,
            isTitleAlwaysVisible: isTitleAlwaysVisible,
            isTickAlwaysVisible: isTickAlwaysVisible,
            isMuted: isMuted,
            isRepeatEnabled: isRepeatEnabled
        )
    }
}

protocol TimerStoring {
    func save(timers: [TimerModel], selectedIndex: Int)
    func load() -> ([TimerModel], Int)
}

final class TimerStore: TimerStoring {
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
        let title: String = String(localized: "default.timer.name")
        return [
            TimerModel(title: title, totalTime: 30 * 60, currentTime: 30 * 60, color: CustomColor.dynamicForeground)
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

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0x0000FF) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    func toHex() -> String? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgbValue: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        return String(format: "#%06x", rgbValue)
    }
}
