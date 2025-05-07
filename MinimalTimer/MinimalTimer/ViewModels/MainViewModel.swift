//
//  MainViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import SwiftUI

class MainViewModel: ObservableObject {
    // 선택된 타이머
    @Published var timers: [TimerModel] = []
    @Published var selectedTimerIndex: Int = 0

    // 타이머 실행 상태
    @Published var isRunning: Bool = false

    // 타이머 객체
    private var timer: Timer?

    // 현재 진행률 계산
    var progress: CGFloat {
        guard let timer = currentTimer, timer.totalTime > 0 else { return 0 }
        return CGFloat(timer.currentTime / timer.totalTime)
    }

    // 현재 선택된 타이머 모델
    var currentTimer: TimerModel? {
        guard timers.indices.contains(selectedTimerIndex) else { return nil }
        return timers[selectedTimerIndex]
    }

    // wrap-around 방지용
    private var previousAngle: Double = 0.0
    private var maxMode: Bool = false
    private var minMode: Bool = false

    init() {
        timers.append(
            TimerModel(
                title: "테스트 타이머",
                totalTime: 60 * 30,
                currentTime: 60 * 30,
                color: .blue
            )
        )
    }

    func start() {
        guard !isRunning, timers.indices.contains(selectedTimerIndex) else { return }
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            guard self.timers.indices.contains(self.selectedTimerIndex) else {
                self.pause()
                return
            }

            self.timers[self.selectedTimerIndex].currentTime -= 1

            if self.timers[self.selectedTimerIndex].currentTime <= 0 {
                self.pause()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
            guard timers.indices.contains(selectedTimerIndex) else { return }
            pause()
            timers[selectedTimerIndex].currentTime = timers[selectedTimerIndex].totalTime
        }

        func setUserProgress(to percentage: Double) {
            guard timers.indices.contains(selectedTimerIndex) else { return }

            let clamped = min(max(percentage, 0.0), 1.0)
            timers[selectedTimerIndex].currentTime = timers[selectedTimerIndex].totalTime * clamped

            pause()
        }

        func setUserProgress(from angle: Double) {
            if previousAngle >= 270 && angle <= 180 {
                setUserProgress(to: 1.0)
                return
            }
            if previousAngle <= 90 && angle >= 180 {
                setUserProgress(to: 0.0)
                return
            }

            let progress = min(max(angle / 360, 0.0), 1.0)
            setUserProgress(to: progress)
            previousAngle = angle
        }

        func switchMode() {
            // 화면 전환용 편집 모드 로직 등 여기에 구현 가능
        }
}

