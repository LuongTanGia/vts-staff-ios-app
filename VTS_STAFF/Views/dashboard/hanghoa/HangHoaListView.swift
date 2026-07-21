//
//  HangHoaListView.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct HangHoaListView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = HangHoaListViewModel()
    @State private var showSearchBar = false
    @State private var hasLoadedData = false
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                if showSearchBar {
                    VTSSearchBar(text: $viewModel.searchText, placeholder: "Tìm kiếm mã, tên, loại, ĐVT...")
                        .padding(.horizontal, VTSSpacing.xl)
                        .padding(.top, VTSSpacing.lg)
                        .padding(.bottom, VTSSpacing.md)
                }
                
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: "Không tìm thấy hàng hoá",
                    emptySubtitle: "Vui lòng kiểm tra lại kết nối hoặc thử lại.",
                    emptyIcon: "cube.box.fill",
                    retry: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                ) { _ in
                    let filtered = viewModel.filteredHangHoa
                    
                    VStack(spacing: 0) {
                        if filtered.isEmpty {
                            Spacer()
                            VTSEmptyState(
                                icon: "doc.text.magnifyingglass",
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
                                        title: AnyView(Text("Tên")),
                                        key: "ten",
                                        width: 0.4,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.ten)
                                            )
                                        },
                                        sorter: { $0.ten.localizedCompare($1.ten) == .orderedAscending }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Loại")),
                                        key: "loai",
                                        width: 0.15,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.loai ?? "")
                                            )
                                        },
                                        sorter: { ($0.loai ?? "").localizedCompare($1.loai ?? "") == .orderedAscending }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("ĐVT")),
                                        key: "dvt",
                                        width: 0.15,
                                        alignment: .center,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.dvt ?? "")
                                            )
                                        },
                                        sorter: { ($0.dvt ?? "").localizedCompare($1.dvt ?? "") == .orderedAscending }
                                    ),
                                    
                                ],
                                defaultSortKey: "ten",
                                onRowAction: { action, row in
                                    handleRowAction(action, row: row)
                                },
                                actions: {
                                    var list: [VTSRowAction] = []
                                    let perm = AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_HANGHOA")
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
                                    AnyView(Text("Tổng cộng: \(viewModel.filteredHangHoa.count) hàng hoá")
                                        .padding()
                                        .foregroundColor(Color.vtsBg)
                                        .frame(width: width * 1, alignment: .center)
                                        .background(Color.vtsPrimary))
                                    
                                },
                                rowHeight: 40,
                                disableVerticalScrolling: false
                            )
                        }
                    }
                }
            }
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
            subtitle: "Hàng hoá",
            isWhiteText: !showSearchBar,
            leading: {
                
            },
            trailing: {
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.easeInOut) {
                            showSearchBar.toggle()
                        }
                    } label: {
                        Image(systemName: showSearchBar ? "magnifyingglass.circle.fill" : "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(showSearchBar ? .primary : .white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    
                    if AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_HANGHOA")?.add == true {
                        Button {
                            router.showScreen(.push) { _ in
                                HangHoaDetailView(maHH: nil)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundColor(showSearchBar ? .primary : .white)
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
    
    private func handleRowAction(_ action: VTSRowAction, row: THangHoa_DanhSach) {
        switch action {
        case .xem:
            router.showScreen(.push) { _ in
                HangHoaDetailView(maHH: row.ma, isEditMode: false)
            }
        case .sua:
            router.showScreen(.push) { _ in
                HangHoaDetailView(maHH: row.ma, isEditMode: true)
            }
        case .xoa:
            router.showAlert(.alert, title: "Xác nhận xóa", subtitle: "Bạn có chắc chắn muốn xóa hàng hóa \(row.ten) (\(row.ma))?") {
                Button("Huỷ", role: .cancel) {}
                Button("Xoá", role: .destructive) {
                    Task {
                        do {
                            let _ = try await HangHoaService.shared.xoa(ma: row.ma)
                            await viewModel.loadData()
                        } catch {
                            router.showAlert(.alert, title: "Lỗi", subtitle: error.localizedDescription) {
                                Button("OK") {}
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
        HangHoaListView()
    }
}
