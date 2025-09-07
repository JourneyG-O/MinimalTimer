//
//  TimerEditView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/7/25.
//

import SwiftUI

// MARK: - Localization helpers
private func L(_ key: String) -> LocalizedStringKey { LocalizedStringKey(key) }
private func LF(_ key: String, _ args: CVarArg...) -> String {
    String(format: NSLocalizedString(key, comment: ""), arguments: args)
}

struct TimerEditView: View {
    
    @ObservedObject var vm: TimerEditViewModel
    @FocusState private var isTitleFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Local validation flags
    @State private var titleError: Bool = false
    @State private var timeError: Bool = false
    
    // MARK: - Color Options
    private let availableColors = CustomColor.allCases
    
    // MARK: - Preview/Tick layout
    private let previewSize: CGFloat = 150
    private let previewHeaderHeight: CGFloat = 220   // 프리뷰 컨테이너(배경 포함) 높이
    private let previewCornerRadius: CGFloat = 16    // 프리뷰 배경 모서리
    private let tickCount: Int = 12
    private let tickLength: CGFloat = 10
    private let previewPadding: CGFloat = 16
    private let formTopExtraSpacing: CGFloat = 36
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - 1) Base Form (화면 전체, 배경 숨김)
            Form {
                // title
                Section(
                    header:
                        Text(titleError ? L("edit.title.required") : L("edit.timerName"))
                        .foregroundStyle(titleError ? Color.red : Color.secondary)
                        .textCase(nil)
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        TextField(L("edit.placeholder.title"), text: $vm.draft.title)
                            .focused($isTitleFocused)
                            .submitLabel(.done)
                            .onChange(of: vm.draft.title) { _, _ in
                                titleError = false
                            }
                        
                        HStack {
                            let count = vm.draft.title.count
                            let isCJK = vm.draft.title.isCJKLike
                            let softLimit = isCJK ? 8 : 15
                            
                            // dynamic "count/limit"
                            Text(LF("%lld/%lld", count, softLimit))
                                .font(.caption2)
                                .foregroundStyle(count > softLimit ? .orange : .secondary)
                            
                            Spacer()
                            
                            if count > softLimit {
                                Text(L("edit.trimWarning"))
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                
                // Color grid
                Section(header: Text(L("edit.color"))) {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6)) {
                        ForEach(availableColors, id: \.self) { customColor in
                            Circle()
                                .fill(customColor.toColor)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: vm.draft.color == customColor ? 2 : 0)
                                )
                                .onTapGesture { vm.draft.color = customColor }
                                .accessibilityAddTraits(customColor == vm.draft.color ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Time
                Section(
                    header:
                        Text(timeError ? L("edit.time.required") : L("edit.time"))
                        .foregroundStyle(timeError ? Color.red : Color.secondary)
                        .textCase(nil)
                ) {
                    HStack {
                        // minutes binding maps to draft.totalSeconds (clamped to 0...120)
                        Picker(L("edit.minutes"), selection: Binding<Int>(
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
                                Text("\(m) \(NSLocalizedString("edit.minutes", comment: ""))")
                            }
                        }
                        
                        // seconds binding maps to draft.totalSeconds (0...59)
                        Picker(L("edit.seconds"), selection: Binding<Int>(
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
                                Text("\(s) \(NSLocalizedString("edit.seconds", comment: ""))")
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
                    .onChange(of: vm.draft.totalSeconds / 60) { newMinutes, _ in
                        let s = vm.draft.totalSeconds % 60
                        guard newMinutes >= Constants.Time.maxMinutes, s > 0 else { return }
                        withAnimation(.easeInOut(duration: 0.15)) {
                            vm.draft.totalSeconds = Constants.Time.maxMinutes * 60 // 120:00으로 고정
                        }
                    }
                    .onChange(of: vm.draft.totalSeconds) { newValue, _ in
                        if newValue > 0 { timeError = false }
                    }
                }
                
                // Options
                Section(header: Text(L("edit.options"))) {
                    Toggle(isOn: $vm.draft.isTitleAlwaysVisible) {
                        Label(L("edit.option.alwaysShowTitle"), systemImage: "textformat")
                    }
                    Toggle(isOn: $vm.draft.isTickAlwaysVisible) {
                        Label(L("edit.option.alwaysShowTicks"), systemImage: "dial.min")
                    }
                    Toggle(isOn: $vm.draft.isMuted) {
                        Label(L("edit.option.mute"), systemImage: "speaker.slash.fill")
                    }
                    Toggle(isOn: $vm.draft.isRepeatEnabled) {
                        Label(L("edit.option.repeat"), systemImage: "repeat")
                    }
                }
                
                // 편집 모드에서만 노출 삭제 버튼
                if case .edit = vm.mode {
                    Section {
                        Button(role: .destructive) {
                            vm.deleteIfEditing()
                            // 삭제 후 닫기
                            dismiss()
                        } label: {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: previewHeaderHeight + formTopExtraSpacing)
            }
            
            // MARK: - 2) Overlay Preview Header (유리 배경 + 프리뷰 내용)
            ZStack {
                // 유리(머티리얼) 배경 — 사각형 컨테이너
                RoundedRectangle(cornerRadius: previewCornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // 프리뷰 콘텐츠: 원 + 눈금 + 텍스트
                ZStack {
                    Circle()
                        .fill(vm.draft.color.toColor)
                        .frame(width: previewSize, height: previewSize)
                        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
                        .shadow(color: .black.opacity(0.26), radius: 4,  x: 0, y: 2)
                    
                    if vm.draft.isTickAlwaysVisible {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: previewSize, height: previewSize)
                            .overlay(
                                ForEach(0..<tickCount, id: \.self) { tick in
                                    Rectangle()
                                        .fill(Color(.systemBackground))
                                        .frame(width: 2, height: tickLength)
                                        .offset(y: -(previewSize / 2 - tickLength / 2))
                                        .rotationEffect(.degrees(Double(tick) / Double(tickCount) * 360.0))
                                }
                            )
                    }
                    
                    Text(formattedTime(vm.draft.totalSeconds))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(.systemBackground))
                }
            }
            .frame(height: previewHeaderHeight)
            .padding(.top, previewPadding)
            .padding(.horizontal, previewPadding)
        }
        .navigationTitle(vm.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .navigationBarItems(
            leading:
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3), in: Circle())
                },
            trailing:
                Button(action: {
                    handleCheckTap()
                }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(.systemBackground))
                        .padding(8)
                        .background(vm.draft.color.toColor, in: Circle())
                        .opacity(vm.isSavable ? 1 : 0.45)
                }
        )
        .simultaneousGesture(
            TapGesture().onEnded { isTitleFocused = false }
        )
        .ignoresSafeArea(.keyboard)
    }
    
    private func formattedTime(_ sec: Int) -> String {
        let minutes = sec / 60
        let seconds = sec % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Validation & Save
    private func handleCheckTap() {
        let isTitleEmpty = vm.draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isTimeZero = vm.draft.totalSeconds <= 0
        
        if isTitleEmpty { titleError = true }
        if isTimeZero { timeError = true }
        
        guard !isTitleEmpty, !isTimeZero else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        vm.save()
    }
}

#Preview {
    NavigationView {
        TimerEditView(
            vm: .init(mode: .create, saveAction: { _, _ in})
        )
    }
}
