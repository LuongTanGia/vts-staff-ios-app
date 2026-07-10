
//
//  VTSLiquidContextMenu.swift
//  VTS_STAFF
//
//  Popover menu Xem / Sửa / Xoá – xuất hiện khi tap vào hàng trong bảng
//  Android: Dialog nổi góc phải với icon + text
//  iOS:     Liquid Glass popover với blur material + shadow
//
//  Cách dùng:
//    VTSLiquidContextMenu(actions: [.xem, .xoa, .sua]) { action in
//        switch action {
//        case .xem: viewItem()
//        case .sua: editItem()
//        case .xoa: deleteItem()
//        }
//    }
//

import SwiftUI

// MARK: - VTSLiquidContextMenu
struct VTSLiquidContextMenu: View {
    
    let actions: [VTSRowAction]
    let onSelect: (VTSRowAction) -> Void
    
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.offset) { idx, action in
                if idx > 0 {
                    Divider().overlay(Color.primary.opacity(0.08))
                }
                contextMenuItem(action)
            }
        }
        .frame(width: 160)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
        .scaleEffect(appeared ? 1 : 0.7, anchor: .topTrailing)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
    
    @ViewBuilder
    private func contextMenuItem(_ action: VTSRowAction) -> some View {
        Button {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            onSelect(action)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(action.tintColor.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: action.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(action.tintColor)
                }
                Text(action.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(action.tintColor)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(VTSPressButtonStyle())
    }
}

// MARK: - Preview
#Preview("ContextMenu") {
    ZStack {
        LinearGradient.vtsBackground.ignoresSafeArea()
        VTSLiquidContextMenu(actions: [.xem, .sua]) { action in
            print("Tapped: \(action.label)")
        }
    }
    .preferredColorScheme(.light)
}
