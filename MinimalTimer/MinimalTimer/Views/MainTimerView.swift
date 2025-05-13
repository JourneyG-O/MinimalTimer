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
        NavigationStack {
            VStack(spacing: 20) {
                TimerContentView(viewModel: viewModel)
                    .frame(maxHeight: .infinity)
                Spacer()
                RemainingTimeView(viewModel: viewModel)
            }
            .padding()
            .navigationTitle(viewModel.currentTimer?.title ?? "타이머")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                withAnimation {
                                    viewModel.interactionMode = .switchMode
                                }
                            }
                    )
            )
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}
