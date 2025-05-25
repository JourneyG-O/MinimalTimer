//
//  TimerModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import SwiftUI

struct TimerModel: Identifiable {
    let id = UUID()
    var title: String
    var totalTime: TimeInterval
    var currentTime: TimeInterval
    var color: Color
    var style: TimerStyleType = .neumorphic
}
