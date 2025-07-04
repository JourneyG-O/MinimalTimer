//
//  MainViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import AudioToolbox
import SwiftUI

class MainViewModel: ObservableObject {
    // MARK: - Dependencies
    private let store = TimerStore()

    // MARK: - Published Properties
    @Published var timers: [TimerModel] = [] {
        didSet {
            saveTimers()
        }
    }
    @Published var selectedTimerIndex: Int = 0 {
        didSet {
            saveTimers()
        }
    }

    @Published var isRunning: Bool = false
    @Published var isDragging: Bool = false
    @Published var isSwitchMode: Bool = false

    // MARK: - Internal State
    private var timer: Timer?
    private var lastUserSetTime: TimeInterval?
    private var previousSnappedMinutes: Int?
    private var previousAngle: Double = 0.0
    private var maxMode: Bool = false
    private var minMode: Bool = false

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Computed Properties
    var progress: CGFloat {
        guard let timer = currentTimer, timer.totalTime > 0 else { return 0 }
        return CGFloat(timer.currentTime / timer.totalTime)
    }

    var currentTimer: TimerModel? {
        guard timers.indices.contains(selectedTimerIndex) else { return nil }
        return timers[selectedTimerIndex]
    }

    // MARK: - Initialization
    init() {
        let (savedTimers, savedIndex) = store.load()
        self.timers = savedTimers
        self.selectedTimerIndex = savedIndex
    }

    // MARK: - Persistence
    func saveTimers() {
        store.save(timers: timers, selectedIndex: selectedTimerIndex)
    }

    // MARK: - Timer Control
    func start() {
        guard !isRunning,
              timers.indices.contains(selectedTimerIndex),
              timers[selectedTimerIndex].currentTime > 0 else { return }

        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            guard self.timers.indices.contains(self.selectedTimerIndex) else {
                self.pause(fromUser: false)
                return
            }

            self.timers[self.selectedTimerIndex].currentTime -= 1

            if self.timers[self.selectedTimerIndex].currentTime <= 0 {
                self.pause(fromUser: false)
                self.playEndFeedback()
            }
        }
        playTapFeedback()
    }

    func pause(fromUser: Bool) {
        isRunning = false
        timer?.invalidate()
        timer = nil

        if fromUser {
            playTapFeedback()
        }
    }

    func reset() {
        guard timers.indices.contains(selectedTimerIndex) else { return }
        pause(fromUser: false)

        let resetTime = lastUserSetTime ?? timers[selectedTimerIndex].totalTime
        timers[selectedTimerIndex].currentTime = resetTime
    }

    // MARK: - Interaction
    func setUserProgress(to percentage: Double) {
        guard timers.indices.contains(selectedTimerIndex) else { return }
        let clamped = min(max(percentage, 0.0), 1.0)
        timers[selectedTimerIndex].currentTime = timers[selectedTimerIndex].totalTime * clamped
        lastUserSetTime = timers[selectedTimerIndex].totalTime * clamped
        if isRunning {
            pause(fromUser: false)
        }
    }

    func setUserProgress(from angle: Double) {
        isDragging = true

        guard let timer = currentTimer else { return }
        let total = timer.totalTime

        // wrap-around 방지
        if previousAngle >= 270 && angle <= 180 {
            setUserProgress(to: 1.0)
            return
        }
        if previousAngle <= 90 && angle >= 180 {
            setUserProgress(to: 0.0)
            return
        }

        // 각도 기반 퍼센트 계산
        let rawProgress = angle / 360
        let rawTime = rawProgress * total

        // 스냅 적용 (1분 = 60초 단위)
        let snappedTime = round(rawTime / 60) * 60
        let clampedTime = max(0, min(snappedTime, total))
        let snappedProgress = clampedTime / total

        // ✅ 스냅 분 단위 계산 시 round 추가
        let snappedMinutes = Int(clampedTime / 60)

        if let previous = previousSnappedMinutes {
            if snappedMinutes != previous {
                playSnapFeedback()
                previousSnappedMinutes = snappedMinutes
            }
        } else {
            previousSnappedMinutes = snappedMinutes
        }

        setUserProgress(to: snappedProgress)
        previousAngle = angle
    }

    func endDragging() {
        isDragging = false
        previousSnappedMinutes = nil
    }

    func selectTimer(at index: Int) {
        guard timers.indices.contains(index) else { return }
        selectedTimerIndex = index
    }

    // MARK: - Feedback
    private func playEndFeedback() {
        feedbackGenerator.impactOccurred()
        AudioServicesPlaySystemSound(1322)
    }

    private func playTapFeedback() {
        feedbackGenerator.impactOccurred()
    }

    private func playSnapFeedback() {
        feedbackGenerator.impactOccurred()
        AudioServicesPlaySystemSound(1104)
    }
}

