//
//  ThongBaoView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 13/08/2026.
//

import SwiftUI
import SwiftfulRouting

struct ThongBaoView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let toolbarTitle = "Thông báo"
        static let searchPlaceholder = "Nhập nội dung để tìm"
        static let emptyTitle = "Không có thông báo nào"
        static let emptySubtitle = "Bạn chưa nhận được thông báo trong khoảng thời gian này."
        static let emptyIcon = "bell.slash"
    }

    @Environment(\.router) private var router
    @StateObject private var viewModel = ThongBaoViewModel()
    
    @State private var isSearchVisible: Bool = false
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                // MARK: - Header & Standard System Date Filter Bar
                VStack(spacing: 0) {
                    if isSearchVisible {
                        VTSSearchBar(
                            text: $viewModel.searchText,
                            placeholder: Strings.searchPlaceholder,
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isSearchVisible = false
                                }
                            }
                        )
                        .padding(.horizontal, VTSSpacing.xl)
                    .padding(.top, 4)
                    .padding(.bottom, 2)
                        .background(Color.vtsPrimary)
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
                    emptyTitle: Strings.emptyTitle,
                    emptySubtitle: Strings.emptySubtitle,
                    emptyIcon: Strings.emptyIcon,
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
            subtitle: Strings.toolbarTitle,
            isWhiteText: true,
            leading: {},
            trailing: {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearchVisible.toggle()
                    }
                } label: {
                    LucideIcon(isSearchVisible ? .x : .search, size: 20, color: .white)
                }
            },
            primaryAction: {
                EmptyView()
            }
        )
        .task {
            await viewModel.loadNotifications()
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
        let text = ((item.tieuDe ?? "") + " " + (item.noiDung ?? "")).lowercased()
        return text.contains("xóa") || text.contains("xoa")
    }
    
    private var iconAssetName: String {
        let text = ((item.tieuDe ?? "") + " " + (item.noiDung ?? "")).uppercased()
        if text.contains("PGC.") || text.contains("GIA CÔNG") {
            return "lucide_settings_arrow"
        } else if text.contains("PX.") || text.contains("XUẤT") {
            return "lucide_truck"
        } else if text.contains("PN.") || text.contains("NHẬP") {
            return "lucide_factory"
        }
        return "lucide_bell"
    }
    
    private var titleColor: Color {
        isDeleteNotification ? Color(hex: "DC2626") : Color.vtsPrimary
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                // Header: Icon + Title
                HStack(spacing: 8) {
                    Image(iconAssetName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.vtsPrimary)
                    
                    if let tieuDe = item.tieuDe, !tieuDe.isEmpty {
                        Text(tieuDe)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(titleColor)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if item.daDoc != true {
                        Circle()
                            .fill(Color.vtsPrimary)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Content Body
                if let noiDung = item.noiDung, !noiDung.isEmpty {
                    Text(noiDung)
                        .font(.system(size: 13.5, weight: .regular))
                        .foregroundColor(Color(hex: "1E293B"))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "E2E8F0"), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ThongBaoView()
}
