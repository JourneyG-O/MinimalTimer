//
//  TimerModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import SwiftUI

struct TimerModel: Identifiable {
    let id: UUID
    var title: String
    var totalTime: TimeInterval
    var currentTime: TimeInterval
    var color: Color
    var isTickAlwaysVisible: Bool
    var isVibrationEnabled: Bool
    var isSoundEnabled: Bool
    var isRepeatEnabled: Bool

    init(
        id: UUID = UUID(), // ← 기본값 설정
        title: String,
        totalTime: TimeInterval,
        currentTime: TimeInterval,
        color: Color,
        isTickAlwaysVisible: Bool = false,
        isVibrationEnabled: Bool = true,
        isSoundEnaved: Bool = true,
        isRepeatEnaved: Bool = false

    ) {
        self.id = id
        self.title = title
        self.totalTime = totalTime
        self.currentTime = currentTime
        self.color = color
        self.isTickAlwaysVisible = isTickAlwaysVisible
        self.isVibrationEnabled = isVibrationEnabled
        self.isSoundEnabled = isSoundEnaved
        self.isRepeatEnabled = isRepeatEnaved
    }
}
