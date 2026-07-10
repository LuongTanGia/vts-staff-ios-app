//
//  DataListView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct DataListView: View {
    @Environment(\.router) private var router
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedFunction: TChucNangPhanQuyen?
    
    
    // Group of functions
    var groupedGroups: [(name: String, items: [TChucNangPhanQuyen])] {
        let excludedCodes = [
            "VTSSTAFF_DASBOARD_NHANVIEN",
            "VTSSTAFF_DULIEU_PHIEUGIACONG",
            "VTSSTAFF_DULIEU_PHIEUNHAP",
            "VTSSTAFF_DULIEU_PHIEUXUAT"
        ]
        let groups = Dictionary(grouping: authManager.chucNangPhanQuyens.filter {  Fitem in
            !excludedCodes.contains(Fitem.maChucNang) && Fitem.visible && Fitem.view
        }) { fn in
            fn.tenNhomChucNang ?? ""
        }
        
        return groups.map { (key, value) in
            let sortedItems = value.sorted { item1, item2 in
                let sort1 = Int(item1.sapXep ?? "") ?? 999
                let sort2 = Int(item2.sapXep ?? "") ?? 999
                if sort1 != sort2 {
                    return sort1 < sort2
                }
                return item1.maChucNang < item2.maChucNang
            }
            return (name: key, items: sortedItems)
        }
        .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                if groupedGroups.isEmpty {
                    VTSEmptyState(
                        icon: "square.grid.2x2",
                        title: "Không có chức năng",
                        subtitle: "Tài khoản của bạn chưa được phân quyền chức năng nào."
                    )
                } else {
                    // Content List
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: VTSSpacing.lg) {
                            ForEach(groupedGroups, id: \.name) { group in
                                VStack(alignment: .leading, spacing: VTSSpacing.md) {
                                    VTSSectionHeader(group.name)
                                        .padding(.horizontal, VTSSpacing.xs)
                                    
                                    VStack(spacing: VTSSpacing.md) {
                                        ForEach(group.items) { item in
                                            VTSListItemRow(
                                                title: item.tenChucNang,
                                                subtitle: item.ghiChu ?? "Mã: \(item.maChucNang)",
                                                leadingIcon: iconForFunction(item.maChucNang),
                                                accentColor: accentColorForFunction(item.maChucNang),
                                                onTap: {
                                                    navigate(to: item)
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, VTSSpacing.xl)
                        .padding(.top, VTSSpacing.lg)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Dữ liệu"
        ){
            
        } trailing: {
            
        } primaryAction: {
            
        }
        
    }
    
    // MARK: - Helpers
    
    private func navigate(to item: TChucNangPhanQuyen) {
        switch item.maChucNang {
        case "VTSSTAFF_DANHMUC_NHANVIEN":
            router.showScreen(.push) { _ in
                NhanVienListView()
            }
        case "VTSSTAFF_DANHMUC_XE":
            router.showScreen(.push) { _ in
                XeListView()
            }
        case "VTSSTAFF_DANHMUC_KHACHHANG":
            router.showScreen(.push) { _ in
                KhachHangListView()
            }
        case "VTSSTAFF_DANHMUC_HANGHOA":
            router.showScreen(.push) { _ in
                HangHoaListView()
            }
        case "VTSSTAFF_DULIEU_PHIEUGIACONG":
            router.showScreen(.push) { _ in
                PhieuGiaCongListView()
            }
        case "VTSSTAFF_DULIEU_PHIEUNHAP":
            router.showScreen(.push) { _ in
                PhieuNhapListView()
            }
        case "VTSSTAFF_DULIEU_PHIEUXUAT":
            router.showScreen(.push) { _ in
                PhieuXuatListView()
            }
        default:
            selectedFunction = item
            
        }
    }
    
    private func iconForFunction(_ code: String) -> String {
        let codeLower = code.lowercased()
        if codeLower.contains("profile") || codeLower.contains("user") || codeLower.contains("nhanvien") || codeLower.contains("hrm") {
            return "person.fill"
        } else if codeLower.contains("setting") || codeLower.contains("config") || codeLower.contains("sys") {
            return "gearshape.fill"
        } else if codeLower.contains("weigh") || codeLower.contains("ticket") || codeLower.contains("phieu") {
            return "scalemass.fill"
        } else if codeLower.contains("trip") || codeLower.contains("schedule") || codeLower.contains("chuyenxe") {
            return "truck.box.fill"
        } else if codeLower.contains("report") || codeLower.contains("excel") || codeLower.contains("chart") {
            return "chart.bar.fill"
        } else {
            return "square.grid.2x2.fill"
        }
    }
    
    private func accentColorForFunction(_ code: String) -> Color {
        let codeLower = code.lowercased()
        if codeLower.contains("profile") || codeLower.contains("user") || codeLower.contains("nhanvien") || codeLower.contains("hrm") {
            return .vtsPrimary
        } else if codeLower.contains("setting") || codeLower.contains("config") || codeLower.contains("sys") {
            return .vtsSecondary
        } else if codeLower.contains("weigh") || codeLower.contains("ticket") || codeLower.contains("phieu") {
            return .vtsInfo
        } else if codeLower.contains("trip") || codeLower.contains("schedule") || codeLower.contains("chuyenxe") {
            return .vtsWarning
        } else if codeLower.contains("report") || codeLower.contains("excel") || codeLower.contains("chart") {
            return .vtsSuccess
        } else {
            return .vtsPrimary
        }
    }
}

#Preview {
    RouterView { _ in
        DataListView()
    }
}
