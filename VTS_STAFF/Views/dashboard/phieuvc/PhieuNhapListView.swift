//
//  PhieuNhapListView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 02/07/2026.
//

import SwiftUI
import SwiftfulRouting

struct PhieuNhapListView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = PhieuNhapListViewModel()
    @State private var showSearchBar = false
    @State private var hasLoadedData = false
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                SystemDateFilterHeader(
                    fromDate: $viewModel.fromDate,
                    toDate: $viewModel.toDate,
                    onChanged: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                )
                .padding(.horizontal, VTSSpacing.xl)
                .padding(.top, VTSSpacing.md)
                .padding(.bottom, showSearchBar ? 0 : VTSSpacing.md)
                
                if showSearchBar {
                    VTSSearchBar(text: $viewModel.searchText, placeholder: "Tìm kiếm số phiếu, số xe, tài xế...")
                        .padding(.horizontal, VTSSpacing.xl)
                        .padding(.top, VTSSpacing.md)
                        .padding(.bottom, VTSSpacing.md)
                }
                
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: "Không tìm thấy phiếu nhập",
                    emptySubtitle: "Vui lòng kiểm tra lại kết nối hoặc thử lại.",
                    emptyIcon: "doc.text.fill",
                    retry: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                ) { _ in
                    let filtered = viewModel.filteredPhieu
                    
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
                                        width: 0.08,
                                        alignment: .center,
                                        render: { _, index in
                                            AnyView(Text(String(index + 1)))
                                        }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Số phiếu")),
                                        key: "soPhieu",
                                        width: 0.2,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(Text(item.soPhieu))
                                        }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Số xe")),
                                        key: "soXe",
                                        width: 0.17,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(Text(item.soXe))
                                        }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Hàng hóa")),
                                        key: "tenHangHoa",
                                        width: 0.23,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(Text(item.tenHangHoa))
                                        }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("TL Hàng")),
                                        key: "trongLuongHang",
                                        width: 0.17,
                                        alignment: .trailing,
                                        render: { item, _ in
                                            AnyView(Text(String(format: "%.0f kg", Double(item.trongLuongHang))))
                                        }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Trạng thái")),
                                        key: "tenTrangThai",
                                        width: 0.15,
                                        alignment: .center,
                                        render: { item, _ in
                                            AnyView(VTSPhieuStatusChip(trangThai: item.tenTrangThai))
                                        }
                                    )
                                ],
                                onRowTap: { row in
                                    print("Selected Phieu Nhap: \(row.soPhieu)")
                                },
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
                                    AnyView(Text("Tổng cộng: \(viewModel.filteredPhieu.count) phiếu")
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
            subtitle: "Danh sách phiếu vận chuyển nhập",
            isWhiteText: !showSearchBar,
            leading: {},
            trailing: {
                Button {
                    withAnimation(.easeInOut) {
                        showSearchBar.toggle()
                    }
                } label: {
                    Image(systemName: showSearchBar ? "magnifyingglass.circle.fill" : "magnifyingglass")
                        .font(.title3)
                }
            },
            primaryAction: {
                EmptyView()
            }
        )
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    RouterView { _ in
        PhieuNhapListView()
    }
}
