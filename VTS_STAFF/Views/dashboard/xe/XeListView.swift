//
//  XeListView.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct XeListView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = XeListViewModel()
    @State private var showSearchBar = false
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                if showSearchBar {
                    VTSSearchBar(text: $viewModel.searchText, placeholder: "Tìm kiếm mã, tên xe, loại, tài xế...")
                        .padding(.horizontal, VTSSpacing.xl)
                        .padding(.top, VTSSpacing.lg)
                        .padding(.bottom, VTSSpacing.md)
                }
                
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: "Không tìm thấy phương tiện",
                    emptySubtitle: "Vui lòng kiểm tra lại kết nối hoặc thử lại.",
                    emptyIcon: "car.2.fill",
                    retry: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                ) { _ in
                    let filtered = viewModel.filteredXe
                    
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
                                        title: AnyView(Text("Biển số")),
                                        key: "ma",
                                        width: 0.25,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.ma)
                                                    .fontWeight(.semibold)
                                            )
                                        },
                                        sorter: { $0.ma.localizedCompare($1.ma) == .orderedAscending }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Tên gọi")),
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
                                        title: AnyView(Text("Loại")),
                                        key: "loai",
                                        width: 0.2,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                Text(item.loai)
                                            )
                                        },
                                        sorter: { $0.loai.localizedCompare($1.loai) == .orderedAscending }
                                    ),
                                    
                                ],
                                defaultSortKey: "ma",
                                onRowAction: { action, row in
                                    handleRowAction(action, row: row)
                                },
                                actions: {
                                    var list: [VTSRowAction] = []
                                    let perm = AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_XE")
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
                                    AnyView(Text("Tổng cộng: \(viewModel.filteredXe.count) phương tiện")
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
            await viewModel.loadData()
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Xe nhà",
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
                    
                    if AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_XE")?.add == true {
                        Button {
                            router.showScreen(.push) { _ in
                                XeDetailView(maXe: nil)
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
    
    private func handleRowAction(_ action: VTSRowAction, row: TXe_DanhSach) {
        switch action {
        case .xem:
            router.showScreen(.push) { _ in
                XeDetailView(maXe: row.ma, isEditMode: false)
            }
        case .sua:
            router.showScreen(.push) { _ in
                XeDetailView(maXe: row.ma, isEditMode: true)
            }
        case .xoa:
            router.showAlert(.alert, title: "Xác nhận xóa", subtitle: "Bạn có chắc chắn muốn xóa phương tiện \(row.ten) (\(row.ma))?") {
                Button("Huỷ", role: .cancel) {}
                Button("Xoá", role: .destructive) {
                    Task {
                        do {
                            let _ = try await XeService.shared.xoa(ma: row.ma)
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
        XeListView()
    }
}
