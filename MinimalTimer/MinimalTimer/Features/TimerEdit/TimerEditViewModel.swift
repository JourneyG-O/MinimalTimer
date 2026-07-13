//
//  TimerEditViewModel.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/7/25.
//

import SwiftUI

// 타이머 편집/생성 화면에 쓰는 임시 상태(폼 데이터): 원본 TimerModel을 건드리지 않고 안전하게 저장, 화면 닫을 때 저장 안 하면 원본 그대로 유지
struct TimerDraft: Equatable {
    var title: String = ""
    var color: CustomColor = .dynamicForeground
    var isTitleAlwaysVisible: Bool = false
    var totalSeconds: Int = 0
    var isTickAlwaysVisible: Bool = false
    var isMuted: Bool = false
    var isRepeatEnabled: Bool = false
}

@MainActor
final class TimerEditViewModel: ObservableObject {
    enum Mode: Equatable {
        case create
        case edit(index: Int)
    }

    @Published var draft: TimerDraft
    let mode: Mode

    // 저장은 상위(MainViewModel)에서 주입
    private let saveAction: @MainActor (Mode, TimerDraft) -> Void

    // 삭제는 편집 모드에서만 사용
    private let deleteAction: (@MainActor (Int) -> Void)?

    init(mode: Mode,
         initial: TimerDraft = .init(),
         saveAction: @escaping @MainActor (Mode, TimerDraft) -> Void,
         deleteAction: (@MainActor (Int) -> Void)? = nil) {
        self.mode = mode
        self.draft = initial
        self.saveAction = saveAction
        self.deleteAction = deleteAction
    }

    var isSavable: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        draft.totalSeconds > 0
    }

    func setTime(byMinutes minutes: Int) {
        draft.totalSeconds = max(0, min(minutes, Constants.Time.maxMinutes)) * 60
    }

    func save() {
        guard isSavable else { return }
        saveAction(mode, draft)
    }

    func deleteIfEditing() {
        guard case let .edit(index) = mode else { return }
        deleteAction?(index)
    }
}

extension TimerEditViewModel {
    var navTitle: LocalizedStringKey {
        switch mode {
        case .create:
            return L("edit.nav.create")
        case .edit:
            return L("edit.nav.edit")
        }
    }
}
