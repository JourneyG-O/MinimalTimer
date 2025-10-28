import SwiftUI

struct TimerRow: View {
    // MARK: - Dependencies
    let timer: TimerModel
    let onSelect: () -> Void
    let onEdit: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {

                HStack {
                    Circle()
                        .fill(timer.color.toColor)
                        .frame(width: 40, height: 40)

                    Spacer(minLength: 12)

                    VStack(alignment: .center, spacing: 4) {
                        Text(timer.title.isEmpty ? "Timer" : timer.title)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text(formatTotalTime(seconds: Int(timer.totalTime)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 15)
                .padding(.leading, 15)

                // ✅ 우측: 편집 버튼 (독립 히트영역)
                Button(action: onEdit) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.borderless)
                .tint(.primary)
                .padding(.trailing, 15)
                .accessibilityLabel("Edit Timer")
                .allowsHitTesting(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Capsule())
        .accessibilityElement(children: .combine)
    }

    // MARK: - Helpers
    private func formatTotalTime(seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
