//
//  SwitchingView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/18/25.
//
import SwiftUI

struct SwitchingView: View {
    @ObservedObject var vm: MainViewModel
    let ns: Namespace.ID

    private enum Constants {
        static let editButtonHeight: CGFloat = 48
        static let editButtonHorizontalPadding: CGFloat = 50
        static let floatingButtonSize: CGFloat = 48
        static let bottomPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 20
        static let editFont: Font = .headline
        static let addFont: Font = .headline
    }

    var body: some View {
        ZStack {
            TimerPagerView(vm: vm)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 중앙 Edit 버튼
            if let timer = vm.currentTimer {
                VStack {
                    Spacer()
                    Button {
                        vm.presentEditTimerView(at: vm.selectedTimerIndex)
                    } label: {
                        Text("switching.edit")
                            .font(Constants.editFont)
                            .foregroundColor(Color(.systemBackground))
                            .frame(height: Constants.editButtonHeight)
                            .padding(.horizontal, Constants.editButtonHorizontalPadding)
                            .background(timer.color.toColor, in: Capsule())
                    }
                    .padding(.bottom, Constants.bottomPadding)
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))

                // 우측 + 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            vm.presentAddTimerView()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(Color(.systemBackground))
                                .font(Constants.addFont)
                                .frame(width: Constants.floatingButtonSize, height: Constants.floatingButtonSize)
                                .background(timer.color.toColor, in: Circle())
                        }
                        .padding(.trailing, Constants.trailingPadding)
                        .padding(.bottom, Constants.bottomPadding)
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .allowsHitTesting(true)
            }

        }
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: vm.interactionMode)
    }
}
