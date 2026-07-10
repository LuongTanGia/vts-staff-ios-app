//
//  TruyVanXuatView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 08/07/2026.
//

import SwiftUI
import SwiftfulRouting

struct TruyVanXuatView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: TruyVanXuatViewModel
    @State private var hasLoadedData = false
    
    init(fromDate: Date, toDate: Date) {
        _viewModel = StateObject(wrappedValue: TruyVanXuatViewModel(fromDate: fromDate, toDate: toDate))
    }
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                Picker("Loại truy vấn", selection: $viewModel.queryType) {
                    ForEach(QueryType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, VTSSpacing.xl)
                .background(Color.vtsPrimary)
                
                SystemDateFilterHeader(
                    fromDate: $viewModel.fromDate,
                    toDate: $viewModel.toDate,
                    onChanged: {
                        Task {
                            await viewModel.loadAllData()
                        }
                    }
                )
                .padding(.horizontal, VTSSpacing.xl)
                .background(Color.vtsPrimary)
                
                TabView(selection: $viewModel.queryType) {
                    tabContent(for: .byItem)
                        .tag(QueryType.byItem)
                    
                    tabContent(for: .byCus)
                        .tag(QueryType.byCus)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color.vtsPrimary)
            }
        }
        .task {
            if !hasLoadedData {
                await viewModel.loadAllData()
                hasLoadedData = true
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Thống kê hàng giao",
            isWhiteText: true,
            leading: {},
            trailing: {},
            primaryAction: {
                EmptyView()
            }
        )
        .toolbar(.hidden, for: .tabBar)
    }
    
    @ViewBuilder
    private func tabContent(for type: QueryType) -> some View {
        let state = (type == .byItem) ? viewModel.stateByItem : viewModel.stateByCus
        let filtered = (type == .byItem) ? viewModel.filteredDataByItem : viewModel.filteredDataByCus
        
        VTSAsyncContent(
            state: state,
            emptyTitle: "Không tìm thấy dữ liệu xuất",
            emptySubtitle: "Vui lòng chọn khoảng ngày khác hoặc thử lại.",
            emptyIcon: "tray.and.arrow.up.fill",
            retry: {
                Task {
                    await viewModel.loadData(for: type)
                }
            }
        ) { _ in
            VStack(spacing: 0) {
                if filtered.isEmpty {
                    Spacer()
                    VTSEmptyState(
                        icon: "magnifyingglass",
                        title: "Không tìm thấy kết quả",
                        subtitle: "Không có dữ liệu trong khoảng thời gian này"
                    )
                    Spacer()
                } else {
                    let totalValue = filtered.filter { $0.colDataType == 0 }.sum(by: \.colValue)
                    
                    ERPTable(
                        dataSource: filtered,
                        columns: [
                            ERPColumn(
                                title: AnyView(Text("#")),
                                key: "colCode",
                                width: 0.1,
                                alignment: .center,
                                render: { _, _ in AnyView(Text("")) }
                            ),
                            ERPColumn(
                                title: AnyView(Text("Khách hàng / Hàng hoá")),
                                key: "colName",
                                width: 0.6,
                                alignment: .leading,
                                render: { _, _ in AnyView(Text("")) },
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
                                render: { _, _ in AnyView(Text("")) },
                                footer: AnyView(
                                    Text(totalValue.toFormattedString(maxDecimals: 0))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                )
                            )
                        ],
                        loadDataIfNeeded: {
                            Task {
                                await viewModel.loadDataIfNeeded()
                            }
                        },
                        onRefresh: {
                            Task {
                                await viewModel.loadData(for: type)
                            }
                        },
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
                                    .background(Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                )
                            } else if item.colDataType == 1 {
                                return AnyView(
                                    Text(item.colName)
                                        .padding(5)
                                        .frame(width: width * 1, alignment: .center)
                                        .background(Color.green.opacity(0.5))
                                        .border(Color.vtsBorder, width: 0.5)
                                )
                            }
                            return nil
                        },
                     
                        disableVerticalScrolling: false
                    )
                }
            }
        }
        .background(Color.vtsBg)
    }
}

#Preview {
    RouterView { _ in
        TruyVanXuatView(fromDate: Date(), toDate: Date())
    }
}
