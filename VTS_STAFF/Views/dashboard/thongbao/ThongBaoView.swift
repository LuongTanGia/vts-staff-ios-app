//
//  ThongBaoView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 13/08/2026.
//

import SwiftUI
import SwiftfulRouting

struct ThongBaoView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = ThongBaoViewModel()
    
    @State private var isSearchVisible: Bool = false
    @State private var showSettingsSheet: Bool = false
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                // MARK: - Header & Standard System Date Filter Bar
                VStack(spacing: 0) {
                    if isSearchVisible {
                        VTSSearchBar(text: $viewModel.searchText, placeholder: "Tìm kiếm thông báo...")
                            .padding(.horizontal, VTSSpacing.xl)
                            .padding(.top, VTSSpacing.md)
                            .padding(.bottom, VTSSpacing.md)
                    }
                    
                    HStack(spacing: 8) {
                        SystemDateFilterHeader(
                            fromDate: $viewModel.tuNgay,
                            toDate: $viewModel.denNgay,
                            onChanged: {
                                Task {
                                    await viewModel.loadNotifications()
                                }
                            }
                        )
                        
                        
                    }
                    .padding(.horizontal, VTSSpacing.xl)
                    .background(Color.vtsPrimary)
                }
               
                // MARK: - Notification List Content
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: "Không có thông báo nào",
                    emptySubtitle: "Bạn chưa nhận được thông báo trong khoảng thời gian này.",
                    emptyIcon: "bell.slash",
                    retry: {
                        Task {
                            await viewModel.loadNotifications()
                        }
                    }
                ) { items in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredNotifications) { item in
                                ThongBaoCard(item: item) {
                                    Task {
                                        await viewModel.markAsRead(ma: item.ma)
                                        navigateToList(for: item)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .refreshable {
                        await viewModel.loadNotifications()
                    }
                }
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Thông báo",
            isWhiteText: !isSearchVisible,
            leading: {},
           
            trailing: {
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.easeInOut) {
                            isSearchVisible.toggle()
                        }
                    } label: {
                        Image(systemName: isSearchVisible ? "magnifyingglass.circle.fill" : "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(isSearchVisible ? .primary : .white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    
                   
                }
            },
            primaryAction: {
                EmptyView()
            }
        )
        .task {
            await viewModel.loadNotifications()
        }
        .sheet(isPresented: $showSettingsSheet) {
            ThongBaoSettingsSheet(viewModel: viewModel)
                .environment(\.colorScheme, .light)
        }
    }
    
    // MARK: - Navigation to Voucher List View
    private func navigateToList(for item: TThongBao_DanhSach) {
        guard let target = viewModel.parseVoucherTarget(from: item) else { return }
        
        switch target.type {
        case .nhap:
            router.showScreen(.push) { _ in
                PhieuNhapListView(fromDate: target.fromDate, toDate: target.toDate, searchText: target.soPhieu)
            }
        case .xuat:
            router.showScreen(.push) { _ in
                PhieuXuatListView(fromDate: target.fromDate, toDate: target.toDate, searchText: target.soPhieu)
            }
        case .giacong:
            router.showScreen(.push) { _ in
                PhieuGiaCongListView(fromDate: target.fromDate, toDate: target.toDate, searchText: target.soPhieu)
            }
        }
    }
}

// MARK: - Notification Item Card View
struct ThongBaoCard: View {
    let item: TThongBao_DanhSach
    let onTap: () -> Void
    
    private var isDeleteNotification: Bool {
        let text = (item.tieuDe ?? "") + (item.noiDung ?? "")
        return text.lowercased().contains("xóa") || text.lowercased().contains("xoa")
    }
    
    private var iconName: String {
        let text = (item.tieuDe ?? "") + (item.noiDung ?? "")
        if text.contains("PGC.") || text.lowercased().contains("gia công") {
            return "gearshape.fill"
        } else if text.contains("PX.") || text.lowercased().contains("xuất") {
            return "truck.box.fill"
        } else if text.contains("PN.") || text.lowercased().contains("nhập") {
            return "building.2.crop.circle.fill"
        }
        return "bell.fill"
    }
    
    private var accentColor: Color {
        isDeleteNotification ? Color(hex: "DC2626") : Color(hex: "004B87")
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                // Icon Header Box
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 36, height: 36)
                    .background(accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 6) {
                    // Title Header (Blue or Red)
                    if let tieuDe = item.tieuDe, !tieuDe.isEmpty {
                        Text(tieuDe)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(accentColor)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Description Body
                    if let noiDung = item.noiDung, !noiDung.isEmpty {
                        Text(noiDung)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "0F2D59"))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(3)
                    }
                    
                    // Date Timestamp
                    if let ngay = item.ngay, !ngay.isEmpty {
                        HStack {
                            Spacer()
                            Text(ngay.toDisplayDate())
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "64748B"))
                        }
                        .padding(.top, 2)
                    }
                }
                
                // Unread Indicator Dot
                if item.daDoc != true {
                    Circle()
                        .fill(Color(hex: "004B87"))
                        .frame(width: 9, height: 9)
                        .padding(.top, 4)
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(item.daDoc == true ? Color(hex: "E2E8F0") : Color(hex: "93C5FD"), lineWidth: item.daDoc == true ? 1 : 1.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notification Settings & Actions Sheet
struct ThongBaoSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ThongBaoViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Quick Action Card
                VTSLiquidFormCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Thao tác nhanh")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "0F2D59"))
                        
                        Button {
                            Task {
                                await viewModel.markAllAsRead()
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "004B87"))
                                Text("Đánh dấu đọc tất cả thông báo")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "0F2D59"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                // Toggle Settings Card
                VTSLiquidFormCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Cài đặt nhận thông báo")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "0F2D59"))
                        
                        Toggle(isOn: Binding(
                            get: { viewModel.isMsgTaoPhieuEnabled },
                            set: { val in
                                Task { await viewModel.toggleMsgTaoPhieu(enabled: val) }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Thông báo khi tạo phiếu mới")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "0F2D59"))
                                Text("Nhận tin báo khi có phiếu nhập, xuất, gia công mới")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "64748B"))
                            }
                        }
                        .tint(Color(hex: "004B87"))
                        
                        Divider()
                        
                        Toggle(isOn: Binding(
                            get: { viewModel.isMsgXoaPhieuEnabled },
                            set: { val in
                                Task { await viewModel.toggleMsgXoaPhieu(enabled: val) }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Thông báo khi xóa phiếu")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "0F2D59"))
                                Text("Nhận tin báo khi có thao tác xóa phiếu vận chuyển")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "64748B"))
                            }
                        }
                        .tint(Color(hex: "004B87"))
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(hex: "F8FAFC").ignoresSafeArea())
            .navigationTitle("Tùy chọn thông báo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "004B87"))
                }
            }
        }
        .task {
            await viewModel.loadNotificationSettings()
        }
    }
}

#Preview {
    ThongBaoView()
}
