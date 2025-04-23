//
//  MainViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import SwiftUI

class MainViewModel: ObservableObject {
    // 선택 된 타이머
    @Published var timers: [TimerModel] = []
    @Published var selectedTimerIndex = 0

    // 타이머 실행 상태
    @Published var isRunning = false

    // 타이머 전환 모드 상태
    @Published var isInSwitchMode: Bool = false

    // 시간 제어용 타이머
    private var timer: Timer?

    // 현재 선택된 타이머를 가져오는 계산 속성
    var currentTimer: TimerModel? {
        guard timers.indices.contains(selectedTimerIndex) else { return nil }
        return timers[selectedTimerIndex]
    }

    init() {
        // 개발 중 디버깅 용도로 기본 타이머 추가
        timers.append(
            TimerModel(
                title: "테스트 타이머",
                totalTime: 60 * 5,
                currentTime: 60 * 5,
                color: .blue
            )
        )
    }

    // 필요한 함수
    func start() { }
    func pause() { }
    func reset() { }
    func switchMode() { }
    func setTime(from angle: Double) { }
}
