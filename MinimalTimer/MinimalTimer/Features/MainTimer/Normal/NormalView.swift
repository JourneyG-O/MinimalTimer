//
//  NormalView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/18/25.
//

import SwiftUI
struct NormalView: View {
    @ObservedObject var vm: MainViewModel
    let ns: Namespace.ID

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if let t = vm.currentTimer, t.isTitleAlwaysVisible {
                    TitleView(title: t.title)
                }

                Spacer()
                if let timer = vm.currentTimer {
                    SingleTimerView(
                        timer: timer,
                        progress: vm.progress,
                        isRunning: vm.isRunning,
                        isDragging: vm.isDragging,
                        interactionMode: vm.interactionMode,
                        onSingleTap: vm.startOrPauseTimer,
                        onDoubleTap: vm.reset,
                        onDrag: { angle in vm.setUserProgress(from: angle) },
                        onDragEnd: vm.endDragging
                    )
                    .matchedGeometryEffect(id: "TIMER_CIRCLE", in: ns)
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.8,
                           height: min(geometry.size.width, geometry.size.height) * 0.8)
                    .popInOnAppear()
                }
                Spacer()
                RemainingTimeView(viewModel: vm)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

