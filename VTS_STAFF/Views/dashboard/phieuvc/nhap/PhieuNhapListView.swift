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
    @StateObject private var viewModel: PhieuNhapListViewModel
    @State private var showSearchBar: Bool
    @State private var hasLoadedData = false
    @State private var selectedModalItem: TPhieuvc_Nhap_DanhSach? = nil
    
    init(fromDate: Date? = nil, toDate: Date? = nil, searchText: String? = nil) {
        let vm = PhieuNhapListViewModel(fromDate: fromDate, toDate: toDate, searchText: searchText)
        _viewModel = StateObject(wrappedValue: vm)
        _showSearchBar = State(initialValue: searchText != nil && !searchText!.isEmpty)
    }
    
    private var permission: TChucNangPhanQuyen? {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUNHAP")
    }
    
    private var hasDeletePermission: Bool {
        permission?.del == true
    }
    
    private func deleteItem(_ item: TPhieuvc_Nhap_DanhSach) {
        router.showAlert(.alert, title: "Xác nhận xoá", subtitle: "Bạn có chắc chắn muốn xoá phiếu nhập \(item.soPhieu)?") {
            Button("Xoá", role: .destructive) {
                Task {
                    do {
                        _ = try await PhieuNhapService.shared.xoa(soPhieu: item.soPhieu)
                        await viewModel.loadData()
                    } catch {
                        ErrorManager.shared.showError("Không thể xoá phiếu: \(error.localizedDescription)")
                    }
                }
            }
            Button("Huỷ", role: .cancel) {}
        }
    }
    
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
                            ZStack(alignment: .bottomLeading) {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(filtered) { item in
                                            cardItemView(item: item)
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
                        let totalWeight = filtered.reduce(0.0) { $0 + Double($1.trongLuongHang) }
                        HStack(spacing: 0) {
                            Text("Tổng cộng \(filtered.count) phiếu")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text(totalWeight.toFormattedString(maxDecimals: 0))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 110, alignment: .center)
                        }
                        .padding(.vertical, 7)
                        .background(Color.vtsPrimary)
                    }
                }
                
                VTSCompanyFooter()
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .task {
            if !hasLoadedData {
                await viewModel.loadData()
                hasLoadedData = true
            }
        }
        .sheet(item: $selectedModalItem) { item in
            VTSActionModalSheet(
                title: "Phiếu nhập: \(item.soPhieu)",
                subtitle: "\(item.tenHangHoa) • \(item.ngay.toUIDateString)",
                actions: {
                    var acts: [VTSModalAction] = []
                    acts.append(VTSModalAction(title: "Xem chi tiết", icon: "eye.fill") {
                        router.showScreen(.push) { _ in
                            PhieuNhapDetailView(soPhieu: item.soPhieu, existing: item)
                        }
                    })
                    if hasDeletePermission {
                        acts.append(VTSModalAction(title: "Xoá phiếu", icon: "trash.fill", isDestructive: true) {
                            deleteItem(item)
                        })
                    }
                    return acts
                }(),
                onClose: {
                    selectedModalItem = nil
                }
            )
            .presentationDetents([.fraction(hasDeletePermission ? 0.38 : 0.3), .medium])
            .presentationDragIndicator(.visible)
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Chuyển hàng thu về",
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
                    
                    if AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUNHAP")?.add == true {
                        Button {
                            router.showScreen(.push) { _ in
                                PhieuNhapDetailView(soPhieu: nil, isEditMode: true)
                            }
                        } label: {
                            LucideIcon(.plus, size: 18)
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
    
    @ViewBuilder
    private func cardItemView(item: TPhieuvc_Nhap_DanhSach) -> some View {
        PhieuNhapCardView(item: item)
            .contentShape(Rectangle())
            .onLongPressGesture {
                let haptic = UIImpactFeedbackGenerator(style: .medium)
                haptic.impactOccurred()
                selectedModalItem = item
            }
            .contextMenu {
                Button {
                    router.showScreen(.push) { _ in
                        PhieuNhapDetailView(soPhieu: item.soPhieu, existing: item)
                    }
                } label: {
                    Label("Xem chi tiết", systemImage: "eye")
                }
                
                if hasDeletePermission {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label("Xoá phiếu", systemImage: "trash")
                    }
                }
            }
    }
}

struct PhieuNhapCardView: View {
    let item: TPhieuvc_Nhap_DanhSach
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row 1: Số, Trạng thái, Ngày
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
                
                VTSPhieuStatusChip(trangThai: item.tenTrangThai ?? item.trangThai)
                
                Text(item.ngay.toUIDateString)
                    .font(.system(size: 13))
                    .foregroundColor(.vtsTxtSecondary)
            }
            
            // Row 2: Khách hàng
            if let khach = item.tenKhachHang, !khach.isEmpty {
                HStack(spacing: 6) {
                    Text("Khách:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(khach)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.vtsTxtPrimary)
                        .lineLimit(1)
                }
            }
            
            // Row 3: Hàng hoá & Khối lượng
            HStack {
                HStack(spacing: 4) {
                    Text("Hàng:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(item.tenHangHoa)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.vtsPrimary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("KL:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(Double(item.trongLuongHang).toFormattedString(maxDecimals: 0))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                }
            }
            
            // Row 4: Xe & Tài xế
            HStack {
                HStack(spacing: 4) {
                    Text("Xe:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(item.soXe ?? "---")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.vtsTxtPrimary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Tài xế:")
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                    Text(item.taiXe ?? "---")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.vtsTxtPrimary)
                        .lineLimit(1)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
