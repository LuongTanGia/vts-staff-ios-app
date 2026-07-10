
//
//  VTSBadge.swift
//  VTS_STAFF
//
//  Badge, Tag, StatusChip – hiển thị trạng thái và nhãn phân loại
//

import SwiftUI

// MARK: - ============================================================
//                      VTSBadge (text pill)
// MARK: - ============================================================

struct VTSBadge: View {
    let text: String
    let color: Color
    let filled: Bool
    
    init(_ text: String, color: Color = .vtsPrimary, filled: Bool = false) {
        self.text   = text
        self.color  = color
        self.filled = filled
    }
    
    var body: some View {
        Text(text)
            .font(.vtsCaption.bold())
            .foregroundColor(filled ? .white : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(filled ? color : color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(filled ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - ============================================================
//                  VTSStatusChip (trạng thái có dot)
// MARK: - ============================================================

enum VTSStatus {
    case success, warning, danger, info, neutral
    
    var color: Color {
        switch self {
        case .success: return .vtsSuccess
        case .warning: return .vtsWarning
        case .danger:  return .vtsDanger
        case .info:    return .vtsPrimary
        case .neutral: return .vtsTxtSecondary
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger:  return "xmark.circle.fill"
        case .info:    return "info.circle.fill"
        case .neutral: return "circle.fill"
        }
    }
}

struct VTSStatusChip: View {
    let label: String
    let status: VTSStatus
    
    init(_ label: String, status: VTSStatus = .neutral) {
        self.label  = label
        self.status = status
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.vtsCaption.bold())
                .foregroundColor(status.color)
        }
        .padding(.horizontal, VTSSpacing.sm)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.12))
        .cornerRadius(VTSRadius.sm)
    }
}

// MARK: - ============================================================
//              VTSPhieuStatusChip (trạng thái phiếu nghiệp vụ)
// MARK: - ============================================================

/// Map tự động trạng thái phiếu sang màu/status
struct VTSPhieuStatusChip: View {
    let trangThai: String?
    
    var body: some View {
        let (label, status) = resolve(trangThai)
        VTSStatusChip(label, status: status)
    }
    
    private func resolve(_ raw: String?) -> (String, VTSStatus) {
        switch raw?.lowercased() {
        case "hoan thanh", "hoàn thành", "done", "completed":
            return ("Hoàn thành", .success)
        case "cho duyet", "chờ duyệt", "pending":
            return ("Chờ duyệt", .warning)
        case "xoa", "xoá", "cancelled", "huy", "huỷ":
            return ("Đã huỷ", .danger)
        case "dang xu ly", "đang xử lý", "processing":
            return ("Đang xử lý", .info)
        default:
            return (raw ?? "—", .neutral)
        }
    }
}

// MARK: - ============================================================
//                  VTSTag (nhãn danh mục, filter)
// MARK: - ============================================================

struct VTSTag: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    init(_ text: String, isSelected: Bool = false, onTap: @escaping () -> Void = {}) {
        self.text       = text
        self.isSelected = isSelected
        self.onTap      = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.vtsCaption.bold())
                .foregroundColor(isSelected ? .white : .vtsTxtSecondary)
                .padding(.horizontal, VTSSpacing.md)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(LinearGradient.vtsPrimary) : AnyShapeStyle(Color.vtsSurface))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.vtsBorder, lineWidth: 1)
                )
        }
        .buttonStyle(VTSPressButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - VTSTagGroup (scrollable horizontal tags)
struct VTSTagGroup: View {
    let tags: [String]
    @Binding var selected: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VTSSpacing.sm) {
                ForEach(tags, id: \.self) { tag in
                    VTSTag(tag, isSelected: selected == tag) {
                        selected = tag
                    }
                }
            }
            .padding(.horizontal, VTSSpacing.xl)
        }
    }
}

// MARK: - ============================================================
//                  VTSCountBadge (số đỏ trên icon)
// MARK: - ============================================================

struct VTSCountBadge: View {
    let count: Int
    
    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, count > 9 ? 5 : 6)
                .padding(.vertical, 2)
                .background(Color.vtsDanger)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Preview
#Preview("Badges") {
    ZStack {
        LinearGradient.vtsBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            // Badges
            HStack(spacing: 8) {
                VTSBadge("Hoàn thành", color: .vtsSuccess)
                VTSBadge("Chờ duyệt",  color: .vtsWarning)
                VTSBadge("Đã huỷ",     color: .vtsDanger, filled: true)
                VTSBadge("Mới",        color: .vtsPrimary, filled: true)
            }
            
            // Status chips
            HStack(spacing: 8) {
                VTSStatusChip("Hoàn thành", status: .success)
                VTSStatusChip("Chờ duyệt",  status: .warning)
                VTSStatusChip("Đã huỷ",     status: .danger)
            }
            
            // Phieu status (auto)
            HStack(spacing: 8) {
                VTSPhieuStatusChip(trangThai: "Hoàn thành")
                VTSPhieuStatusChip(trangThai: "Chờ duyệt")
                VTSPhieuStatusChip(trangThai: "Đang xử lý")
            }
            
            // Tags
            HStack(spacing: 8) {
                VTSTag("Tất cả",    isSelected: true)
                VTSTag("Hôm nay")
                VTSTag("Tuần này")
                VTSTag("Tháng này")
            }
        }
        .padding()
    }
}
