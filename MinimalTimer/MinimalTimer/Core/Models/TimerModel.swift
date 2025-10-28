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
    var lastUserSetTime: TimeInterval?
    var color: CustomColor
    var isTitleAlwaysVisible: Bool
    var isTickAlwaysVisible: Bool
    var isMuted: Bool
    var isRepeatEnabled: Bool

    init(
        id: UUID = UUID(), // ← 기본값 설정
        title: String,
        totalTime: TimeInterval,
        currentTime: TimeInterval,
        lastUserSetTime: TimeInterval? = nil,
        color: CustomColor,
        isTitleAlwaysVisible: Bool = false ,
        isTickAlwaysVisible: Bool = false,
        isMuted: Bool = false,
        isRepeatEnabled: Bool = false

    ) {
        self.id = id
        self.title = title
        self.totalTime = totalTime
        self.currentTime = currentTime
        self.lastUserSetTime = lastUserSetTime
        self.color = color
        self.isTitleAlwaysVisible = isTitleAlwaysVisible
        self.isTickAlwaysVisible = isTickAlwaysVisible
        self.isMuted = isMuted
        self.isRepeatEnabled = isRepeatEnabled
    }
}

extension TimerDraft {
    // TimerModel -> TimerDraft (편집하기로 진입 시 사용)
    init(model: TimerModel) {
        self.title = model.title
        self.color = model.color
        self.totalSeconds = Int(model.totalTime)
        self.isTitleAlwaysVisible = model.isTitleAlwaysVisible
        self.isTickAlwaysVisible = model.isTickAlwaysVisible
        self.isMuted = model.isMuted
        self.isRepeatEnabled = model.isRepeatEnabled
    }
}

extension TimerModel {
    // Draft -> TimerModel 생성하기로 진입 시 사용 (타이머 새로 만들 때)
    init(from draft: TimerDraft) {
        self.id = UUID()
        self.title = draft.title
        self.color = draft.color
        self.totalTime = TimeInterval(draft.totalSeconds)
        self.currentTime = TimeInterval(draft.totalSeconds)
        self.lastUserSetTime = nil
        self.isTitleAlwaysVisible = draft.isTitleAlwaysVisible
        self.isTickAlwaysVisible = draft.isTickAlwaysVisible
        self.isMuted = draft.isMuted
        self.isRepeatEnabled = draft.isRepeatEnabled
    }

    // 기존 TimerModel에 Draft 값 반영 (편집 저장 시)
    mutating func apply(_ draft: TimerDraft) {
        self.title = draft.title
        self.color = draft.color
        self.totalTime = TimeInterval(draft.totalSeconds)
        self.currentTime = TimeInterval(draft.totalSeconds)
        self.isTitleAlwaysVisible = draft.isTitleAlwaysVisible
        if let t = lastUserSetTime {
            self.lastUserSetTime = min(t, self.totalTime)
        }
        self.isTickAlwaysVisible = draft.isTickAlwaysVisible
        self.isMuted = draft.isMuted
        self.isRepeatEnabled = draft.isRepeatEnabled
    }
}
