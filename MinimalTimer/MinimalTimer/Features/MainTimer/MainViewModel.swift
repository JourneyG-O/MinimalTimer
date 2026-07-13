//
//  MainViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import AudioToolbox
import AVFoundation
import SwiftUI

enum InteractionMode {
    case normal
    case switching
}

@MainActor
final class MainViewModel: ObservableObject {

    private let store: TimerStoring
    private let purchaseGating: any PurchaseGating

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

    private var countdownTask: Task<Void, Never>?
    private var previousSnappedIndex: Int?
    private var previousAngle: Double = 0.0
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private var audioPlayer: AVAudioPlayer?

    init(
        store: TimerStoring = TimerStore(),
        purchaseGating: any PurchaseGating
    ) {
        self.store = store
        self.purchaseGating = purchaseGating
        let (savedTimers, savedIndex) = store.load()
        self.timers = savedTimers
        self.selectedTimerIndex = savedIndex
        self.interactionMode = .normal
        validateSelectedTimerIndex()
        updatePreviousAngle()
        configureAudioSession()
    }

    var progress: CGFloat {
        guard let timer = currentTimer, timer.totalTime > 0 else { return 0 }
        return CGFloat(timer.currentTime / timer.totalTime)
    }

    var currentTimer: TimerModel? {
        guard timers.indices.contains(selectedTimerIndex) else { return nil }
        return timers[selectedTimerIndex]
    }

    /// 무료 사용자는 타이머 개수 제한 내에서만 새 타이머를 만들 수 있다.
    var canCreateTimer: Bool {
        purchaseGating.isPremium || timers.count < Constants.Purchase.freeTimerLimit
    }

    private func validateSelectedTimerIndex() {
        if selectedTimerIndex >= timers.count {
            selectedTimerIndex = max(timers.count - 1, 0)
        }
    }

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
    }

    func start() {
        guard !isRunning,
              timers.indices.contains(selectedTimerIndex),
              timers[selectedTimerIndex].currentTime > 0 else { return }

        isRunning = true
        UIApplication.shared.isIdleTimerDisabled = true

        if let timerModel = currentTimer { playTapFeedback(for: timerModel) }
        startCountdown()
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Constants.Interaction.tickInterval)
                guard !Task.isCancelled, let self else { return }
                self.advanceOneSecond()
            }
        }
    }

    private func advanceOneSecond() {
        guard timers.indices.contains(selectedTimerIndex) else {
            pause(fromUser: false)
            return
        }

        timers[selectedTimerIndex].currentTime -= 1
        guard timers[selectedTimerIndex].currentTime <= 0 else { return }

        if let timerModel = currentTimer { playEndFeedback(for: timerModel) }

        if timers[selectedTimerIndex].isRepeatEnabled {
            reset()
            start()
        } else {
            pause(fromUser: false)
            reset()
        }
    }

    func pause(fromUser: Bool) {
        isRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
        countdownTask?.cancel()
        countdownTask = nil

        if fromUser {
            if let timerModel = currentTimer { playTapFeedback(for: timerModel) }
        }
    }

    func startOrPauseTimer() {
        isRunning ? pause(fromUser: true) : start()
    }

    func reset() {
        guard timers.indices.contains(selectedTimerIndex) else { return }
        pause(fromUser: false)

        let model = timers[selectedTimerIndex]
        let resetTime = model.lastUserSetTime ?? model.totalTime
        timers[selectedTimerIndex].currentTime = resetTime
    }

    func setUserProgress(to percentage: Double) {
        guard timers.indices.contains(selectedTimerIndex) else { return }
        let clamped = min(max(percentage, 0.0), 1.0)
        let total = timers[selectedTimerIndex].totalTime
        let newValue = total * clamped
        timers[selectedTimerIndex].currentTime = newValue
        timers[selectedTimerIndex].lastUserSetTime = newValue
        if isRunning {
            pause(fromUser: false)
        }
    }

    func setUserProgress(from angle: Double) {
        if !isDragging {
            isDragging = true
            feedbackGenerator.prepare()
        }

        guard let timer = currentTimer else { return }
        let total = timer.totalTime
        let unit = total < Constants.Time.snapSecondThreshold ? 1.0 : 60.0 // 초or분

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

        // 스냅 적용 (1초 또는 60초)
        let snappedTime = round(rawTime / unit) * unit
        let clampedTime = max(0, min(snappedTime, total))
        let snappedProgress = clampedTime / total

        // 스냅 단위 인덱스(초or분)
        let snappedIndex = Int(clampedTime / unit)

        if let previousIndex = previousSnappedIndex {
            if snappedIndex != previousIndex {
                playSnapFeedback(for: timer)
                previousSnappedIndex = snappedIndex
            }
        } else {
            previousSnappedIndex = snappedIndex
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
        previousSnappedIndex = nil
    }

    func selectTimer(at index: Int) {
        guard timers.indices.contains(index) else { return }
        selectedTimerIndex = index
        updatePreviousAngle()
    }

    func enterSwitchMode() {
        pause(fromUser: false)
        transitionInteractionMode(to: .switching)
    }

    func exitSwitchMode() {
        transitionInteractionMode(to: .normal)
    }

    private func transitionInteractionMode(to mode: InteractionMode) {
        Task { [weak self] in
            try? await Task.sleep(for: Constants.Interaction.switchModeDelay)
            guard let self else { return }
            withAnimation(.easeInOut(duration: Constants.Interaction.switchModeAnimationSeconds)) {
                self.interactionMode = mode
            }
        }
    }

    private func playEndFeedback(for timer: TimerModel) {
        guard !timer.isMuted else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        playSoundIfAllowed(named: "finish", ext: "mp3")
    }

    private func playTapFeedback(for timer: TimerModel) {
        guard !timer.isMuted else { return }
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }

    private func playSnapFeedback(for timer: TimerModel) {
        guard !timer.isMuted else { return }
        feedbackGenerator.impactOccurred()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session config failed: \(error)")
        }
    }

    private func playSoundIfAllowed(named: String, ext: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: ext) else {
            print("Sound file not found: \(named).\(ext)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
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
    }
}
