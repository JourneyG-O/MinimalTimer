//
//  MainViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import AudioToolbox
import SwiftUI

enum InteractionMode {
    case normal
    case switching
}

final class MainViewModel: ObservableObject {
    // MARK: - Dependencies
    private let store = TimerStore()

    // MARK: - Published Properties
    @Published var interactionMode: InteractionMode = .normal
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

    // 편집/생성 화면 라우팅 상태
    @Published var route: Route? = nil

    // 화면 라우트
    enum Route: Identifiable, Equatable {
        var id: String { String(describing: self) }
        case add
        case edit(index: Int)
    }


    // MARK: - Internal State
    private var timer: Timer?
    private var lastUserSetTime: TimeInterval?
    private var previousSnappedMinutes: Int?
    private var previousAngle: Double = 0.0
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
        self.interactionMode = .normal
        validateSelectedTimerIndex()
        updatePreviousAngle()
    }

    // MARK: - Index Validation
    private func validateSelectedTimerIndex() {
        if selectedTimerIndex >= timers.count {
            selectedTimerIndex = max(timers.count - 1, 0)
        }
    }

    // MARK: - Persistence
    func saveTimers() {
        store.save(timers: timers, selectedIndex: selectedTimerIndex)
    }

    func deleteTimer(at index: Int) {
        guard timers.indices.contains(index) else { return }
        timers.remove(at: index)
        if selectedTimerIndex >= timers.count {
            selectedTimerIndex = max(timers.count - 1, 0)
        }
        saveTimers()
        route = nil
    }

    // MARK: - Timer Control
    func start() {
        guard !isRunning,
              timers.indices.contains(selectedTimerIndex),
              timers[selectedTimerIndex].currentTime > 0 else { return }

        isRunning = true
        UIApplication.shared.isIdleTimerDisabled = true

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
                self.reset()
            }
        }
        playTapFeedback()
    }

    func pause(fromUser: Bool) {
        isRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
        timer?.invalidate()
        timer = nil

        if fromUser {
            playTapFeedback()
        }
    }

    func startOrPauseTimer() {
        isRunning ? pause(fromUser: true) : start()
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

    func updatePreviousAngle() {
        guard let timer = currentTimer, timer.totalTime > 0 else { return }
        let progress = timer.currentTime / timer.totalTime
        previousAngle = progress * 360
    }

    func endDragging() {
        isDragging = false
        previousSnappedMinutes = nil
    }

    func selectTimer(at index: Int) {
        guard timers.indices.contains(index) else { return }
        selectedTimerIndex = index
        updatePreviousAngle()
    }


    // MARK: - Interaction Mode Control
    func enterSwitchMode() {
        pause(fromUser: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.interactionMode = .switching
            }
        }
    }

    func exitSwitchMode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.interactionMode = .normal
            }
        }
    }

    func presentAddTimerView() {
        print("presentAddTimerView가 호출 됨")
        route = .add
    }

    func presentEditTimerView(at index: Int) {
        print("pressentEditTimerView가 호출 됨")
        guard timers.indices.contains(index) else { return }
        route = .edit(index: index)
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

extension MainViewModel {
    func handleSave(mode: TimerEditViewModel.Mode, draft: TimerDraft) {
        switch mode {
        case .create:
            let newTimer = TimerModel(from: draft)
            timers.append(newTimer)
            selectedTimerIndex = timers.count - 1

        case .edit(let index):
            guard timers.indices.contains(index) else { return }
            timers[index].apply(draft)
        }

        store.save(timers: timers, selectedIndex: selectedTimerIndex)
        route = nil
    }
}
