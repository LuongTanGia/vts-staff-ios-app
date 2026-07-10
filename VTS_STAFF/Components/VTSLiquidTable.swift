
//
//  VTSLiquidTable.swift
//  VTS_STAFF
//
//  Bảng dữ liệu dùng lại – Liquid Glass style
//
//  Xuất hiện trong: Hàng hoá, Khách hàng, Xe nhà, Nhân viên, Phiếu VC
//
//  Cách dùng:
//    VTSLiquidTable(
//        columns: [
//            .init(title: "#",       width: 36,  align: .center),
//            .init(title: "Tên",     flex: true, align: .leading),
//            .init(title: "Loại",    width: 80),
//            .init(title: "ĐVT",     width: 52),
//        ],
//        rows: hangHoaList,
//        selectedID: $selectedID,
//        onRowTap: { item in selectedItem = item }
//    ) { item in
//        [item.ma, item.ten, item.loai, item.dvt]
//    }
//

import SwiftUI

// MARK: - Column definition
struct VTSTableColumn {
    let title: String
    let width: CGFloat?      // nil = flex (dùng maxWidth: .infinity)
    let flex: Bool           // true = cột co giãn
    let align: TextAlignment // nội dung căn lề
    
    init(title: String, width: CGFloat? = nil, flex: Bool = false, align: TextAlignment = .center) {
        self.title = title
        self.width = width
        self.flex  = flex || width == nil
        self.align = align
    }
}

// MARK: - Row action
public struct VTSRowAction: Hashable, Identifiable {
    public let id: String
    public let label: String
    public let icon: String
    public let tintColor: Color
    public let isDestructive: Bool
    
    public init(id: String, label: String, icon: String, tintColor: Color = .vtsPrimary, isDestructive: Bool = false) {
        self.id = id
        self.label = label
        self.icon = icon
        self.tintColor = tintColor
        self.isDestructive = isDestructive
    }
    
    // Default static actions for backward compatibility
    public static let xem = VTSRowAction(id: "xem", label: "Xem", icon: "eye.fill", tintColor: .vtsPrimary)
    public static let sua = VTSRowAction(id: "sua", label: "Sửa", icon: "pencil", tintColor: .vtsSecondary)
    public static let xoa = VTSRowAction(id: "xoa", label: "Xoá", icon: "trash.fill", tintColor: .vtsDanger, isDestructive: true)
}

// MARK: - VTSLiquidTable
struct VTSLiquidTable<T: Identifiable>: View {
    
    let columns: [VTSTableColumn]
    let rows: [T]
    @Binding var selectedID: T.ID?
    let actions: [VTSRowAction]              // actions hiện trong context menu
    let onAction: (VTSRowAction, T) -> Void  // callback
    let cellValues: (T) -> [String]          // trả về mảng string theo thứ tự columns
    
    /// Màu highlight hàng chẵn/lẻ (alternating row)
    var alternatingColor: Color = .vtsPrimary.opacity(0.04)
    
    init(
        columns: [VTSTableColumn],
        rows: [T],
        selectedID: Binding<T.ID?> = .constant(nil),
        actions: [VTSRowAction] = [.xem, .sua],
        onAction: @escaping (VTSRowAction, T) -> Void = { _, _ in },
        cellValues: @escaping (T) -> [String]
    ) {
        self.columns    = columns
        self.rows       = rows
        self._selectedID = selectedID
        self.actions    = actions
        self.onAction   = onAction
        self.cellValues = cellValues
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerRow
            
            Divider().overlay(Color.vtsPrimary.opacity(0.3))
            
            // Data rows
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    if rows.isEmpty {
                        emptyCell
                    } else {
                        ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                            dataRow(row, index: idx)
                            if idx < rows.count - 1 {
                                Divider()
                                    .overlay(Color.primary.opacity(0.06))
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
            }
        }
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: Header
    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(columns.indices, id: \.self) { i in
                let col = columns[i]
                Text(col.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.vtsPrimary)
                    .multilineTextAlignment(.center)
                    .if(col.flex) { $0.frame(maxWidth: .infinity) }
                    .if(!col.flex) { $0.frame(width: col.width) }
                
                if i < columns.count - 1 {
                    verticalDivider
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color.vtsPrimary.opacity(0.08))
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
    }
    
    // MARK: Data row
    @ViewBuilder
    private func dataRow(_ row: T, index: Int) -> some View {
        let values    = cellValues(row)
        let isSelected = selectedID == row.id
        
        HStack(spacing: 0) {
            ForEach(columns.indices, id: \.self) { i in
                let col = columns[i]
                let val = i < values.count ? values[i] : "—"
                
                Text(val.isEmpty ? "—" : val)
                    .font(.system(size: 13))
                    .foregroundStyle(isSelected ? Color.vtsPrimary : Color.primary)
                    .multilineTextAlignment(col.align == .leading ? .leading : .center)
                    .lineLimit(2)
                    .if(col.flex)  { $0.frame(maxWidth: .infinity, alignment: col.align == .leading ? .leading : .center) }
                    .if(!col.flex) { $0.frame(width: col.width) }
                    .padding(.leading, i == 0 ? 0 : 0)
                
                if i < columns.count - 1 {
                    verticalDivider
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            isSelected
            ? Color.vtsPrimary.opacity(0.12)
            : (index % 2 == 1 ? alternatingColor : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedID = selectedID == row.id ? nil : row.id
            }
        }
        // Context menu (Xem / Sửa / Xoá) – hiện khi hàng được chọn
        .overlay(alignment: .trailing) {
            if isSelected {
                VTSLiquidContextMenu(actions: actions) { action in
                    onAction(action, row)
                    selectedID = nil
                }
                .padding(.trailing, 8)
                .transition(.scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
    }
    
    // MARK: Empty
    private var emptyCell: some View {
        Text("Không có dữ liệu")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .italic()
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
    }
    
    // MARK: Helpers
    private var verticalDivider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.07))
            .frame(width: 1)
            .frame(maxHeight: .infinity)
    }
}

// MARK: - View conditional modifier helper
extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Preview
#Preview("VTSLiquidTable") {
    struct PreviewItem: Identifiable {
        let id = UUID()
        let stt: String; let ten: String; let loai: String; let dvt: String
    }
    let items = [
        PreviewItem(stt: "1", ten: "Than Bụi",       loai: "Than", dvt: "KG"),
        PreviewItem(stt: "2", ten: "Than Shisha",     loai: "Than", dvt: "KG"),
        PreviewItem(stt: "3", ten: "Nước dừa",        loai: "Dừa",  dvt: "KG"),
        PreviewItem(stt: "4", ten: "Cơm cục",         loai: "Dừa",  dvt: "KG"),
    ]
    @State var sel: UUID? = nil
    return VStack {
        VTSLiquidTable(
            columns: [
                .init(title: "#",    width: 36),
                .init(title: "Tên",  flex: true, align: .leading),
                .init(title: "Loại", width: 70),
                .init(title: "ĐVT",  width: 52),
            ],
            rows: items,
            selectedID: $sel,
            onAction: { action, item in print(action, item.ten) }
        ) { item in [item.stt, item.ten, item.loai, item.dvt] }
            .padding()
    }
    .preferredColorScheme(.dark)
}
