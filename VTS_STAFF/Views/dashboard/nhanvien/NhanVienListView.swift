//
//  NhanVienListView.swift
//  VTS_STAFF
//
//  Created by viettas on 25/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct NhanVienListView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = NhanVienListViewModel()
    @State private var showSearchBar = false
    @State private var hasLoadedData = false
    @State private var selectedModalItem: TNhanVien_DanhSach? = nil
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                                if showSearchBar {
                    VTSSearchBar(
                        text: $viewModel.searchText,
                        placeholder: "Nhập nội dung để tìm",
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
                
                //                     Content list or table
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: "Không tìm thấy nhân viên",
                    emptySubtitle: "Vui lòng kiểm tra lại kết nối hoặc thử lại.",
                    emptyIcon: "person.3.fill",
                    retry: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                ) { _ in
                    let filtered = viewModel.filteredNhanVien
                    
                    VStack(spacing: 0) {
                        if filtered.isEmpty {
                            Spacer()
                            VTSEmptyState(
                                icon: "person.crop.circle.badge.questionmark",
                                title: "Không tìm thấy kết quả",
                                subtitle: "Vui lòng nhập từ khóa khác"
                            )
                            Spacer()
                        } else {
                            ERPTable(
                                dataSource: filtered,
                                columns: [
                                    ERPColumn(
                                        title: AnyView(Text("#")),
                                        key: "emid",
                                        width: 0.1,
                                        alignment: .center,
                                        render: { _, index in
                                            AnyView(
                                                Text(String(index + 1))
                                                
                                            )
                                        }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Họ")),
                                        key: "emHo",
                                        width: 0.4,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.emHo)
                                            )
                                        },
                                        sorter: { $0.emHo.localizedCompare($1.emHo) == .orderedAscending }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Tên")),
                                        key: "emTen",
                                        width: 0.2,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.emTen)
                                            )
                                        },
                                        sorter: { $0.emTen.localizedCompare($1.emTen) == .orderedAscending }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Điện thoại")),
                                        key: "emDienThoai",
                                        width: 0.3,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.emDienThoai)
                                            )
                                        },
                                        sorter: { $0.emDienThoai.localizedCompare($1.emDienThoai) == .orderedAscending }
                                    ),
                                    
                                 ],
                                defaultSortKey: "emTen",
                                onRowLongPress: { row in
                                    router.showScreen(.push) { _ in
                                        NhanVienDetailView(maNV: row.emid, isEditMode: false)
                                    }
                                },
                                onRowAction: { action, row in
                                    handleRowAction(action, row: row)
                                },
                                actions: {
                                    var list: [VTSRowAction] = []
                                    let perm = AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_NHANVIEN")
                                    if perm?.view == true || perm == nil { list.append(.xem) }
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
                                    AnyView(Text("Tổng cộng: \(viewModel.filteredNhanVien.count) nhân viên")
                                        .font(.system(size: 12, weight: .bold))
                                        .padding(.vertical, 6)
                                        .foregroundColor(Color.vtsBg)
                                        .frame(width: width * 1, alignment: .center)
                                        .background(Color.vtsPrimary))
                                    
                                },
                                rowHeight: 40,
                                disableVerticalScrolling: false,
                                showCompanyFooter: true
                            )
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
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
            subtitle: "Nhân viên",
            isWhiteText: true,
            leading: {},
            trailing: {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSearchBar.toggle()
                    }
                } label: {
                    LucideIcon(showSearchBar ? .x : .search, size: 20, color: .white)
                }
            },
            primaryAction: {
                EmptyView()
            }
        )
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func handleRowAction(_ action: VTSRowAction, row: TNhanVien_DanhSach) {
        switch action {
        case .xem:
            router.showScreen(.push) { _ in
                NhanVienDetailView(maNV: row.emid, isEditMode: false)
            }
        default:
            break
        }
    }
}

#Preview {
    let _ = AuthManager.shared.saveTokens(access: "mock_jwt_token_for_vts_staff_bypass", refresh: "mock_refresh")
    return RouterView { _ in
        NhanVienListView()
    }
}
