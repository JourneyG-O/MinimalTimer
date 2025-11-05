//
//  LimitInfoSheet.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 11/5/25.
//

import SwiftUI

struct LimitInfoSheet: View {
    let currentCount: Int
    let limit: Int
    var onUpgrade: () -> Void
    var onManage: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {

            Text("타이머는 무료로 \(limit)개까지")
                .font(.title3.bold())
            Text("지금 \(currentCount)/\(limit)개를 사용 중입니다.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("기존 타이머 정리하기", action: onManage)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.bordered)

                Button("Pro로 업그레이드", action: onUpgrade)
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                    .foregroundStyle(.background)
            }
            .padding(.top, 4)

            Button("닫기", action: onClose)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding(20)
        .presentationDetents([.height(220), .medium])
    }
}
