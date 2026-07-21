//
//  PhieuGiaCongListView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 02/07/2026.
//

import SwiftUI
import SwiftfulRouting

struct PhieuGiaCongListView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel = PhieuGiaCongListViewModel()
    @State private var showSearchBar = false
    @State private var hasLoadedData = false
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if showSearchBar {
                        VTSSearchBar(text: $viewModel.searchText, placeholder: "Tìm kiếm số phiếu, số xe, tài xế...")
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
                    .padding(.top, VTSSpacing.md)
                    .background(Color.vtsPrimary)
                }
              
                
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: "Không tìm thấy phiếu gia công",
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
                            ZStack(alignment: .bottomLeading) {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(filtered) { item in
                                            Button {
                                                router.showScreen(.push) { _ in
                                                    PhieuGiaCongDetailView(soPhieu: item.soPhieu, existing: item)
                                                }
                                            } label: {
                                                PhieuGiaCongCardView(item: item)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .onAppear {
                                                if item.id == filtered.last?.id {
                                                    Task {
                                                        await viewModel.loadDataIfNeeded()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                }
                                .refreshable {
                                    await viewModel.loadData()
                                }
                            }
                        }
                        
                        // Bottom Statistics Footer
                        let totalWeight = filtered.reduce(0) { $0 + $1.trongLuongHang }
                        HStack(spacing: 0) {
                            Text("Tổng cộng \(filtered.count) phiếu")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text(Double(totalWeight).toFormattedString(maxDecimals: 0))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .center)
                        }
                        .frame(height: 48)
                        .background(Color.vtsPrimary)
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
            subtitle: "Chuyển hàng gia công",
            isWhiteText: !showSearchBar,
            leading: {},
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
                    
                    if AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUGIACONG")?.add == true {
                        Button {
//                            router.showScreen(.push) { _ in
//                                PhieuGiaCongDetailView(soPhieu: nil, isEditMode: true)
//                            }
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
}

struct PhieuGiaCongCardView: View {
    let item: TPhieuvc_Giacong_DanhSach
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row 1: Số, Ngày
            HStack {
                HStack(spacing: 4) {
                    Text("Số:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(item.soPhieu)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("Ngày:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(item.ngay.toUIDateString)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                }
            }
            
            // Row 2: Xe ngoài, Số xe
            HStack {
                HStack(spacing: 6) {
                    Text("Xe ngoài:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Image(systemName: item.xeNgoai ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18))
                        .foregroundColor(item.xeNgoai ? .vtsPrimary : .vtsBorder)
                        .symbolEffect(.bounce, options: .nonRepeating)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("Số xe:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(item.soXe ?? "")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                }
            }
            
            // Row 3: Tài xế
            HStack(spacing: 4) {
                Text("Tài xế:")
                    .font(.vtsCallout)
                    .foregroundColor(.vtsTxtSecondary)
                Text(item.taiXe ?? "")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.vtsPrimary)
                Spacer()
            }
            
            // Row 4: Hàng giao, Số/Trọng lượng
            HStack {
                HStack(spacing: 4) {
                    Text("Hàng giao:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(item.tenHangHoa)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text("Số/Trọng lượng:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(Double(item.trongLuongHang).toFormattedString(maxDecimals: 0))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                }
            }
            
            // Row 5: Khách hàng
            HStack(alignment: .top, spacing: 4) {
                Text("Khách hàng:")
                    .font(.vtsCallout)
                    .foregroundColor(.vtsTxtSecondary)
                Text(item.tenKhachHang ?? "")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.vtsPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.vtsBorder.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    RouterView { _ in
        PhieuGiaCongListView()
    }
}

