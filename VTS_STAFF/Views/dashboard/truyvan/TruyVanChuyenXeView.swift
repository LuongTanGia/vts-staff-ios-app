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
                
                HStack(spacing: 8) {
                    SystemDateFilterHeader(
                        fromDate: $viewModel.fromDate,
                        toDate: $viewModel.toDate,
                        onChanged: {
                            Task {
                                await viewModel.loadData()
                            }
                        }
                    )
                }
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
                            let totalValue1 = filtered.sum(by: \.colValue1)
                            let totalValue2 = filtered.sum(by: \.colValue2)
                            let totalValue3 = filtered.sum(by: \.colValue3)
                            let totalValue4 = filtered.sum(by: \.colValue4)
                            
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
                                        },
                                        footer: AnyView(Text("").font(.system(size: 13, weight: .bold)))
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Hàng hóa")),
                                        key: "colName",
                                        width: 0.30,
                                        alignment: .leading,
                                        render: { item, _ in
                                            AnyView(Text(item.colName ?? ""))
                                        },
                                        sorter: { ($0.colName ?? "") < ($1.colName ?? "") },
                                        footer: AnyView(Text("Cộng").font(.system(size: 13, weight: .bold)))
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Xe nhận")),
                                        key: "colValue1",
                                        width: 0.14,
                                        alignment: .trailing,
                                        render: { item, _ in
                                            AnyView(Text("\(item.colValue1)"))
                                        },
                                        sorter: { $0.colValue1 < $1.colValue1 },
                                        footer: AnyView(Text("\(totalValue1)").font(.system(size: 13, weight: .bold)))
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Số nhận")),
                                        key: "colValue2",
                                        width: 0.17,
                                        alignment: .trailing,
                                        render: { item, _ in
                                            AnyView(Text(item.colValue2.toFormattedString(maxDecimals: 2)))
                                        },
                                        sorter: { $0.colValue2 < $1.colValue2 },
                                        footer: AnyView(Text(totalValue2.toFormattedString(maxDecimals: 2)).font(.system(size: 13, weight: .bold)))
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Xe giao")),
                                        key: "colValue3",
                                        width: 0.15,
                                        alignment: .trailing,
                                        render: { item, _ in
                                            AnyView(Text("\(item.colValue3)"))
                                        },
                                        sorter: { $0.colValue3 < $1.colValue3 },
                                        footer: AnyView(Text("\(totalValue3)").font(.system(size: 13, weight: .bold)))
                                    ),
                                    ERPColumn(
                                        title: AnyView(Text("Số giao")),
                                        key: "colValue4",
                                        width: 0.16,
                                        alignment: .trailing,
                                        render: { item, _ in
                                            AnyView(Text(item.colValue4.toFormattedString(maxDecimals: 2)))
                                        },
                                        sorter: { $0.colValue4 < $1.colValue4 },
                                        footer: AnyView(Text(totalValue4.toFormattedString(maxDecimals: 2)).font(.system(size: 13, weight: .bold)))
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
                                customHeaderBuilder: { containerW in
                                    let tableBorderColor = Color(hex: "C5D2E0")
                                    let headerBgColor = Color.vtsPrimary
                                    
                                    let col1Width: CGFloat = max(24, containerW * 0.08)
                                    let colXeWidth: CGFloat = max(38, containerW * 0.14)
                                    let colQtyWidth: CGFloat = max(55, containerW * 0.17)
                                    let colXe2Width: CGFloat = max(38, containerW * 0.15)
                                    let colQty2Width: CGFloat = max(55, containerW * 0.16)
                                    
                                    return AnyView(
                                        HStack(spacing: 0) {
                                            Text("#")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: col1Width, alignment: .center)
                                                .frame(maxHeight: .infinity)
                                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                                            
                                            Text("Hàng hóa")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 4)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .frame(maxHeight: .infinity)
                                                .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                                            
                                            // Group "Nhận"
                                            VStack(spacing: 0) {
                                                Text("Nhận")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 5)
                                                    .frame(maxWidth: .infinity)
                                                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                                                
                                                HStack(spacing: 0) {
                                                    Text("Xe")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 4)
                                                        .frame(width: colXeWidth, alignment: .center)
                                                        .frame(maxHeight: .infinity)
                                                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                                                    
                                                    Text("Số lượng")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 4)
                                                        .frame(width: colQtyWidth, alignment: .center)
                                                        .frame(maxHeight: .infinity)
                                                }
                                            }
                                            .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                                            
                                            // Group "Giao"
                                            VStack(spacing: 0) {
                                                Text("Giao")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 5)
                                                    .frame(maxWidth: .infinity)
                                                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                                                
                                                HStack(spacing: 0) {
                                                    Text("Xe")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 4)
                                                        .frame(width: colXe2Width, alignment: .center)
                                                        .frame(maxHeight: .infinity)
                                                        .overlay(Rectangle().frame(width: 0.5).foregroundColor(tableBorderColor), alignment: .trailing)
                                                    
                                                    Text("Số lượng")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 4)
                                                        .frame(width: colQty2Width, alignment: .center)
                                                        .frame(maxHeight: .infinity)
                                                }
                                            }
                                        }
                                        .fixedSize(horizontal: false, vertical: true)
                                        .background(headerBgColor)
                                        .overlay(Rectangle().frame(height: 0.5).foregroundColor(tableBorderColor), alignment: .bottom)
                                    )
                                },
                                disableVerticalScrolling: false,
                                showCompanyFooter: true
                            )
                        }
                    }
                }
                .background(Color.vtsBg)
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
            subtitle: "Hàng hóa theo chuyến",
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
}

#Preview {
    RouterView { _ in
        TruyVanChuyenXeView(fromDate: Date(), toDate: Date())
    }
}
