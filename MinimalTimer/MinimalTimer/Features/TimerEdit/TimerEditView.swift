//
//  TimerEditView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/7/25.
//

import SwiftUI

struct TimerEditView: View {

    @StateObject private var vm: TimerEditViewModel
    @FocusState private var isTitleFocused: Bool
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var purchaseManager: PurchaseManager

    var onPaywall: (() -> Void)? = nil

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

    // MARK: - Helpers
    private var minutesBinding: Binding<Int> {
        Binding<Int>(
            get: { vm.draft.totalSeconds / 60 },
            set: { newMinutes in
                let m = max(0, min(newMinutes, Constants.Time.maxMinutes))
                let s = vm.draft.totalSeconds % 60
                let maxTotal = Constants.Time.maxMinutes * 60
                if m >= Constants.Time.maxMinutes && s > 0 {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        vm.draft.totalSeconds = maxTotal
                    }
                } else {
                    vm.draft.totalSeconds = m * 60 + s
                }
            }
        )
    }

    private var secondsBinding: Binding<Int> {
        Binding<Int>(
            get: { vm.draft.totalSeconds % 60 },
            set: { newSeconds in
                let m = vm.draft.totalSeconds / 60
                let sCap = (m >= Constants.Time.maxMinutes) ? 0 : min(max(0, newSeconds), 59)
                let maxTotal = Constants.Time.maxMinutes * 60
                let total = m * 60 + sCap
                vm.draft.totalSeconds = min(total, maxTotal)
            }
        )
    }

    private func triggerPaywall() {
        if let onPaywall {
            onPaywall()
        } else {
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.warning)
        }
    }

    private func enforceColorEntitlement() {
        guard !purchaseManager.isPremium else { return }
        guard let first = availableColors.first else { return }
        if vm.draft.color != first {
            vm.draft.color = first
        }
    }

    // MARK: - Subviews
    private var titleSection: some View {
        Section(
            header:
                Text(titleError ? L("edit.title.required") : L("edit.timerName"))
                .foregroundStyle(titleError ? Color.red : Color.primary)
                .textCase(nil)
        ) {
            VStack(alignment: .leading, spacing: 6) {
                TextField(L("edit.placeholder.name"), text: $vm.draft.title)
                    .focused($isTitleFocused)
                    .submitLabel(.done)
                    .onChange(of: vm.draft.title) { _, _ in
                        titleError = false
                    }
                    .accessibilityLabel(L("edit.timername.label"))
                    .accessibilityValue(Text(LocalizedStringKey(vm.draft.title.isEmpty ? String(localized: "edit.title.untitled", defaultValue: "Untitled") : vm.draft.title)))
                    .accessibilityHint(L("edit.timername.hint"))

                HStack {
                    let count = vm.draft.title.count
                    let isCJK = vm.draft.title.isCJKLike
                    let softLimit = isCJK ? 8 : 15

                    Text("\(count)/\(softLimit)")
                        .font(.caption2)
                        .foregroundStyle(count > softLimit ? .orange : .secondary)

                    Spacer()

                    if count > softLimit {
                        Text(L("edit.trimwarning"))
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
    }

    private var colorGridSection: some View {
        Section(header: sectionHeader(L("edit.color"))) {
            let firstColor = availableColors.first
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6)) {
                ForEach(availableColors, id: \.self) { customColor in
                    let isUnlocked = purchaseManager.isPremium || customColor == firstColor
                    ZStack {
                        Circle()
                            .fill(customColor.toColor)
                            .frame(width: 40, height: 40)
                            .opacity(isUnlocked ? 1.0 : 0.45)
                            .overlay(alignment: .center) {
                                if !isUnlocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                        .padding(2)
                                }
                            }

                        Circle()
                            .fill(.clear)
                            .frame(width: 46, height: 46)
                            .overlay(
                                Circle().stroke(Color(.gray), lineWidth: vm.draft.color == customColor ? 3 : 0)
                            )
                        // Invisible tap catcher to either select or show paywall
                        Color.clear
                            .contentShape(Circle())
                            .onTapGesture {
                                if isUnlocked {
                                    vm.draft.color = customColor
                                } else {
                                    triggerPaywall()
                                }
                            }
                    }
                    .accessibilityLabel(LF("edit.color.value", String(describing: customColor)))
                    .accessibilityHint(isUnlocked ? Text(LocalizedStringKey("")) : Text(L("premium.locked")))
                    .accessibilityAddTraits(vm.draft.color == customColor ? .isSelected : [])
                }
            }
            .padding(.vertical, 4)
        }
        .onAppear { enforceColorEntitlement() }
        .onChange(of: purchaseManager.isPremium) {
            enforceColorEntitlement()
        }
        .onChange(of: vm.draft.color) {
            enforceColorEntitlement()
        }
    }

    private var timeSection: some View {
        Section(
            header:
                Text(timeError ? L("edit.time.required") : L("edit.time"))
                .foregroundStyle(timeError ? Color.red : Color.primary)
                .textCase(nil)
        ) {
            HStack {
                Picker(L("edit.minutes"), selection: minutesBinding) {
                    ForEach(0...Constants.Time.maxMinutes, id: \.self) { m in
                        Text(LF("edit.minutes.value", m))
                    }
                }

                Picker(L("edit.seconds"), selection: secondsBinding) {
                    ForEach(0..<60, id: \.self) { s in
                        Text(LF("edit.seconds.value", s))
                    }
                }
                .disabled((vm.draft.totalSeconds / 60) >= Constants.Time.maxMinutes && (vm.draft.totalSeconds % 60) == 0)
                .opacity(((vm.draft.totalSeconds / 60) >= Constants.Time.maxMinutes && (vm.draft.totalSeconds % 60) == 0) ? 0.4 : 1.0)
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .onChange(of: vm.draft.totalSeconds / 60) { newMinutes, _ in
                let s = vm.draft.totalSeconds % 60
                guard newMinutes >= Constants.Time.maxMinutes, s > 0 else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    vm.draft.totalSeconds = Constants.Time.maxMinutes * 60
                }
            }
            .onChange(of: vm.draft.totalSeconds) { newValue, _ in
                if newValue > 0 { timeError = false }
            }
        }
    }

    private var optionsSection: some View {
        Section(header: sectionHeader(L("edit.options"))) {
            premiumToggle(isOn: $vm.draft.isTitleAlwaysVisible) {
                Label(L("edit.option.alwaysShowTitle"), systemImage: "textformat")
            }
            premiumToggle(isOn: $vm.draft.isTickAlwaysVisible) {
                Label(L("edit.option.alwaysShowTicks"), systemImage: "dial.min")
            }
            premiumToggle(isOn: $vm.draft.isMuted) {
                Label(L("edit.option.mute"), systemImage: "speaker.slash.fill")
            }
            premiumToggle(isOn: $vm.draft.isRepeatEnabled) {
                Label(L("edit.option.repeat"), systemImage: "repeat")
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        HStack(spacing: 6) {
            if !purchaseManager.isPremium {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            Text(title)
        }
        .textCase(nil)
        .foregroundStyle(purchaseManager.isPremium ? .primary : .secondary)
        .accessibilityLabel({
            let accessibilityString: String
            let titleString = String(describing: title)

            if purchaseManager.isPremium {
                accessibilityString = titleString
            } else {

                let lockedString = L("premium.locked")
                accessibilityString = "\(titleString), \(lockedString)"
            }
            return Text(accessibilityString)
        }())
        .accessibilityHint(
            purchaseManager.isPremium
            ? Text("")
            : Text(L("premium.locked"))
        )
    }

    @ViewBuilder
    private func premiumToggle(isOn: Binding<Bool>, label: () -> some View) -> some View {
        ZStack {
            Toggle(isOn: isOn) { label() }
                .opacity(purchaseManager.isPremium ? 1.0 : 0.45)
                .disabled(!purchaseManager.isPremium)
            // Tap catcher overlay to show paywall when not premium
            if !purchaseManager.isPremium {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { triggerPaywall() }
            }
        }
        .overlay(alignment: .trailing) {
            if !purchaseManager.isPremium {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(5)
            }
        }
        .accessibilityHint(purchaseManager.isPremium ? Text("") : Text(L("premium.locked")))
    }

    private var previewHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: previewCornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)

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

    init(
        mode: TimerEditViewModel.Mode,
        initial: TimerDraft = .init(),
        onPaywall: (() -> Void)? = nil,
        saveAction: @escaping (TimerEditViewModel.Mode, TimerDraft) -> Void,
        deleteAction:((Int) -> Void)? = nil
    ) {
        _vm = StateObject(wrappedValue: TimerEditViewModel(
            mode: mode,
            initial: initial,
            saveAction: saveAction,
            deleteAction: deleteAction
        ))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - 1) Base Form (화면 전체, 배경 숨김)
            Form {
                // title
                titleSection

                // Color grid
                colorGridSection

                // Time
                timeSection

                // Options
                optionsSection

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
                        .accessibilityLabel(L("edit.delete.label"))
                        .accessibilityHint(L("edit.delete.hint"))
                    }
                }
            }
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: previewHeaderHeight + formTopExtraSpacing)
            }

            // MARK: - 2) Overlay Preview Header (유리 배경 + 프리뷰 내용)
            previewHeader
        }
        .navigationTitle(vm.navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .navigationBarItems(
            leading:
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
                .accessibilityLabel(L("edit.close.label"))
                .accessibilityHint(L("edit.close.hint")),
            trailing:
                Button(action: {
                    handleCheckTap()
                }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.primary)
                        .opacity(vm.isSavable ? 1 : 0.3)
                }
                .accessibilityLabel(L("edit.save.label"))
                .accessibilityHint(L("edit.save.hint"))
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

        // Success path: provide light feedback, save, and dismiss
        let successGenerator = UINotificationFeedbackGenerator()
        successGenerator.notificationOccurred(.success)

        // End any active text field focus before dismissing
        isTitleFocused = false

        vm.save()

        // Dismiss after successful save
        dismiss()
    }
}

#Preview {
    NavigationView {
        TimerEditView(
            mode: .create,
            initial: .init(),
            onPaywall: { print("Present Paywall") },
            saveAction: { _, _ in }
        )
        .environment(\.isPremium, false)
    }
}

/*
 Localization Keys to provide (EditTimerView)
 - "edit.timername" = "Timer name";
 - "edit.timername.label" = "Timer name";
 - "edit.timername.hint" = "Enter a name for your timer.";
 - "edit.title.required" = "Title is required";
 - "edit.placeholder.name" = "Name";
 - "edit.title.count.value" = "%lld/%lld"; // current/limit
 - "edit.trimwarning" = "Title may be trimmed.";
 - "edit.color" = "Color";
 - "edit.color.value" = "%@"; // color name
 - "premium.locked" = "Premium feature locked";
 - "edit.time" = "Time";
 - "edit.time.required" = "Time is required";
 - "edit.minutes" = "Minutes";
 - "edit.seconds" = "Seconds";
 - "edit.minutes.value" = "%lld minutes"; // stringsdict candidate
 - "edit.seconds.value" = "%lld seconds"; // stringsdict candidate
 - "edit.options" = "Options";
 - "edit.option.alwaysshowtitle" = "Always show title";
 - "edit.option.alwaysshowticks" = "Always show ticks";
 - "edit.option.mute" = "Mute";
 - "edit.option.repeat" = "Repeat";
 - "edit.delete.label" = "Delete timer";
 - "edit.delete.hint" = "Delete this timer and close the editor.";
 - "edit.close.label" = "Close";
 - "edit.close.hint" = "Close the editor without saving.";
 - "edit.save.label" = "Save";
 - "edit.save.hint" = "Save changes and close the editor.";
 - "edit.title.untitled" = "Untitled";

 Stringsdict candidates:
 - edit.minutes.value (singular/plural)
 - edit.seconds.value (singular/plural)
 */

