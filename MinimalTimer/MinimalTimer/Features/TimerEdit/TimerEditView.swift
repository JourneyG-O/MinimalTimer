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
        .red, .orange, .yellow, .green, .mint, .teal,
        .blue, .indigo, .purple, .pink, .brown, .gray
    ]

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Preview Circle
            ZStack {
                Circle()
                    .fill(vm.draft.color)
                    .frame(width: 120, height: 120)

                Text(formattedTime(vm.draft.totalSeconds))
                    .font(.title)
                    .bold()

                if vm.draft.isTickAlwaysVisible {
                    Circle()
                        .strokeBorder(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 130, height: 130)
                }
            }
            .padding(.top)

            // MARK: - Form
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("타이머 이름", text: $vm.draft.title)
                }

                Section(header: Text("색상 선택")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6), spacing: 12) {
                        ForEach(availableColors.indices, id: \.self) { i in
                            let color = availableColors[i]
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: vm.draft.color == color ? 3 : 0)
                                )
                                .onTapGesture { vm.draft.color = color }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("시간 설정")) {
                    Stepper(
                        value: Binding(
                            get: { vm.draft.totalSeconds / 120},
                            set: { vm.setTime(byMinutes: $0) }
                        ),
                        in: 0...60, step: 1
                    ) {
                        Text(formattedTime(vm.draft.totalSeconds))
                    }
                }

                Section(header: Text("추가 옵션")) {
                    Toggle("눈금 항상 표시", isOn: $vm.draft.isTickAlwaysVisible)
                    Toggle("진동", isOn: $vm.draft.isVibrationEnabled)
                    Toggle("소리", isOn: $vm.draft.isSoundEnabled)
                    Toggle("반복", isOn: $vm.draft.isRepeatEnabled)
                }
            }

            // MARK: - Bottom Button
            Button(action: { vm.save() }) {
                Text(vm.actionTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.isSavable ? Color.accentColor : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(!vm.isSavable)
        }
        .navigationTitle(vm.navTitle)
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
