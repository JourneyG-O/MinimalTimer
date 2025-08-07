//
//  TimerEditViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/7/25.
//

import SwiftUI

class TimerEditViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var color: Color = .red
    @Published var totalTime: TimeInterval = 0
    @Published var isTickAlwaysVisivle: Bool = false
    @Published var isVibrationEnabled: Bool = true
    @Published var isSoundEnabled: Bool = true
    @Published var isRepeatEnabled: Bool = false

    init(from timer: TimerModel) {
        self.title = timer.title
        self.color = timer.color
        self.totalTime = timer.totalTime
        self.isTickAlwaysVisivle = timer.isTickAlwaysVisible
        self.isVibrationEnabled = timer.isVibrationEnabled
        self.isSoundEnabled = timer.isSoundEnaved
        self.isRepeatEnabled = timer.isRepeatEnaved
        self.isEditing = true
    }

    // 생성or편집 구분
    var isEditing: Bool = false

    func toTimerModel() -> TimerModel {
        TimerModel(
            title: title,
            totalTime: totalTime,
            currentTime: totalTime,
            color: color,
            isTickAlwaysVisible: isTickAlwaysVisivle,
            isVibrationEnabled: isVibrationEnabled,
            isSoundEnaved: isSoundEnabled,
            isRepeatEnaved: isRepeatEnabled
        )
    }
}
