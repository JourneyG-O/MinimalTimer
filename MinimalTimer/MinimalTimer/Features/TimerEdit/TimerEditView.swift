//
//  TimerEditView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/7/25.
//

import SwiftUI

struct TimerEditView: View {

    // MARK: - ViewModel (Draft 기반)
    @ObservedObject var vm: TimerEditViewModel

    @FocusState private var isTitleFocused: Bool

    // MARK: - Color Options
    private let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .blue, .indigo, .purple,
        .pink, .brown, .gray, .black
    ]

    // MARK: - Preview/Tick layout
    private let previewSize: CGFloat = 150
    private let tickCount: Int = 12
    private let tickLength: CGFloat = 10

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Top Preview (200 * 200 + tick overlay)
            ZStack {
                Circle()
                    .fill(vm.draft.color)
                    .frame(width: previewSize, height: previewSize)

                if vm.draft.isTickAlwaysVisible {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: previewSize, height: previewSize)
                        .overlay(
                            ForEach(0..<tickCount, id: \.self) { tick in
                                Rectangle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 2, height: tickLength)
                                    .offset(y: -(previewSize / 2 - tickLength / 2))
                                    .rotationEffect(.degrees(Double(tick) / Double(tickCount) * 360.0))

                            }
                        )
                }

                Text(formattedTime(vm.draft.totalSeconds))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top)

            // MARK: - Form Section (Title / Color / Time wheel / Options)
            Form {
                // title
                Section(header: Text("Title")) {
                    TextField("Enter timer title", text: $vm.draft.title)
                        .focused($isTitleFocused)
                        .submitLabel(.done)
                }

                // Color grid
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6)) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: vm.draft.color == color ? 2 : 0)
                                )
                                .onTapGesture { vm.draft.color = color }
                                .accessibilityLabel(Text(color == vm.draft.color ? "Selected color" : "Color option"))
                                .accessibilityAddTraits(color == vm.draft.color ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Time
                Section(header: Text("Time")) {
                    HStack {
                        // minutes binding maps to draft.totalSeconds (clamped to 0...120)
                        Picker("Minutes", selection: Binding<Int>(
                            get: { vm.draft.totalSeconds / 60 },
                            set: { newMinutes in
                                let m = max(0, min(newMinutes, Constants.Time.maxMinutes))
                                let s = vm.draft.totalSeconds % 60
                                let maxTotal = Constants.Time.maxMinutes * 60
                                if m >= Constants.Time.maxMinutes && s > 0 {
                                    // 120분에서 초가 남아있으면, 초를 애니메이션으로 0으로 스냅
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        vm.draft.totalSeconds = maxTotal // 120:00
                                    }
                                } else {
                                    vm.draft.totalSeconds = m * 60 + s
                                }
                            }
                        )) {
                            ForEach(0...Constants.Time.maxMinutes, id: \.self) { m in
                                Text("\(m) 분")
                            }
                        }

                        // seconds binding maps to draft.totalSeconds (0...59)
                        Picker("Seconds", selection: Binding<Int>(
                            get: { vm.draft.totalSeconds % 60 },
                            set: { newSeconds in
                                let m = vm.draft.totalSeconds / 60
                                // 분이 최대면 초는 0으로 고정 (UI도 비활성화됨)
                                let sCap = (m >= Constants.Time.maxMinutes) ? 0 : min(max(0, newSeconds), 59)
                                let maxTotal = Constants.Time.maxMinutes * 60
                                let total = m * 60 + sCap
                                vm.draft.totalSeconds = min(total, maxTotal)
                            }
                        )) {
                            ForEach(0..<60, id: \.self) { s in
                                Text("\(s) 초")
                            }
                        }
                        // 분==120 "그리고" 초==0일 때만 비활성화 → 스냅 애니메이션 방해 X
                        .disabled((vm.draft.totalSeconds / 60) >= Constants.Time.maxMinutes
                                  && (vm.draft.totalSeconds % 60) == 0)
                        .opacity(((vm.draft.totalSeconds / 60) >= Constants.Time.maxMinutes
                                  && (vm.draft.totalSeconds % 60) == 0) ? 0.4 : 1.0)
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    // 분이 최대(120)로 바뀌는 순간 초가 > 0이면 0으로 애니메이션 스냅
                    .onChange(of: vm.draft.totalSeconds / 60) { newMinutes, _ in
                        let s = vm.draft.totalSeconds % 60
                        guard newMinutes >= Constants.Time.maxMinutes, s > 0 else { return }
                        withAnimation(.easeInOut(duration: 0.15)) {
                            vm.draft.totalSeconds = Constants.Time.maxMinutes * 60 // 120:00으로 고정
                        }
                    }
                }

                // Options
                Section(header: Text("Options")) {
                    Toggle(isOn: $vm.draft.isTickAlwaysVisible) {
                        Label("Show Ticks", systemImage: "dial.min")
                    }
                    Toggle(isOn: $vm.draft.isVibrationEnabled) {
                        Label("Vibration", systemImage: "waveform.path")
                    }
                    Toggle(isOn: $vm.draft.isSoundEnabled) {
                        Label("Sound", systemImage: "speaker.wave.2")
                    }
                    Toggle(isOn: $vm.draft.isRepeatEnabled) {
                        Label("Repeat", systemImage: "repeat")
                    }
                }
            }
            .frame(maxHeight: 450)
            .scrollContentBackground(.visible)

            // MARK: - Bottom Button
            Button(action: { vm.save() }) {
                Text(vm.actionTitle)
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.isSavable ? vm.draft.color : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.horizontal)
            }
            .disabled(!vm.isSavable)
        }
        .navigationTitle(vm.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .simultaneousGesture(
            TapGesture().onEnded { isTitleFocused = false }
        )
        // 키보드가 올라와도 레이아웃(특히 하단 버튼)을 밀어올리지 않음
        .ignoresSafeArea(.keyboard)
    }

    private func formattedTime(_ sec: Int) -> String {
        let minutes = sec / 60
        let seconds = sec % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationView {
        TimerEditView(
            vm: .init(mode: .create, saveAction: { _, _ in})
        )
    }
}
