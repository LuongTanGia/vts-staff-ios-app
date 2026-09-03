//
//  HomeView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct HomeView: View {
    
    @Environment(\.router) private var router
    @ObservedObject private var authManager = AuthManager.shared
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var hasLoadedData = false
    
    @AppStorage("vts_show_nhan_vien") private var showNhanVienStats = true
    @AppStorage("vts_show_nhap_homnay") private var showNhapHomNay = true
    @AppStorage("vts_show_nhap_tuannay") private var showNhapTuanNay = false
    
    @AppStorage("vts_show_xuat_homnay") private var showXuatHomNay = true
    @AppStorage("vts_show_xuat_tuannay") private var showXuatTuanNay = false
    
    private var hasNHANVIENPermission: Bool {
        authManager.getPermission(for: "VTSSTAFF_DANHMUC_NHANVIEN")?.visible == true &&
        authManager.getPermission(for: "VTSSTAFF_DANHMUC_NHANVIEN")?.view == true
    }
    
    private var hasXEPermission: Bool {
        authManager.getPermission(for: "VTSSTAFF_DANHMUC_XE")?.visible == true &&
        authManager.getPermission(for: "VTSSTAFF_DANHMUC_XE")?.view == true
    }
    
    private var hasNHAPPermission: Bool {
        authManager.getPermission(for: "VTSSTAFF_DULIEU_PHIEUNHAP")?.visible == true &&
        authManager.getPermission(for: "VTSSTAFF_DULIEU_PHIEUNHAP")?.view == true
    }
    
    private var hasXUATPermission: Bool {
        authManager.getPermission(for: "VTSSTAFF_DULIEU_PHIEUXUAT")?.visible == true &&
        authManager.getPermission(for: "VTSSTAFF_DULIEU_PHIEUXUAT")?.view == true
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true){
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        VTSAsyncContent(
                            state: viewModel.dashboardState,
                            emptyTitle: "Không có dữ liệu thống kê",
                            emptySubtitle: "Vui lòng thử lại sau hoặc liên hệ quản trị viên.",
                            emptyIcon: "chart.pie.fill",
                            retry: {
                                Task {
                                    await viewModel.loadDashboardData()
                                }
                            }
                        ) { data in
                            
                            let nhapHomNay = data.hangNhap.filter { $0.colGroup.localizedCaseInsensitiveContains("HOMNAY") }
                            let nhapTuanNay = data.hangNhap.filter { $0.colGroup.localizedCaseInsensitiveContains("TUANNAY") }
                            
                            let xuatHomNay = data.hangXuat.filter { $0.colGroup.localizedCaseInsensitiveContains("HOMNAY") }
                            let xuatTuanNay = data.hangXuat.filter { $0.colGroup.localizedCaseInsensitiveContains("TUANNAY") }
                            
                            return VStack(alignment: .leading, spacing: 14) {
                                
                                // Bảng Phân bố nhân sự
                                if showNhanVienStats && hasNHANVIENPermission {
                                    if !data.nhanVienPhongBan.isEmpty || !data.nhanVienInOut.isEmpty {
                                        homeCardContainer(title: "Phân bố nhân sự") {
                                            VStack(spacing: 12) {
                                                kpiGrid(data: data)
                                                hrCustomTable(data: data)
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            router.showScreen(.push) { _ in
                                                NhanVienListView()
                                            }
                                        }
                                    }
                                }
                                
                                // Các chuyến hàng hôm nay
                                if hasXEPermission {
                                    let filteredChuyenXe = data.hangHoaChuyenXe.filter({ $0.colType.localizedCaseInsensitiveContains("HOMNAY") })
                                    if !filteredChuyenXe.isEmpty {
                                        homeCardContainer(title: "Các chuyến hàng hôm nay") {
                                            transportCustomTable(filteredList: filteredChuyenXe)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.todayRange
                                            router.showScreen(.push) { _ in
                                                TruyVanChuyenXeView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        emptySectionPill(title: "Các chuyến hàng hôm nay") {
                                            let range = Date.todayRange
                                            router.showScreen(.push) { _ in
                                                TruyVanChuyenXeView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    }
                                }
                                
                                // Hàng nhận hôm nay / tuần này
                                if hasNHAPPermission {
                                    if showNhapHomNay {
                                        if !nhapHomNay.isEmpty {
                                            homeCardContainer(title: "Hàng nhận hôm nay") {
                                                importCustomTable(list: nhapHomNay)
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                let range = Date.todayRange
                                                router.showScreen(.push) { _ in
                                                    TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        } else {
                                            emptySectionPill(title: "Hàng nhận hôm nay") {
                                                let range = Date.todayRange
                                                router.showScreen(.push) { _ in
                                                    TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        }
                                    }
                                    
                                    if showNhapTuanNay {
                                        if !nhapTuanNay.isEmpty {
                                            homeCardContainer(title: "Hàng nhận tuần này") {
                                                importCustomTable(list: nhapTuanNay)
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                let range = Date.getWeekRange(offsetWeeks: 0)
                                                router.showScreen(.push) { _ in
                                                    TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        } else {
                                            emptySectionPill(title: "Hàng nhận tuần này") {
                                                let range = Date.getWeekRange(offsetWeeks: 0)
                                                router.showScreen(.push) { _ in
                                                    TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Hàng giao hôm nay / tuần này
                                if hasXUATPermission {
                                    if showXuatHomNay {
                                        if !xuatHomNay.isEmpty {
                                            homeCardContainer(title: "Hàng giao hôm nay") {
                                                exportCustomTable(list: xuatHomNay)
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                let range = Date.todayRange
                                                router.showScreen(.push) { _ in
                                                    TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        } else {
                                            emptySectionPill(title: "Hàng giao hôm nay") {
                                                let range = Date.todayRange
                                                router.showScreen(.push) { _ in
                                                    TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        }
                                    }
                                    
                                    if showXuatTuanNay {
                                        if !xuatTuanNay.isEmpty {
                                            homeCardContainer(title: "Hàng giao tuần này") {
                                                exportCustomTable(list: xuatTuanNay)
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                let range = Date.getWeekRange(offsetWeeks: 0)
                                                router.showScreen(.push) { _ in
                                                    TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        } else {
                                            emptySectionPill(title: "Hàng giao tuần này") {
                                                let range = Date.getWeekRange(offsetWeeks: 0)
                                                router.showScreen(.push) { _ in
                                                    TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(VTSSpacing.sm)
                }
                .refreshable {
                    await viewModel.loadDashboardData()
                }
            }
        }
        .task {
            if !hasLoadedData {
                await viewModel.loadDashboardData()
                hasLoadedData = true
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Trang chủ",
            isWhiteText: true
        ) {
            EmptyView()
        } trailing: {
            EmptyView()
        } primaryAction: {
            EmptyView()
        }
    }
    
    // MARK: - Subviews & Custom Card/Table Builders
    
    @ViewBuilder
    private func homeCardContainer<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "0F2D59"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)
            
            content()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
    
    @ViewBuilder
    private func emptySectionPill(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "0F2D59"))
                Spacer()
            }
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func kpiGrid(data: HomeDashboardData) -> some View {
        VStack(spacing: VTSSpacing.xs) {
            ForEach(data.nhanVienInOut) { item in
                HStack {
                    Text(item.colName)
                        .font(.vtsBody)
                        .foregroundColor(.vtsTxtPrimary)
                    Spacer()
                    Text(item.colValue.toFormattedString(maxDecimals: 0))
                        .font(.vtsBody.bold())
                        .foregroundColor(.vtsPrimary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func transportCustomTable(filteredList: [THangHoa_ChuyenXeDataResult]) -> some View {
        VTSFlexibleTableContainer { containerW in
            let totalCol1 = filteredList.sum(by: \.colValue1)
            let totalCol2 = filteredList.sum(by: \.colValue2)
            let totalCol3 = filteredList.sum(by: \.colValue3)
            let totalCol4 = filteredList.sum(by: \.colValue4)
            
            let tableBorderColor = Color(hex: "C5D2E0")
            let headerBgColor = Color(hex: "E8EEF9")
            let headerTextColor = Color(hex: "0F2D59")
            
            let col1Width: CGFloat = max(24, containerW * 0.08)
            let colXeWidth: CGFloat = max(40, containerW * 0.15)
            let colQtyWidth: CGFloat = max(52, containerW * 0.21)
            
            VStack(spacing: 0) {
                // Multi-level Header
                HStack(spacing: 0) {
                    Text("#")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .frame(width: col1Width, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Hàng hóa")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    // Group "Nhận"
                    VStack(spacing: 0) {
                        Text("Nhận")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(headerTextColor)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                            .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                        
                        HStack(spacing: 0) {
                            Text("Xe")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.vertical, 4)
                                .frame(width: colXeWidth, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text("Số lượng")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.vertical, 4)
                                .frame(width: colQtyWidth, alignment: .center)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    // Group "Giao"
                    VStack(spacing: 0) {
                        Text("Giao")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(headerTextColor)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                            .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                        
                        HStack(spacing: 0) {
                            Text("Xe")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.vertical, 4)
                                .frame(width: colXeWidth, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text("Số lượng")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.vertical, 4)
                                .frame(width: colQtyWidth, alignment: .center)
                                .frame(maxHeight: .infinity)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                
                // Data Rows
                ForEach(Array(filteredList.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 0) {
                        Text("\(index + 1)")
                            .font(.system(size: 13))
                            .foregroundColor(headerTextColor)
                            .frame(width: col1Width, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colName ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colValue1.toFormattedString(maxDecimals: 2))
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 4)
                            .frame(width: colXeWidth, alignment: .trailing)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colValue2.toFormattedString(maxDecimals: 2))
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 4)
                            .frame(width: colQtyWidth, alignment: .trailing)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colValue3.toFormattedString(maxDecimals: 2))
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 4)
                            .frame(width: colXeWidth, alignment: .trailing)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colValue4.toFormattedString(maxDecimals: 2))
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 4)
                            .frame(width: colQtyWidth, alignment: .trailing)
                            .frame(maxHeight: .infinity)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color.white)
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                }
                
                // Summary Row ("Cộng")
                HStack(spacing: 0) {
                    Text(" ")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.vertical, 7)
                        .frame(width: col1Width, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Cộng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalCol1.toFormattedString(maxDecimals: 2))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .frame(width: colXeWidth, alignment: .trailing)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalCol2.toFormattedString(maxDecimals: 2))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .frame(width: colQtyWidth, alignment: .trailing)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalCol3.toFormattedString(maxDecimals: 2))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .frame(width: colXeWidth, alignment: .trailing)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalCol4.toFormattedString(maxDecimals: 2))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .frame(width: colQtyWidth, alignment: .trailing)
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
            }
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(tableBorderColor, lineWidth: 0.5)
            )
        }
    }
    
    @ViewBuilder
    private func importCustomTable(list: [THangNhapDataResult]) -> some View {
        VTSFlexibleTableContainer { containerW in
            let totalQty = list.filter { $0.colDataType == 0 }.sum(by: \.colValue)
            let tableBorderColor = Color(hex: "C5D2E0")
            let headerBgColor = Color(hex: "E8EEF9")
            let headerTextColor = Color(hex: "0F2D59")
            let subtotalBgColor = Color(hex: "C8E6C9") // Green tint
            
            let col1Width: CGFloat = max(26, containerW * 0.09)
            let col3Width: CGFloat = max(75, containerW * 0.26)
            
            VStack(spacing: 0) {
                // Header Row
                HStack(spacing: 0) {
                    Text("#")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .frame(width: col1Width, alignment: .center)
                        .padding(.vertical, 7)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Khách hàng / Hàng hóa")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Số lượng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 7)
                        .frame(width: col3Width, alignment: .center)
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                
                // Data Rows
                ForEach(list) { item in
                    if item.colDataType == 0 {
                        HStack(spacing: 0) {
                            Text("\(item.colOrder)")
                                .font(.system(size: 13))
                                .foregroundColor(headerTextColor)
                                .frame(width: col1Width, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colName ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "0F2D59"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 7)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colValue.toFormattedString(maxDecimals: 0))
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "0F2D59"))
                                .padding(.horizontal, 6)
                                .frame(width: col3Width, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .background(Color.white)
                        .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                    } else if item.colDataType == 1 {
                        HStack(spacing: 0) {
                            Text(" ")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.vertical, 7)
                                .frame(width: col1Width, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colName ?? "")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 7)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colValue.toFormattedString(maxDecimals: 0))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 6)
                                .frame(width: col3Width, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .background(subtotalBgColor)
                        .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                    }
                }
                
                // Summary Row ("Cộng")
                HStack(spacing: 0) {
                    Text(" ")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.vertical, 7)
                        .frame(width: col1Width, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Cộng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalQty.toFormattedString(maxDecimals: 0))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 6)
                        .frame(width: col3Width, alignment: .trailing)
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
            }
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(tableBorderColor, lineWidth: 0.5)
            )
        }
    }
    
    @ViewBuilder
    private func exportCustomTable(list: [THangXuatDataResult]) -> some View {
        VTSFlexibleTableContainer { containerW in
            let totalQty = list.filter { $0.colDataType == 0 }.sum(by: \.colValue)
            let tableBorderColor = Color(hex: "C5D2E0")
            let headerBgColor = Color(hex: "E8EEF9")
            let headerTextColor = Color(hex: "0F2D59")
            let subtotalBgColor = Color(hex: "C8E6C9") // Green tint
            
            let col1Width: CGFloat = max(26, containerW * 0.09)
            let col3Width: CGFloat = max(75, containerW * 0.26)
            
            VStack(spacing: 0) {
                // Header Row
                HStack(spacing: 0) {
                    Text("#")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .frame(width: col1Width, alignment: .center)
                        .padding(.vertical, 7)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Khách hàng / Hàng hóa")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Số lượng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 7)
                        .frame(width: col3Width, alignment: .center)
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                
                // Data Rows
                ForEach(list) { item in
                    if item.colDataType == 0 {
                        HStack(spacing: 0) {
                            Text("\(item.colOrder)")
                                .font(.system(size: 13))
                                .foregroundColor(headerTextColor)
                                .frame(width: col1Width, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colName ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "0F2D59"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 7)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colValue.toFormattedString(maxDecimals: 0))
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "0F2D59"))
                                .padding(.horizontal, 6)
                                .frame(width: col3Width, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .background(Color.white)
                        .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                    } else if item.colDataType == 1 {
                        HStack(spacing: 0) {
                            Text(" ")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.vertical, 7)
                                .frame(width: col1Width, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colName ?? "")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 7)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                            
                            Text(item.colValue.toFormattedString(maxDecimals: 0))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 6)
                                .frame(width: col3Width, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .background(subtotalBgColor)
                        .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                    }
                }
                
                // Summary Row ("Cộng")
                HStack(spacing: 0) {
                    Text(" ")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.vertical, 7)
                        .frame(width: col1Width, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Cộng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalQty.toFormattedString(maxDecimals: 0))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 6)
                        .frame(width: col3Width, alignment: .trailing)
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
            }
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(tableBorderColor, lineWidth: 0.5)
            )
        }
    }
    
    @ViewBuilder
    private func hrCustomTable(data: HomeDashboardData) -> some View {
        VTSFlexibleTableContainer { containerW in
            let totalVal = data.nhanVienPhongBan.sum(by: \.colValue)
            let totalVal0 = data.nhanVienPhongBan.sum(by: \.colValue0)
            let totalVal1 = data.nhanVienPhongBan.sum(by: \.colValue1)
            
            let tableBorderColor = Color(hex: "C5D2E0")
            let headerBgColor = Color(hex: "E8EEF9")
            let headerTextColor = Color(hex: "0F2D59")
            
            let col1Width: CGFloat = max(24, containerW * 0.08)
            let colValWidth: CGFloat = max(45, containerW * 0.16)
            
            VStack(spacing: 0) {
                // Header Row
                HStack(spacing: 0) {
                    Text("#")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .frame(width: col1Width, alignment: .center)
                        .padding(.vertical, 7)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Phòng ban")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.leading, 6)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Tổng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 7)
                        .frame(width: colValWidth, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Vắng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "D32F2F"))
                        .padding(.horizontal, 2)
                        .padding(.vertical, 7)
                        .frame(width: colValWidth, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Đi làm")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 7)
                        .frame(width: colValWidth, alignment: .center)
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                
                // Data Rows
                ForEach(Array(data.nhanVienPhongBan.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 0) {
                        Text("\(index + 1)")
                            .font(.system(size: 13))
                            .foregroundColor(headerTextColor)
                            .frame(width: col1Width, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colName ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colValue.toFormattedString(maxDecimals: 0))
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 2)
                            .frame(width: colValWidth, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colValue0.toFormattedString(maxDecimals: 0))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "D32F2F"))
                            .padding(.horizontal, 2)
                            .frame(width: colValWidth, alignment: .center)
                            .frame(maxHeight: .infinity)
                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                        
                        Text(item.colValue1.toFormattedString(maxDecimals: 0))
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .padding(.horizontal, 2)
                            .frame(width: colValWidth, alignment: .center)
                            .frame(maxHeight: .infinity)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color.white)
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                }
                
                // Summary Row ("Cộng")
                HStack(spacing: 0) {
                    Text(" ")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.vertical, 7)
                        .frame(width: col1Width, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text("Cộng")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalVal.toFormattedString(maxDecimals: 0))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 2)
                        .frame(width: colValWidth, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalVal0.toFormattedString(maxDecimals: 0))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "D32F2F"))
                        .padding(.horizontal, 2)
                        .frame(width: colValWidth, alignment: .center)
                        .frame(maxHeight: .infinity)
                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                    
                    Text(totalVal1.toFormattedString(maxDecimals: 0))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(headerTextColor)
                        .padding(.horizontal, 2)
                        .frame(width: colValWidth, alignment: .center)
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(headerBgColor)
            }
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(tableBorderColor, lineWidth: 0.5)
            )
        }
    }
}

// MARK: - VTSFlexibleTableContainer
struct VTSFlexibleTableContainer<Content: View>: View {
    @State private var containerWidth: CGFloat = 0
    @ViewBuilder let content: (CGFloat) -> Content

    var body: some View {
        let width = containerWidth > 0 ? containerWidth : (UIScreen.main.bounds.width - 56)
        content(width)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: VTSContainerWidthKey.self, value: geo.size.width)
                }
            )
            .onPreferenceChange(VTSContainerWidthKey.self) { newWidth in
                if newWidth > 0 && containerWidth != newWidth {
                    containerWidth = newWidth
                }
            }
    }
}

private struct VTSContainerWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeView()
}
