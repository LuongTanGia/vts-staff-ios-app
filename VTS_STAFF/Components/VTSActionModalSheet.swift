//
//  VTSActionModalSheet.swift
//  VTS_STAFF
//
//  Created by Antigravity on 02/09/2026.
//  Modal hành động đồng nhất xuất hiện khi người dùng long-click trên thẻ / hàng của các trang danh sách.
//

import SwiftUI

public struct VTSModalAction: Identifiable {
    public let id: String
    public let title: String
    public let icon: String
    public let isDestructive: Bool
    public let action: () -> Void
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        icon: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
}

public struct VTSActionModalSheet: View {
    public let title: String
    public var subtitle: String? = nil
    public let actions: [VTSModalAction]
    public var onClose: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        title: String,
        subtitle: String? = nil,
        actions: [VTSModalAction],
        onClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actions = actions
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 38, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)
            
            // Header
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.vtsTxtPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            
            // Actions List
            VStack(spacing: 10) {
                ForEach(actions) { item in
                    Button {
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                        onClose?()
                        dismiss()
                        item.action()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(item.isDestructive ? Color.vtsDanger.opacity(0.12) : Color.vtsPrimary.opacity(0.12))
                                    .frame(width: 38, height: 38)
                                Image(systemName: item.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(item.isDestructive ? .vtsDanger : .vtsPrimary)
                            }
                            
                            Text(item.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(item.isDestructive ? .vtsDanger : .vtsTxtPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.vtsTxtTertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(item.isDestructive ? Color.vtsDanger.opacity(0.06) : Color(uiColor: .systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(item.isDestructive ? Color.vtsDanger.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
                        )
                    }
                    .buttonStyle(VTSPressButtonStyle())
                }
                
                Button {
                    onClose?()
                    dismiss()
                } label: {
                    Text("Đóng")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.vtsTxtSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(VTSPressButtonStyle())
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
