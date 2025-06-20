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

    init(
        id: UUID = UUID(), // ← 기본값 설정
        title: String,
        totalTime: TimeInterval,
        currentTime: TimeInterval,
        color: Color
    ) {
        self.id = id
        self.title = title
        self.totalTime = totalTime
        self.currentTime = currentTime
        self.color = color
    }
}
