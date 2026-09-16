//
//  KhachHangListView.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct KhachHangListView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let searchPlaceholder = "Nhập nội dung để tìm"
        static let emptyTitle = "Không tìm thấy khách hàng"
        static let emptySubtitle = "Vui lòng kiểm tra lại kết nối hoặc thử lại."
        static let noResultTitle = "Không tìm thấy kết quả"
        static let noResultSubtitle = "Vui lòng nhập từ khóa khác"
        static let colIndex = "#"
        static let colTen = "Tên"
        static let colDiaChi = "Địa chỉ"
        static let subtitle = "Khách hàng"
        static func totalCount(_ count: Int) -> String { "Tổng cộng: \(count)" }
        static let viewDetail = "Xem chi tiết"
        static let deleteKhachHang = "Xóa khách hàng"
        static let deleteConfirmTitle = "Xác nhận xóa"
        static func deleteConfirmSubtitle(_ ten: String, _ ma: String) -> String { "Bạn có chắc chắn muốn xóa khách hàng \(ten) (\(ma))?" }
        static let deleteBtn = "Xóa"
        static let cancelBtn = "Hủy"
        static let errorTitle = "Lỗi"
        static let okBtn = "OK"
        static func subtitleModal(_ ma: String, _ diaChi: String?) -> String {
            "Mã: \(ma)" + (diaChi != nil && !diaChi!.isEmpty ? " • \(diaChi!)" : "")
        }
    }

    @Environment(\.router) private var router
    @StateObject private var viewModel = KhachHangListViewModel()
    @State private var showSearchBar = false
    @State private var hasLoadedData = false
    @State private var selectedModalItem: TKhachhang_TDanhSach? = nil
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                if showSearchBar {
                    VTSSearchBar(
                        text: $viewModel.searchText,
                        placeholder: Strings.searchPlaceholder,
                        onClose: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showSearchBar = false
                            }
                        }
                    )
                    .padding(.horizontal, VTSSpacing.xl)
                    .padding(.top, 4)
                    .padding(.bottom, 2)
                    .background(Color.vtsPrimary)
                }
                
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: Strings.emptyTitle,
                    emptySubtitle: Strings.emptySubtitle,
                    emptyIcon: "building.2.fill",
                    retry: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                ) { _ in
                    let filtered = viewModel.filteredKhachHang
                    
                    VStack(spacing: 0) {
                        if filtered.isEmpty {
                            Spacer()
                            VTSEmptyState(
                                icon: "doc.text.magnifyingglass",
                                title: Strings.noResultTitle,
                                subtitle: Strings.noResultSubtitle
                            )
                            Spacer()
                        } else {
                            ERPTable(
                                dataSource: filtered,
                                columns: [
                                    ERPColumn(
                                        title: AnyView(Text(Strings.colIndex)),
                                        key: "index",
                                        width: 0.1,
                                        alignment: .center,
                                        render: { _, index in
                                            AnyView(
                                                Text(String(index + 1))
                                            )
                                        }
                                    ),
                                    
                                    ERPColumn(
                                        title: AnyView(Text(Strings.colTen)),
                                        key: "ten",
                                        width: 0.45,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.ten)
                                            )
                                        },
                                        sorter: { $0.ten.localizedCompare($1.ten) == .orderedAscending }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text(Strings.colDiaChi)),
                                        key: "diaChi",
                                        width: 0.45,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.diaChi ?? "")
                                            )
                                        },
                                        sorter: { ($0.diaChi ?? "").localizedCompare($1.diaChi ?? "") == .orderedAscending }
                                    )
                                ],
                                defaultSortKey: "ten",
                                onRowLongPress: { row in
                                    let perm = AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_KHACHHANG")
                                    if perm?.del != true && (perm?.view == true || perm == nil) {
                                        router.showScreen(.push) { _ in
                                            KhachHangDetailView(maKH: row.ma, isEditMode: false)
                                        }
                                    } else {
                                        selectedModalItem = row
                                    }
                                },
                                onRowAction: { action, row in
                                    handleRowAction(action, row: row)
                                },
                                actions: {
                                    var list: [VTSRowAction] = []
                                    let perm = AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_KHACHHANG")
                                    if perm?.view == true { list.append(.xem) }
                                    if perm?.del == true { list.append(.xoa) }
                                    return list
                                }(),
                                loadDataIfNeeded: {
                                    Task {
                                        await viewModel.loadDataIfNeeded()
                                    }
                                },
                                onRefresh: {
                                    Task {
                                        await viewModel.loadData()
                                    }
                                },
                                backgroundPreferenceValue: Color.vtsPrimary,
                                customFooterBuilder: { width in
                                    AnyView(Text(Strings.totalCount(viewModel.filteredKhachHang.count))
                                        .font(.system(size: 12, weight: .bold))
                                        .padding(.vertical, 6)
                                        .foregroundColor(Color.vtsBg)
                                        .frame(width: width * 1, alignment: .center)
                                        .background(Color.vtsPrimary))
                                    
                                },
                                rowHeight: nil,
                                disableVerticalScrolling: false,
                                showCompanyFooter: true
                            )
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(item: $selectedModalItem) { item in
            VTSActionModalSheet(
                title: item.ten,
                subtitle: Strings.subtitleModal(item.ma, item.diaChi),
                actions: {
                    var acts: [VTSModalAction] = []
                    let perm = AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_KHACHHANG")
                    if perm?.view == true || perm == nil {
                        acts.append(VTSModalAction(title: Strings.viewDetail, icon: "eye.fill") {
                            router.showScreen(.push) { _ in
                                KhachHangDetailView(maKH: item.ma, isEditMode: false)
                            }
                        })
                    }
                    if perm?.del == true {
                        acts.append(VTSModalAction(title: Strings.deleteKhachHang, icon: "trash.fill", isDestructive: true) {
                            handleRowAction(.xoa, row: item)
                        })
                    }
                    return acts
                }(),
                onClose: {
                    selectedModalItem = nil
                }
            )
            .presentationDetents([.fraction(AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_KHACHHANG")?.del == true ? 0.38 : 0.3), .medium])
            .presentationDragIndicator(.visible)
        }
        .task {
            if !hasLoadedData {
                await viewModel.loadData()
                hasLoadedData = true
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: Strings.subtitle,
            isWhiteText: true,
            leading: {},
            trailing: {
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.easeInOut) {
                            showSearchBar.toggle()
                        }
                    } label: {
                        LucideIcon(showSearchBar ? .x : .search, size: 20, color: .white)
                    }
                    
                    if AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_KHACHHANG")?.add == true {
                        Button {
                            router.showScreen(.push) { _ in
                                KhachHangDetailView(maKH: nil)
                            }
                        } label: {
                            LucideIcon(.plus, size: 18)
                                .font(.title3)
                                .foregroundColor(.white)
                                .symbolEffect(.bounce, value: showSearchBar)
                        }
                    }
                }
            },
            primaryAction: {
                EmptyView()
            }
        )
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func handleRowAction(_ action: VTSRowAction, row: TKhachhang_TDanhSach) {
        switch action {
        case .xem:
            router.showScreen(.push) { _ in
                KhachHangDetailView(maKH: row.ma, isEditMode: false)
            }
        case .sua:
            router.showScreen(.push) { _ in
                KhachHangDetailView(maKH: row.ma, isEditMode: true)
            }
        case .xoa:
            router.showAlert(.alert, title: Strings.deleteConfirmTitle, subtitle: Strings.deleteConfirmSubtitle(row.ten, row.ma)) {
                Button(Strings.cancelBtn, role: .cancel) {}
                Button(Strings.deleteBtn, role: .destructive) {
                    Task {
                        do {
                            let _ = try await KhachHangService.shared.xoa(ma: row.ma)
                            await viewModel.loadData()
                        } catch {
                            router.showAlert(.alert, title: Strings.errorTitle, subtitle: error.localizedDescription) {
                                Button(Strings.okBtn) {}
                            }
                        }
                    }
                }
            }
        default:
            break
        }
    }
}

#Preview {
    RouterView { _ in
        KhachHangListView()
    }
}
