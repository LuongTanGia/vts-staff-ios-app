//
//  TruyVanChuyenXeView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 08/07/2026.
//

import SwiftUI
import SwiftfulRouting

struct TruyVanChuyenXeView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: TruyVanChuyenXeViewModel
    @State private var showSearchBar = false
    @State private var hasLoadedData = false
    
    init(fromDate: Date, toDate: Date) {
        _viewModel = StateObject(wrappedValue: TruyVanChuyenXeViewModel(fromDate: fromDate, toDate: toDate))
    }
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
               
//                .padding(.horizontal, VTSSpacing.xl)
//                .padding(.top, VTSSpacing.md)
//                .padding(.bottom, showSearchBar ? 0 : VTSSpacing.md)
                
                if showSearchBar {
                    VTSSearchBar(text: $viewModel.searchText, placeholder: "Tìm kiếm mã, hàng hóa...")
                        .padding(.horizontal, VTSSpacing.xl)
                        .padding(.top, VTSSpacing.md)
                        .padding(.bottom, VTSSpacing.md)
                }
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
                .background(Color.vtsPrimary)
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: "Không tìm thấy chuyến xe",
                    emptySubtitle: "Vui lòng chọn khoảng ngày khác hoặc thử lại.",
                    emptyIcon: "bus.fill",
                    retry: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                ) { _ in
                    let filtered = viewModel.filteredData
                    
                    VStack(spacing: 0) {
                        if filtered.isEmpty {
                            Spacer()
                            VTSEmptyState(
                                icon: "magnifyingglass",
                                title: "Không tìm thấy kết quả",
                                subtitle: "Vui lòng nhập từ khóa khác"
                            )
                            Spacer()
                        } else {
                            
                            let totalValue2 = filtered.sum(by: \.colValue2)
                            
                            let totalValue4 = filtered.sum(by: \.colValue4)
                            
                            ERPTable(
                                dataSource: filtered,
                                columns: [
                                    ERPColumn(
                                        title: AnyView(Text("#")),
                                        key: "index",
                                        width: 0.1,
                                        alignment: .center,
                                        render: { _, index in
                                            AnyView(Text(String(index + 1)))
                                        }
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Hàng hóa")),
                                        key: "colName",
                                        width: 0.40,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(
                                                
                                                Text(item.colName)
                                                    
                                                
                                                
                                            )
                                        },
                                        footer: AnyView(Text("Cộng"))
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Số nhận"))
                                        ,
                                        key: "nhan",
                                        width: 0.25,
                                        alignment: .trailing,
                                        render: { item, _ in
                                            AnyView(
                                                
                                                Text(item.colValue2.toFormattedString(maxDecimals: 2))
                                                    
                                                
                                            )
                                        },
                                        footer: AnyView(Text(totalValue2.toFormattedString(maxDecimals: 2)))
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Số giao")),
                                        key: "giao",
                                        width: 0.25,
                                        alignment: .trailing,
                                        render: { item, _ in
                                            AnyView(
                                                
                                                Text(item.colValue4.toFormattedString(maxDecimals: 1))
                                                    
                                                
                                            )
                                        },
                                        footer: AnyView(Text(totalValue4.toFormattedString(maxDecimals: 2)))
                                    )
                                ],
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
                                
                               
                                disableVerticalScrolling: false
                            )
                        }
                    }
                }
                .background(Color.vtsBg)
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
            subtitle: "Hàng hóa theo chuyến",
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
                        .foregroundColor(showSearchBar ? .primary : .white)
                        .contentTransition(.symbolEffect(.replace))
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
        TruyVanChuyenXeView(fromDate: Date(), toDate: Date())
    }
}
