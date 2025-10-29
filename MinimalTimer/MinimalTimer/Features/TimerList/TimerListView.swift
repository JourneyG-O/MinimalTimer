//
//  TimerListView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/22/25.
//

import SwiftUI
import StoreKit

struct TimerListView: View {
    // MARK: - Dependencies
    @ObservedObject var vm: MainViewModel
    var onCreate: (() -> Void)?
    var onEdit: ((Int) -> Void)?
    var onShowPaywall: (() -> Void)?
    var onSelectTimer: ((Int) -> Void)?
    
    
    // MARK: - States
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var isPresentingSettings: Bool = false
    @State private var showSafari = false
    @State private var selectedPolicyURL: URL?
    @State private var isPurchasing: Bool = false
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    // MARK: - Body
    var body: some View {
        
        VStack(spacing: 0) {
            List {
                ForEach(vm.timers) { timer in         // ← indices 대신 모델 자체 사용
                    let index = vm.timers.firstIndex(where: { $0.id == timer.id }) ?? 0
                    
                    TimerRow(
                        timer: timer,
                        onSelect: { handleSelect(index) },
                        onEdit:   { handleEdit(index) }
                    )
                    .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                    .swipeActions(edge: .trailing) {
                        Button {
                            if editMode?.wrappedValue == .active {
                                editMode?.wrappedValue = .inactive
                            } else {
                                editMode?.wrappedValue = .active
                            }
                        } label: {
                            Label("Reorder", systemImage: "arrow.up.arrow.down")
                        }
                        .tint(.blue)
                        
                        Button(role: .destructive) {
                            vm.deleteTimer(at: index)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .moveDisabled(editMode?.wrappedValue != .active)
                }
                .onMove { from, to in
                    vm.timers.move(fromOffsets: from, toOffset: to)
                    vm.saveTimers()
                }
                .onDelete { indexSet in
                    indexSet.sorted(by: >).forEach { vm.deleteTimer(at: $0) }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            if !vm.isPremium {
                PaywallPromoRow {
                    onShowPaywall?()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 80)
            }
        }
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if editMode?.wrappedValue == .active {
                    Button {
                        editMode?.wrappedValue = .inactive
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel("편집 완료")
                } else {
                    Button {
                        isPresentingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("설정")
                }
            }
        }
        .sheet(isPresented: $isPresentingSettings) {
            NavigationStack {
                List {
                    Section("프리미엄") {
                        if purchaseManager.isPremium || vm.isPremium {
                            Label("프리미엄 활성화됨", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        } else {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("모든 기능 잠금해제")
                                    Text(purchaseManager.localizedPrice.isEmpty ? "가격 불러오는 중…" : purchaseManager.localizedPrice)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    isPurchasing = true
                                    Task {
                                        let _ = await purchaseManager.purchase()
                                        isPurchasing = false
                                        if purchaseManager.isPremium { vm.handleUpgradePurchased() }
                                    }
                                }) {
                                    if isPurchasing {
                                        ProgressView()
                                    } else {
                                        Text("구매")
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            Button("복원") {
                                Task { await purchaseManager.restore() }
                            }
                        }

                        if let err = purchaseManager.lastError {
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    Section("앱 정보") {
                        HStack {
                            Text("버전")
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Section("정책") {
                        Button("이용약관") {
                            if let url = URL(string: "https://stannum.app/apps/minimal-timer/legal/terms.html") {
                                selectedPolicyURL = url
                                isPresentingSettings = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    showSafari = true
                                }
                            }
                        }
                        
                        Button("개인정보처리방침") {
                            if let url = URL(string: "https://stannum.app/apps/minimal-timer/legal/privacy.html") {
                                selectedPolicyURL = url
                                isPresentingSettings = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    showSafari = true
                                }
                            }
                        }
                    }
                }
                .navigationTitle("설정")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { isPresentingSettings = false }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
            .task { await purchaseManager.refreshProducts() }
        }
        .sheet(isPresented: $showSafari) {
            if let url = selectedPolicyURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: purchaseManager.isPremium) { newValue, _ in
            if newValue { vm.handleUpgradePurchased() }
        }
    }
    
    // MARK: - Helpers
    private func handleSelect(_ index: Int) {
        vm.selectTimer(at: index)
        UISelectionFeedbackGenerator().selectionChanged()
        onSelectTimer?(index)
    }
    
    private func handleCreate() {
        onCreate?()
    }
    
    private func handleEdit(_ index: Int) {
        onEdit?(index)
    }
}

