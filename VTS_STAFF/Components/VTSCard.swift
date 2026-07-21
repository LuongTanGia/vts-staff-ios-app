
//
//  VTSCard.swift
//  VTS_STAFF
//
//  Card components: GlassCard, StatCard, InfoRow, SectionHeader
//

import SwiftUI

// MARK: - ============================================================
//                    GLASS CARD (container chung)
// MARK: - ============================================================

struct VTSGlassCard<Content: View>: View {
    let padding: CGFloat
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content
    
    init(
        padding: CGFloat = VTSSpacing.lg,
        cornerRadius: CGFloat = VTSRadius.xxl,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding      = padding
        self.cornerRadius = cornerRadius
        self.content      = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.vtsBorder, lineWidth: 1)
                    )
            )
    }
}

// MARK: - ============================================================
//                    STAT CARD (Dashboard KPI)
// MARK: - ============================================================

struct VTSStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    let trend: Trend?
    
    enum Trend {
        case up(String)    // "▲ 12%"
        case down(String)  // "▼ 5%"
        case neutral
    }
    
    init(
        title: String,
        value: String,
        icon: String,
        gradient: LinearGradient = .vtsPrimary,
        trend: Trend? = nil
    ) {
        self.title    = title
        self.value    = value
        self.icon     = icon
        self.gradient = gradient
        self.trend    = trend
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            // Icon + Title
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: VTSRadius.md, style: .continuous)
                        .fill(gradient)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                // Value
                
                Text(value)
                    .font(.vtsTitle)
                    .foregroundColor(.vtsTxtPrimary)
                    .lineLimit(1)
                
            }
            // Title
            Text(title)
                .font(.vtsCaption)
                .foregroundColor(.vtsTxtSecondary)
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: VTSRadius.xl, style: .continuous)
                .fill(Color.vtsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: VTSRadius.xl, style: .continuous)
                        .stroke(Color.vtsBorder, lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func trendBadge(_ trend: Trend) -> some View {
        switch trend {
        case .up(let text):
            Text("↑ \(text)")
                .font(.vtsCaption.bold())
                .foregroundColor(.vtsSuccess)
                .padding(.horizontal, VTSSpacing.sm)
                .padding(.vertical, 3)
                .background(Color.vtsSuccess.opacity(0.12))
                .cornerRadius(VTSRadius.sm)
        case .down(let text):
            Text("↓ \(text)")
                .font(.vtsCaption.bold())
                .foregroundColor(.vtsDanger)
                .padding(.horizontal, VTSSpacing.sm)
                .padding(.vertical, 3)
                .background(Color.vtsDanger.opacity(0.12))
                .cornerRadius(VTSRadius.sm)
        case .neutral:
            EmptyView()
        }
    }
}

// MARK: - ============================================================
//                    INFO ROW (label : value)
// MARK: - ============================================================

struct VTSInfoRow: View {
    let label: String
    let value: String
    let icon: String?
    let valueColor: Color
    
    init(label: String, value: String, icon: String? = nil, valueColor: Color = .vtsTxtPrimary) {
        self.label      = label
        self.value      = value
        self.icon       = icon
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: VTSSpacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.vtsTxtSecondary)
                    .frame(width: 18)
            }
            Text(label)
                .font(.vtsCallout)
                .foregroundColor(.vtsTxtSecondary)
                .frame(minWidth: 100, alignment: .leading)
            
            Spacer(minLength: 8)
            
            Text(value.isEmpty ? "—" : value)
                .font(.vtsCallout)
                .foregroundColor(value.isEmpty ? .vtsTxtTertiary : valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, VTSSpacing.xs)
    }
}

// MARK: - ============================================================
//                    SECTION HEADER
// MARK: - ============================================================

struct VTSSectionHeader: View {
    let title: String
    let action: (() -> Void)?
    let actionLabel: String
    
    init(_ title: String, action: (() -> Void)? = nil, actionLabel: String = "Xem tất cả") {
        self.title       = title
        self.action      = action
        self.actionLabel = actionLabel
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.vtsTitle2)
                .foregroundColor(.vtsTxtPrimary)
            Spacer()
            if let action {
                Button(actionLabel, action: action)
                    .font(.vtsCaption)
                    .foregroundColor(.vtsPrimary)
            }
        }
    }
}

// MARK: - ============================================================
//               LIST ITEM ROW (cho danh sách phiếu, hàng hoá…)
// MARK: - ============================================================

struct VTSListItemRow: View {
    let title: String
    let subtitle: String?
    let trailing: String?
    let leadingIcon: String?
    let accentColor: Color
    let badge: String?
    let onTap: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        trailing: String? = nil,
        leadingIcon: String? = nil,
        accentColor: Color = .vtsPrimary,
        badge: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.title       = title
        self.subtitle    = subtitle
        self.trailing    = trailing
        self.leadingIcon = leadingIcon
        self.accentColor = accentColor
        self.badge       = badge
        self.onTap       = onTap
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: VTSSpacing.md) {
                // Leading icon
                if let icon = leadingIcon {
                    ZStack {
                        Circle()
                            .fill(Color.vtsBg.opacity(0.08))
                            .frame(width: 42, height: 42)
                        
                        Circle()
                            .stroke(Color.vtsBg.opacity(0.15), lineWidth: 1)
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.vtsBg)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsBg)
                        .lineLimit(1)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.vtsBg)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Trailing
                VStack(alignment: .trailing, spacing: 4) {
                    if let trailing {
                        Text(trailing)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.vtsTxtSecondary)
                    }
                    if let badge {
                        VTSBadge(badge, color: Color.vtsBg)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.vtsBg)
            }
            .padding(.horizontal, VTSSpacing.xl)
            .padding(.vertical, VTSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: VTSRadius.md, style: .continuous)
                    .fill(Color.vtsPrimary)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: VTSRadius.md, style: .continuous)
                    .stroke(Color.vtsBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(VTSPressButtonStyle())
    }
}

// MARK: - Preview
#Preview("Cards") {
    ZStack {
        Color.vtsPrimary.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 16) {
                // Stat cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    VTSStatCard(title: "Phiếu Nhập", value: "142",  icon: "arrow.down.circle.fill",
                                gradient: .vtsPrimary, trend: .up("8%"))
                    VTSStatCard(title: "Phiếu Xuất", value: "98",   icon: "arrow.up.circle.fill",
                                gradient: .vtsSuccess, trend: .down("3%"))
                    VTSStatCard(title: "Xe đang chạy", value: "24", icon: "truck.box.fill",
                                gradient: .vtsWarning)
                    VTSStatCard(title: "Nhân viên", value: "67",    icon: "person.2.fill",
                                gradient: .vtsDanger)
                }
                
                // Glass card with info rows
                VTSGlassCard {
                    VStack(spacing: 0) {
                        VTSSectionHeader("Thông tin phiếu")
                        Divider().overlay(Color.vtsBorder).padding(.vertical, 8)
                        VTSInfoRow(label: "Số phiếu",  value: "PN-2024-001", icon: "doc.text")
                        VTSInfoRow(label: "Ngày",      value: "20/06/2024",  icon: "calendar")
                        VTSInfoRow(label: "Khách hàng",value: "Công ty ABC", icon: "building.2")
                        VTSInfoRow(label: "Trạng thái",value: "Hoàn thành",  icon: "checkmark.circle",
                                   valueColor: .vtsSuccess)
                    }
                }
                
                // List items
                VStack(spacing: 8) {
                    VTSListItemRow(title: "PN-2024-001", subtitle: "20/06/2024 · Công ty ABC",
                                   trailing: "145.5 tấn", leadingIcon: "arrow.down.circle.fill",
                                   accentColor: .vtsPrimary, badge: "Hoàn thành")
                    VTSListItemRow(title: "PX-2024-045", subtitle: "19/06/2024 · Công ty XYZ",
                                   trailing: "98.0 tấn", leadingIcon: "arrow.up.circle.fill",
                                   accentColor: .vtsSuccess, badge: "Chờ duyệt")
                }
            }
            .padding()
        }
    }
}
