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
    
    @AppStorage("vts_show_nhap_homnay") private var showNhapHomNay = true
    @AppStorage("vts_show_nhap_tuannay") private var showNhapTuanNay = false
    @AppStorage("vts_show_nhap_tuantruoc") private var showNhapTuanTruoc = false
    
    @AppStorage("vts_show_xuat_homnay") private var showXuatHomNay = true
    @AppStorage("vts_show_xuat_tuannay") private var showXuatTuanNay = false
    @AppStorage("vts_show_xuat_tuantruoc") private var showXuatTuanTruoc = false
    
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
        VTSPageContainer {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: VTSSpacing.sm) {
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
                            let nhapTuanTruoc = data.hangNhap.filter { $0.colGroup.localizedCaseInsensitiveContains("TUANTRUOC") }
                            
                            let xuatHomNay = data.hangXuat.filter { $0.colGroup.localizedCaseInsensitiveContains("HOMNAY") }
                            let xuatTuanNay = data.hangXuat.filter { $0.colGroup.localizedCaseInsensitiveContains("TUANNAY") }
                            let xuatTuanTruoc = data.hangXuat.filter { $0.colGroup.localizedCaseInsensitiveContains("TUANTRUOC") }
                            
                            return VStack(alignment: .leading) {
                                
                                if hasNHANVIENPermission {
                                    if !data.nhanVienPhongBan.isEmpty || !data.nhanVienInOut.isEmpty {
                                        VTSGlassCard {
                                            // 6. Bảng Nhân Sự
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Phân bố nhân sự")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                // 2. Grid of Stat Cards
                                                kpiGrid(data: data)
                                                
                                                hrTable(data: data)
                                                    .id("hr_distribution_table")
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
                                
                                if hasXEPermission {
                                    if !data.hangHoaChuyenXe.filter({ $0.colType.localizedCaseInsensitiveContains("HOMNAY") }).isEmpty {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Các chuyến hàng hôm nay")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                transportTable(data: data)
                                                    .id("transport_comparison_table")
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.todayRange
                                            router.showScreen(.push) { _ in
                                                TruyVanChuyenXeView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Các chuyến hàng hôm nay")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                HStack {
                                                    Text("Không có chuyến hàng hôm nay")
                                                        .font(.vtsCallout)
                                                        .foregroundColor(.vtsTxtSecondary)
                                                    Spacer()
                                                    VTSButton("Truy vấn", icon: "magnifyingglass", style: .outline, size: .small) {
                                                        let range = Date.todayRange
                                                        router.showScreen(.push) { _ in
                                                            TruyVanChuyenXeView(fromDate: range.from, toDate: range.to)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if hasNHAPPermission {
                                    if showNhapHomNay {
                                        if !nhapHomNay.isEmpty {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng nhận hôm nay")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                importTable(list: nhapHomNay)
                                                    .id("import_cargo_table_homnay")
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.todayRange
                                            router.showScreen(.push) { _ in
                                                TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng nhận hôm nay")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                HStack {
                                                    Text("Không có hàng nhận hôm nay")
                                                        .font(.vtsCallout)
                                                        .foregroundColor(.vtsTxtSecondary)
                                                    Spacer()
                                                    VTSButton("Truy vấn", icon: "magnifyingglass", style: .outline, size: .small) {
                                                        let range = Date.todayRange
                                                        router.showScreen(.push) { _ in
                                                            TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if showNhapTuanNay {
                                    if !nhapTuanNay.isEmpty {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng nhận tuần này")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                importTable(list: nhapTuanNay)
                                                    .id("import_cargo_table_tuannay")
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.getWeekRange(offsetWeeks: 0)
                                            router.showScreen(.push) { _ in
                                                TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng nhận tuần này")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                HStack {
                                                    Text("Không có hàng nhận tuần này")
                                                        .font(.vtsCallout)
                                                        .foregroundColor(.vtsTxtSecondary)
                                                    Spacer()
                                                    VTSButton("Truy vấn", icon: "magnifyingglass", style: .outline, size: .small) {
                                                        let range = Date.getWeekRange(offsetWeeks: 0)
                                                        router.showScreen(.push) { _ in
                                                            TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if showNhapTuanTruoc {
                                    if !nhapTuanTruoc.isEmpty {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng nhận tuần trước")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                importTable(list: nhapTuanTruoc)
                                                    .id("import_cargo_table_tuantruoc")
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.getWeekRange(offsetWeeks: -1)
                                            router.showScreen(.push) { _ in
                                                TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng nhận tuần trước")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                HStack {
                                                    Text("Không có hàng nhận tuần trước")
                                                        .font(.vtsCallout)
                                                        .foregroundColor(.vtsTxtSecondary)
                                                    Spacer()
                                                    VTSButton("Truy vấn", icon: "magnifyingglass", style: .outline, size: .small) {
                                                        let range = Date.getWeekRange(offsetWeeks: -1)
                                                        router.showScreen(.push) { _ in
                                                            TruyVanNhapView(fromDate: range.from, toDate: range.to)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                }
                                
                                if hasXUATPermission {
                                    if showXuatHomNay {
                                        if !xuatHomNay.isEmpty {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng giao hôm nay")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                exportTable(list: xuatHomNay)
                                                    .id("export_cargo_table_homnay")
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.todayRange
                                            router.showScreen(.push) { _ in
                                                TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng giao hôm nay")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                HStack {
                                                    Text("Không có hàng giao hôm nay")
                                                        .font(.vtsCallout)
                                                        .foregroundColor(.vtsTxtSecondary)
                                                    Spacer()
                                                    VTSButton("Truy vấn", icon: "magnifyingglass", style: .outline, size: .small) {
                                                        let range = Date.todayRange
                                                        router.showScreen(.push) { _ in
                                                            TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if showXuatTuanNay {
                                    if !xuatTuanNay.isEmpty {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng giao tuần này")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                exportTable(list: xuatTuanNay)
                                                    .id("export_cargo_table_tuannay")
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.getWeekRange(offsetWeeks: 0)
                                            router.showScreen(.push) { _ in
                                                TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng giao tuần này")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                HStack {
                                                    Text("Không có hàng giao tuần này")
                                                        .font(.vtsCallout)
                                                        .foregroundColor(.vtsTxtSecondary)
                                                    Spacer()
                                                    VTSButton("Truy vấn", icon: "magnifyingglass", style: .outline, size: .small) {
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
                                
                                if showXuatTuanTruoc {
                                    if !xuatTuanTruoc.isEmpty {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng giao tuần trước")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                exportTable(list: xuatTuanTruoc)
                                                    .id("export_cargo_table_tuantruoc")
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            let range = Date.getWeekRange(offsetWeeks: -1)
                                            router.showScreen(.push) { _ in
                                                TruyVanXuatView(fromDate: range.from, toDate: range.to)
                                            }
                                        }
                                    } else {
                                        VTSGlassCard {
                                            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                                                Text("Hàng giao tuần trước")
                                                    .font(.vtsCaption.bold())
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .tracking(1)
                                                
                                                HStack {
                                                    Text("Không có hàng giao tuần trước")
                                                        .font(.vtsCallout)
                                                        .foregroundColor(.vtsTxtSecondary)
                                                    Spacer()
                                                    VTSButton("Truy vấn", icon: "magnifyingglass", style: .outline, size: .small) {
                                                        let range = Date.getWeekRange(offsetWeeks: -1)
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
            subtitle: "Trang chủ"
        ) {
            EmptyView()
        } trailing: {
            EmptyView()
        } primaryAction: {
            EmptyView()
        }
    }
    
    // MARK: - Subviews & Builders
    
    @ViewBuilder
    private func kpiGrid(data: HomeDashboardData) -> some View {
        VStack(spacing: VTSSpacing.sm) {
            ForEach(data.nhanVienInOut) { item in
                HStack {
                    Text(item.colName)
                        .font(.vtsBody)
                        .foregroundColor(.vtsTxtPrimary)
                    Spacer()
                    Text("\(item.colValue)")
                        .font(.vtsBody.bold())
                        .foregroundColor(.vtsPrimary)
                }
               
            }
        }
    }
    @ViewBuilder
    private func transportTable(data: HomeDashboardData) -> some View {
        let filteredList = data.hangHoaChuyenXe.filter({ $0.colType.localizedCaseInsensitiveContains("HOMNAY") })
        let totalcolValue2 = filteredList.sum(by: \.colValue2)
        let totalcolValue4 = filteredList.sum(by: \.colValue4)
        
        ERPTable(
            dataSource: filteredList,
            columns: [
                ERPColumn(
                    title: AnyView(Text("#")),
                    key: "000",
                    width: 0.1,
                    alignment: .center,
                    render: { item, index in
                        AnyView(
                            Text(String(index + 1))
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    
                ),
                ERPColumn(
                    title: AnyView(Text("Hàng hoá")),
                    key: "colName",
                    width: 0.4,
                    alignment: .leading,
                    render: { item, _ in
                        AnyView(
                            Text(item.colName)
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    footer: AnyView(
                        Text("Tổng")
                            .frame(maxWidth: .infinity, alignment: .center)
                    )
                ),
                
                ERPColumn(
                    title: AnyView(
                        VStack(alignment: .center) {
                            Text("Nhận")
                            Divider()
                                .padding(0.5)
                                .background(Color.vtsBg)
                            Text("Số/ Trọng lượng")
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    ),
                    key: "colValue2",
                    width: 0.25,
                    alignment: .trailing,
                    render: { item, _ in
                        AnyView(
                            Text("\(item.colValue2)")
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    footer: AnyView(
                        Text("\(totalcolValue2)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                ),
                ERPColumn(
                    title: AnyView(
                        VStack {
                            Text("Giao")
                            Divider()
                                .padding(0.5)
                                .background(Color.vtsBg)
                            Text("Số/ Trọng lượng")
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    ),
                    key: "colValue4",
                    width: 0.25,
                    alignment: .trailing,
                    render: { item, _ in
                        AnyView(
                            Text("\(item.colValue4)")
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    footer: AnyView(
                        Text("\(totalcolValue4)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                )
            ],
            rowHeight: 30,
            disableVerticalScrolling: true
        )
    }
    
    @ViewBuilder
    private func importTable(list: [THangNhapDataResult]) -> some View {
        let totalcolValue = list.filter {
            $0.colDataType == 0
        }.sum(by: \.colValue)
        ERPTable(
            dataSource: list,
            
            columns: [
                ERPColumn(
                    title: AnyView(Text("#")),
                    key: "colCode",
                    width: 0.1,
                    alignment: .center,
                    render: { item, index in
                        AnyView(Text(""))
                    }
                ),
                ERPColumn(
                    title: AnyView(Text("Khách hàng / Hàng hoá")),
                    key: "colName",
                    width: 0.6,
                    alignment: .leading,
                    render: { item, index in
                        AnyView(Text(""))
                    },
                    footer: AnyView(
                        Text("Tổng")
                            .frame(maxWidth: .infinity, alignment: .center)
                    )
                ),
                ERPColumn(
                    title: AnyView(Text("Số/ Trọng lượng")),
                    key: "colValue",
                    width: 0.3,
                    alignment: .trailing,
                    render: { item, index in
                        AnyView(Text(""))
                    },
                    footer: AnyView(
                        Text("\(totalcolValue)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                )
            ],
            customRowBuilder: { item, width in
                
                if item.colDataType == 0 {
                    return AnyView(
                        
                        HStack(spacing: 0) {
                            
                            Text(String(item.colOrder))
                                .padding(5)
                                .frame(width: width * 0.1, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .border(Color.vtsBorder, width: 0.5)
                            Text(item.colName)
                                .padding(5)
                                .frame(width: width * 0.6, alignment: .leading)
                                .frame(maxHeight: .infinity)
                                .border(Color.vtsBorder, width: 0.5)
                            Text(item.colValue.toFormattedString(maxDecimals: 0))
                                .padding(5)
                                .frame(width: width * 0.3, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                                .border(Color.vtsBorder, width: 0.5)
                            
                            
                        }
                        .background(.white)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        
                    )
                }
                if item.colDataType == 1 {
                    return AnyView(
                        Text(item.colName)
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(.green.opacity(0.5))
                            .border(Color.vtsBorder, width: 0.5)
                    )
                    
                }
                return nil
            },
            //            rowHeight: 30,
            disableVerticalScrolling: true
        )
    }
    
    @ViewBuilder
    private func exportTable(list: [THangXuatDataResult]) -> some View {
        let totalcolValue = list.filter {
            $0.colDataType == 0
        }.sum(by: \.colValue)
        ERPTable(
            dataSource: list,
            columns: [
                ERPColumn(
                    title: AnyView(Text("#")),
                    key: "colCode",
                    width: 0.1,
                    alignment: .center,
                    render: { item, _ in
                        AnyView(
                            Text(item.colCode)
                                .foregroundColor(.vtsTxtSecondary)
                        )
                    }
                ),
                ERPColumn(
                    title: AnyView(Text("Khách hàng / Hàng hoá")),
                    key: "colName",
                    width: 0.6,
                    alignment: .leading,
                    render: { item, _ in
                        AnyView(
                            Text(item.colName)
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    footer: AnyView(
                        Text("Tổng")
                            .frame(maxWidth: .infinity, alignment: .center)
                    )
                ),
                ERPColumn(
                    title: AnyView(Text("Số/ Trọng lượng")),
                    key: "colValue",
                    width: 0.3,
                    alignment: .trailing,
                    render: { item, _ in
                        return AnyView(
                            Text("\(item.colValue) tấn")
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    footer: AnyView(
                        Text("\(totalcolValue)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                )
            ],
            customRowBuilder: { item, width in
                
                if item.colDataType == 0 {
                    return AnyView(
                        
                        HStack(spacing: 0) {
                            
                            Text(String(item.colOrder))
                                .padding(5)
                                .frame(width: width * 0.1, alignment: .center)
                                .frame(maxHeight: .infinity)
                                .border(Color.vtsBorder, width: 0.5)
                            Text(item.colName)
                                .padding(5)
                                .frame(width: width * 0.6, alignment: .leading)
                                .frame(maxHeight: .infinity)
                                .border(Color.vtsBorder, width: 0.5)
                            Text(item.colValue.toFormattedString(maxDecimals: 0))
                                .padding(5)
                                .frame(width: width * 0.3, alignment: .trailing)
                                .frame(maxHeight: .infinity)
                                .border(Color.vtsBorder, width: 0.5)
                            
                            
                        }
                        .background(.white)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        
                    )
                }
                if item.colDataType == 1 {
                    return AnyView(
                        Text(item.colName)
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(.green.opacity(0.5))
                            .border(Color.vtsBorder, width: 0.5)
                    )
                    
                }
                return nil
            },
            //            rowHeight: 30,
            disableVerticalScrolling: true
        )
    }
    
    @ViewBuilder
    private func hrTable(data: HomeDashboardData) -> some View {
        let totalcolValue = data.nhanVienPhongBan.sum(by: \.colValue)
        let totalcolValue0 = data.nhanVienPhongBan.sum(by: \.colValue0)
        let totalcolValue1 = data.nhanVienPhongBan.sum(by: \.colValue1)
        ERPTable(
            dataSource: data.nhanVienPhongBan,
            columns: [
                ERPColumn(
                    title: AnyView(Text("Phòng ban")),
                    key: "colName",
                    width: 0.4,
                    alignment: .leading,
                    render: { item, _ in
                        AnyView(
                            Text(item.colName)
                                .foregroundColor(.vtsTxtPrimary)
                            
                        )
                    },
                    footer: AnyView(
                        Text("Tổng")
                            .frame(maxWidth: .infinity, alignment: .center)
                    )
                ),
                ERPColumn(
                    title: AnyView(Text("Tổng")),
                    key: "colValue",
                    width: 0.2,
                    alignment: .trailing,
                    render: { item, _ in
                        AnyView(
                            Text("\(item.colValue)")
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    footer: AnyView(
                        Text("\(totalcolValue)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                ),
                ERPColumn(
                    title: AnyView(Text("Vắng")),
                    key: "colValue0",
                    width: 0.2,
                    alignment: .trailing,
                    render: { item, _ in
                        AnyView(
                            Text("\(item.colValue0)")
                                .foregroundColor(.red)
                        )
                    },
                    footer: AnyView(
                        Text("\(totalcolValue0)")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                ),
                ERPColumn(
                    title: AnyView(Text("Đi làm")),
                    key: "colValue1",
                    width: 0.2,
                    alignment: .trailing,
                    render: { item, _ in
                        AnyView(
                            Text("\(item.colValue1)")
                                .foregroundColor(.vtsTxtPrimary)
                        )
                    },
                    footer: AnyView(
                        Text("\(totalcolValue1)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                ),
                
            ],
            
            rowHeight: 30,
            disableVerticalScrolling: true
        )
    }
}

#Preview {
    HomeView()
}
