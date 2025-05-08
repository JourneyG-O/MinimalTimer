//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//

import SwiftUI

struct MainTimerView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack {
            Spacer()

            if viewModel.interactionMode == .switchMode {
                mainTimerUI(scale: 0.8)
            } else {
                mainTimerUI(scale: 1.0)
            }

            Spacer()

            if viewModel.interactionMode == .switchMode {
                timerListScrollView
            }

            if viewModel.interactionMode == .normal {
                Text(formatTime(viewModel.currentTimer?.currentTime ?? 0))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
            }
        }
        .padding(.top, 20)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            withAnimation {
                                viewModel.switchMode()
                            }
                        }
                )
        )
    }

    // 메인 타이머 뷰 구성
    func mainTimerUI(scale: CGFloat) -> some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let size = side * scale
            let center = CGPoint(x: size / 2, y: size / 2)

            return PieShape(progress: viewModel.progress)
                .fill(viewModel.currentTimer?.color ?? .blue)
                .frame(width: size, height: size)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let angle = angleFrom(center: center, to: value.location)
                            viewModel.setUserProgress(from: angle)
                        }
                )
                .onTapGesture(count: 1) {
                    viewModel.isRunning ? viewModel.pause() : viewModel.start()
                }
                .onTapGesture(count: 2) {
                    viewModel.reset()
                }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 260, height: 260)
    }

    // 타이머 리스트 스크롤 뷰
    var timerListScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(viewModel.timers.enumerated()), id: \ .offset) { index, timer in
                    TimerPreviewView(
                        title: timer.title,
                        color: timer.color,
                        isSelected: index == viewModel.selectedTimerIndex,
                        action: {
                            viewModel.selectedTimerIndex = index
                        },
                        showGear: true,
                        grearAction: {
                            viewModel.interactionMode = .editTimer(index: index)
                        }
                    )
                }

                // 타이머 추가 버튼
                Button(action: {
                    viewModel.interactionMode = .create
                }) {
                    VStack {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .frame(width: 90, height: 90)
                            .overlay(Image(systemName: "plus").font(.title2))
                        Text("추가")
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // 각도 계산
    func angleFrom(center: CGPoint, to point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        var angle = atan2(dy, dx) * 180 / .pi
        angle = angle < -90 ? angle + 450 : angle + 90
        return min(max(angle, 0), 360)
    }

    // 시간 포맷터
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}



