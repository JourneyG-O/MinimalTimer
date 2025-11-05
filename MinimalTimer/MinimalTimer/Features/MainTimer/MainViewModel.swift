//
//  MainViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/23/25.
//

import AudioToolbox
import AVFoundation
import SwiftUI
import StoreKit

enum InteractionMode {
    case normal
    case switching
}

final class MainViewModel: ObservableObject {

    // MARK: - Premium
    @Published var isPremium: Bool = UserDefaults.standard.bool(forKey: "isPremium") {
        didSet { UserDefaults.standard.set(isPremium, forKey: "isPremium") }
    }

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

    // MARK: - Internal State
    private var timer: Timer?
    private var previousSnappedIndex: Int?
    private var previousAngle: Double = 0.0
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notifyGenerator = UINotificationFeedbackGenerator()
    private var audioPlayer: AVAudioPlayer?

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
        configureAudioSession()
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
                if let t = self.currentTimer {
                    self.playEndFeedback(for: t)
                }

                if self.timers[self.selectedTimerIndex].isRepeatEnabled {
                    self.reset()
                    self.start()
                } else {
                    self.pause(fromUser: false)
                    self.reset()
                }
            }
        }
        if let t = currentTimer { playTapFeedback(for: t) }
    }

    func pause(fromUser: Bool) {
        isRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
        timer?.invalidate()
        timer = nil

        if fromUser {
            if let t = currentTimer { playTapFeedback(for: t) }
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

    // MARK: - Interaction
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

        if let prev = previousSnappedIndex {
            if snappedIndex != prev {
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

    func restorePurchases() {
        Task { await PurchaseManager.shared.restore() }
    }

    // MARK: - Feedback

    private func playEndFeedback(for timer: TimerModel) {
        guard !timer.isMuted else { return }
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        playSoundIfAllowed(named: "finish", ext: "mp3")
    }

    private func playTapFeedback(for timer: TimerModel) {
        guard !timer.isMuted else { return }
        DispatchQueue.main.async {
            self.feedbackGenerator.prepare()
            self.feedbackGenerator.impactOccurred()
        }
    }

    private func playSnapFeedback(for timer: TimerModel) {
        guard !timer.isMuted else { return }
        DispatchQueue.main.async {
            self.feedbackGenerator.impactOccurred()
        }
    }

    // MARK: - Audio helpers
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

