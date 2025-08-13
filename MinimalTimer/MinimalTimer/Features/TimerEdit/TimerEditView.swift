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

    // MARK: - Color Options
    private let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .blue, .indigo, .purple,
        .pink, .brown, .gray, .black
    ]

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Top Preview (200 * 200 + tick overlay)
            ZStack {
                Circle()
                    .fill(vm.draft.color)
                    .frame(width: 150, height: 150)

                if vm.draft.isTickAlwaysVisible {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 150, height: 150)
                        .overlay(
                            ForEach(0..<12, id: \.self) { tick in
                                Rectangle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 2, height: 10)
                                    .offset(y: -100)
                                    .rotationEffect(.degrees(Double(tick) / 12.0 * 360.0))

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
                                vm.draft.totalSeconds = m * 60 + s
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
                                let s = max(0, min(newSeconds, 59))
                                let m = vm.draft.totalSeconds / 60
                                vm.draft.totalSeconds = m * 60 + s
                            }
                        )) {
                            ForEach(0..<60, id: \.self) { s in
                                Text("\(s) 초")
                            }
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
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
