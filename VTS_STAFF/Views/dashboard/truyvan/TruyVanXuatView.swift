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
    @State private var showSearchBar = false
    @State private var hasLoadedData = false
    
    init(fromDate: Date, toDate: Date) {
        _viewModel = StateObject(wrappedValue: TruyVanXuatViewModel(fromDate: fromDate, toDate: toDate))
    }
    
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
                    .padding(.top, VTSSpacing.sm)
                    .padding(.bottom, VTSSpacing.sm)
                    .background(Color.vtsPrimary)
                }
                
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
                
                Group {
                    if viewModel.queryType == .byItem {
                        tabContent(for: .byItem)
                    } else {
                        tabContent(for: .byCus)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.vtsPrimary)
            }
            .ignoresSafeArea(edges: .bottom)
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
                    let grandTotal = filtered.filter { $0.colDataType == 0 }.reduce(0.0) { $0 + $1.colValue }
                    
                    ERPTable(
                        dataSource: filtered,
                        columns: [
                            ERPColumn(
                                title: AnyView(Text("#")),
                                key: "colOrder",
                                width: 0.12,
                                alignment: .center,
                                render: { item, _ in
                                    if item.colDataType == 1 {
                                        return AnyView(Text(""))
                                    }
                                    return AnyView(
                                        Text("\(item.colOrder)")
                                            .font(.system(size: 11.5, weight: .regular))
                                    )
                                },
                                sorter: { $0.colOrder < $1.colOrder }
                            ),
                            ERPColumn(
                                title: AnyView(Text(type == .byItem ? "Hàng hoá" : "Khách hàng")),
                                key: "colName",
                                width: 0.58,
                                alignment: .leading,
                                render: { item, _ in
                                    AnyView(
                                        Text(item.colName ?? "")
                                            .font(.system(size: 11.5, weight: item.colDataType == 1 ? .bold : .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                            .frame(maxWidth: .infinity, alignment: item.colDataType == 1 ? .center : .leading)
                                    )
                                },
                                sorter: { ($0.colName ?? "").localizedCompare($1.colName ?? "") == .orderedAscending }
                            ),
                            ERPColumn(
                                title: AnyView(Text("Số lượng")),
                                key: "colValue",
                                width: 0.30,
                                alignment: .trailing,
                                render: { item, _ in
                                    AnyView(
                                        Text(item.colValue.toFormattedString(maxDecimals: 0))
                                            .font(.system(size: 11.5, weight: item.colDataType == 1 ? .bold : .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                    )
                                },
                                sorter: { $0.colValue < $1.colValue }
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
                        groupKey: { $0.colGroup ?? $0.colCode ?? "" },
                        customRowBuilder: { item, fullWidth in
                            let isSubtotal = (item.colDataType == 1)
                            
                            return AnyView(
                                HStack(spacing: 0) {
                                    Text(isSubtotal ? "" : "\(item.colOrder)")
                                        .font(.system(size: 11.5, weight: isSubtotal ? .bold : .regular))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                        .frame(width: fullWidth * 0.12, alignment: .center)
                                        .frame(maxHeight: .infinity)
                                        .border(Color.vtsBorder, width: 0.5)
                                    
                                    Text(item.colName ?? "")
                                        .font(.system(size: 11.5, weight: isSubtotal ? .bold : .regular))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                        .padding(.horizontal, 4)
                                        .frame(width: fullWidth * 0.58, alignment: isSubtotal ? .center : .leading)
                                        .frame(maxHeight: .infinity)
                                        .border(Color.vtsBorder, width: 0.5)
                                    
                                    Text(item.colValue.toFormattedString(maxDecimals: 0))
                                        .font(.system(size: 11.5, weight: isSubtotal ? .bold : .regular))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                        .padding(.horizontal, 4)
                                        .frame(width: fullWidth * 0.30, alignment: .trailing)
                                        .frame(maxHeight: .infinity)
                                        .border(Color.vtsBorder, width: 0.5)
                                }
                                .frame(height: 28)
                                .background(isSubtotal ? Color(hex: "D1F2D9") : Color.white)
                            )
                        },
                        customFooterBuilder: { width in
                            AnyView(
                                HStack(spacing: 0) {
                                    Text("Cộng")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: width * 0.70, alignment: .center)
                                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(Color.white.opacity(0.3)), alignment: .trailing)
                                    
                                    Text(grandTotal.toFormattedString(maxDecimals: 0))
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .frame(width: width * 0.30, alignment: .trailing)
                                }
                                .padding(.vertical, 6)
                                .background(Color.vtsPrimary)
                            )
                        },
                        disableVerticalScrolling: false,
                        showCompanyFooter: true
                    )
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.vtsBg)
    }
}

#Preview {
    RouterView { _ in
        TruyVanXuatView(fromDate: Date(), toDate: Date())
    }
}
