//
//  TimerEditView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/7/25.
//

import SwiftUI

struct TimerEditView: View {
    // MARK: - Temporary UI State
    @State private var title: String = ""
    @State private var selectedColor: Color = .red
    @State private var totalTime: TimeInterval = 0
    @State private var isTickAlwaysVisible: Bool = false
    @State private var isVibrationEnabled: Bool = true
    @State private var isSoundEnabled: Bool = true
    @State private var isRepeatEnabled: Bool = false

    // MAKR: - Color Options
    private let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .blue, .indigo, .purple, .pink, .brown, .gray
    ]

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Preview Circle
            ZStack {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 120, height: 120)

                Text(formattedTime(totalTime))
                    .font(.title)
                    .bold()

                if isTickAlwaysVisible {
                    Circle()
                        .strokeBorder(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 130, height: 130)
                }
            }
            .padding(.top)

            // MARK: - Form
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("타이머 이름", text: $title)
                }

                Section(header: Text("색상 선택")) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6), spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("시간 설정")) {
                    Stepper(value: Binding(get: {
                        Int(totalTime)
                    }, set: {
                        totalTime = TimeInterval($0)
                    }), in: 0...3600, step: 60) {
                        Text(formattedTime(totalTime))
                    }
                }

                Section(header: Text("추가 옵션")) {
                    Toggle("눈금 항상 표시", isOn: $isTickAlwaysVisible)
                    Toggle("진동", isOn: $isVibrationEnabled)
                    Toggle("소리", isOn: $isSoundEnabled)
                    Toggle("반복", isOn: $isRepeatEnabled)
                }
            }

            // MARK: - Bottom Button
            Button(action: {
                print("타이머 생성 또는 저장 로직")
            }) {
                Text("생성")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("타이머 설정")
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationView {
        TimerEditView()
    }
}
