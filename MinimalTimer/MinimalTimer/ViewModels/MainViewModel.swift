//
//  MainViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import SwiftUI

class MainViewModel: ObservableObject {
    // 선택된 타이머 리스트와 인덱스
    @Published var timers: [TimerModel] = []
    @Published var selectedTimerIndex = 0

    // 실행 상태
    @Published var isRunning = false
    @Published var isInSwitchMode: Bool = false

    // 드래그 상태 및 진행률 표시용 값
    @Published var isDragging: Bool = false
    @Published var userSetProgress: Double = 1.0

    // wrap-around 방지용
    @Published var previousAngle: Double = 0.0
    @Published var maxMode: Bool = false
    @Published var minMode: Bool = false

    // 타이머 객체
    private var timer: Timer?

    // 현재 선택된 타이머 모델
    var currentTimer: TimerModel? {
        guard timers.indices.contains(selectedTimerIndex) else { return nil }
        return timers[selectedTimerIndex]
    }

    // 현재 진행률 계산
    var progress: CGFloat {
        guard let timer = currentTimer, timer.totalTime > 0 else { return 0 }
        let ratio = timer.currentTime / timer.totalTime
        return CGFloat(min(max(ratio, 0.0), 1.0))
    }

    init() {
        timers.append(
            TimerModel(
                title: "테스트 타이머",
                totalTime: 60 * 5,
                currentTime: 60 * 5,
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
        userSetProgress = 1.0
    }

    func setUserProgress(from angle: Double) {
        if previousAngle >= 340 && angle <= 30 {
            setUserProgress(to: 1.0)
            return
        }
        if previousAngle <= 20 && angle >= 330 {
            setUserProgress(to: 0.0)
            return
        }

        let progress = min(max(angle / 360, 0.0), 1.0)
        setUserProgress(to: progress)
        previousAngle = angle
    }

    func setUserProgress(to percentage: Double) {
        guard timers.indices.contains(selectedTimerIndex) else { return }
        let clamped = max(0.0, min(percentage, 1.0))
        let maxTime = timers[selectedTimerIndex].totalTime
        timers[selectedTimerIndex].currentTime = maxTime * clamped
        userSetProgress = clamped
        pause()
    }

    func syncUserProgressWithCurrentTime() {
        guard timers.indices.contains(selectedTimerIndex) else { return }
        let timer = timers[selectedTimerIndex]
        let ratio = max(0.0, min(timer.currentTime / timer.totalTime, 1.0))
        userSetProgress = ratio
    }

    func switchMode() { }
}

