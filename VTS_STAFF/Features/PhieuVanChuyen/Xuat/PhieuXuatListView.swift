//
//  PhieuXuatListView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 02/07/2026.
//

import SwiftUI
import SwiftfulRouting

struct PhieuXuatListView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let searchPlaceholder = "Nhập nội dung để tìm"
        static let emptyTitle = "Không tìm thấy phiếu xuất"
        static let emptySubtitle = "Vui lòng kiểm tra lại kết nối hoặc thử lại."
        static let noResultTitle = "Không tìm thấy kết quả"
        static let noResultSubtitle = "Vui lòng nhập từ khóa khác"
        static let deleteAlertTitle = "Xác nhận xóa"
        static func deleteAlertSubtitle(_ soPhieu: String) -> String { "Bạn có chắc chắn muốn xóa phiếu xuất \(soPhieu)?" }
        static let deleteBtn = "Xóa"
        static let cancelBtn = "Hủy"
        static func modalTitle(_ soPhieu: String) -> String { "Phiếu xuất: \(soPhieu)" }
        static let viewDetail = "Xem chi tiết"
        static let deleteTicket = "Xóa phiếu"
        static let navSubtitle = "Chuyển hàng giao"
        static func totalTickets(_ count: Int) -> String { "Tổng cộng \(count) phiếu" }
        static func deleteError(_ message: String) -> String { "Không thể xóa phiếu: \(message)" }
    }

    @Environment(\.router) private var router
    @StateObject private var viewModel: PhieuXuatListViewModel
    @State private var showSearchBar: Bool
    @State private var hasLoadedData = false
    @State private var selectedModalItem: TPhieuvc_Xuat_DanhSach? = nil
    
    init(fromDate: Date? = nil, toDate: Date? = nil, searchText: String? = nil) {
        let vm = PhieuXuatListViewModel(fromDate: fromDate, toDate: toDate, searchText: searchText)
        _viewModel = StateObject(wrappedValue: vm)
        _showSearchBar = State(initialValue: searchText != nil && !searchText!.isEmpty)
    }
    
    private var permission: TChucNangPhanQuyen? {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUXUAT")
    }
    
    private var hasDeletePermission: Bool {
        permission?.del == true
    }
    
    private func deleteItem(_ item: TPhieuvc_Xuat_DanhSach) {
        router.showAlert(.alert, title: Strings.deleteAlertTitle, subtitle: Strings.deleteAlertSubtitle(item.soPhieu)) {
            Button(Strings.deleteBtn, role: .destructive) {
                Task {
                    do {
                        _ = try await PhieuXuatService.shared.xoa(soPhieu: item.soPhieu)
                        await viewModel.loadData()
                    } catch {
                        ErrorManager.shared.showError(Strings.deleteError(error.localizedDescription))
                    }
                }
            }
            Button(Strings.cancelBtn, role: .cancel) {}
        }
    }
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if showSearchBar {
                        VTSSearchBar(
                            text: $viewModel.searchText,
                            placeholder: Strings.searchPlaceholder,
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
                }
                
                VTSAsyncContent(
                    state: viewModel.state,
                    emptyTitle: Strings.emptyTitle,
                    emptySubtitle: Strings.emptySubtitle,
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
                                title: Strings.noResultTitle,
                                subtitle: Strings.noResultSubtitle
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
                                    .padding(.bottom, 16)
                                }
                                .refreshable {
                                    await viewModel.loadData()
                                }
                            }
                        }
                        
                        // Bottom Statistics Footer
                        let totalWeight = filtered.reduce(0.0) { $0 + Double($1.trongLuongHang) }
                        HStack(spacing: 0) {
                            Text(Strings.totalTickets(filtered.count))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text(totalWeight.toQuantityString())
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
        .onReceive(NotificationCenter.default.publisher(for: .vtsPhieuXuatChanged)) { _ in
            Task {
                await viewModel.loadData()
            }
        }
        .sheet(item: $selectedModalItem) { item in
            VTSActionModalSheet(
                title: Strings.modalTitle(item.soPhieu),
                subtitle: "\(item.tenHangHoa) • \(item.ngay.toUIDateString)",
                actions: {
                    var acts: [VTSModalAction] = []
                    acts.append(VTSModalAction(title: Strings.viewDetail, icon: "eye.fill") {
                        router.showScreen(.push) { _ in
                            PhieuXuatDetailView(soPhieu: item.soPhieu, existing: item, onSaveSuccess: {
                                Task {
                                    await viewModel.loadData()
                                }
                            })
                        }
                    })
                    if hasDeletePermission {
                        acts.append(VTSModalAction(title: Strings.deleteTicket, icon: "trash.fill", isDestructive: true) {
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
            subtitle: Strings.navSubtitle,
            isWhiteText: true,
            leading: {},
            trailing: {
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.easeInOut) {
                            showSearchBar.toggle()
                        }
                    } label: {
                        LucideIcon(showSearchBar ? .x : .search, size: 20, color: .white)
                    }
                    
                    if AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUXUAT")?.add == true {
                        Button {
                            router.showScreen(.push) { _ in
                                PhieuXuatDetailView(soPhieu: nil, isEditMode: true, onSaveSuccess: {
                                    Task {
                                        await viewModel.loadData()
                                    }
                                })
                            }
                        } label: {
                            LucideIcon(.plus, size: 18)
                                .font(.title3)
                                .foregroundColor(.white)
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
    private func cardItemView(item: TPhieuvc_Xuat_DanhSach) -> some View {
        PhieuXuatCardView(item: item)
            .contentShape(Rectangle())
            .onLongPressGesture {
                let haptic = UIImpactFeedbackGenerator(style: .medium)
                haptic.impactOccurred()
                if !hasDeletePermission && (permission?.view == true || permission == nil) {
                    router.showScreen(.push) { _ in
                        PhieuXuatDetailView(soPhieu: item.soPhieu, existing: item, onSaveSuccess: {
                            Task {
                                await viewModel.loadData()
                            }
                        })
                    }
                } else {
                    selectedModalItem = item
                }
            }
            .contextMenu {
                Button {
                    router.showScreen(.push) { _ in
                        PhieuXuatDetailView(soPhieu: item.soPhieu, existing: item, onSaveSuccess: {
                            Task {
                                await viewModel.loadData()
                            }
                        })
                    }
                } label: {
                    Label(Strings.viewDetail, systemImage: "eye")
                }
                
                if hasDeletePermission {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label(Strings.deleteTicket, systemImage: "trash")
                    }
                }
            }
    }
}

struct PhieuXuatCardView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let hangBan = "Hàng bán"
        static let hangBanLabel = "Hàng bán:"
        static let thuVe = "hàng hoá"
        static let thuVeLabel = "Hàng thu về:"
        static let xeNgoai = "Xe ngoài:"
        static let emptyPlaceholder = "---"
    }

    let item: TPhieuvc_Xuat_DanhSach
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Dòng 1: Số phiếu : Ngày
            HStack(spacing: 8) {
                Text(item.soPhieu)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.vtsPrimary)
                
                Text(":")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.vtsPrimary)
                
                Text(item.ngay.toUIDateString)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.vtsPrimary)
                
                Spacer()
            }
            
            // Dòng 2: Checkbox Xe ngoài, Biển số xe, Tài xế
            HStack(spacing: 8) {
                Image(systemName: item.xeNgoai ? "checkmark.square.fill" : "square")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(item.xeNgoai ? .vtsPrimary : Color.primary.opacity(0.65))
                
                Text(Strings.xeNgoai)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vtsTxtPrimary)
                
                let soXeDisplay = item.soXe?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !soXeDisplay.isEmpty {
                    Text(soXeDisplay)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.vtsPrimary)
                }
                
                let driverDisplay = ((item.taiXe?.isEmpty == false ? item.taiXe : item.tenNhanVien) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !driverDisplay.isEmpty {
                    Text(driverDisplay)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.vtsTxtPrimary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Dòng 3: Hàng hoá : Khối lượng (ĐVT)
            HStack(spacing: 6) {
                Text(item.tenHangHoa)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.vtsPrimary)
                    .lineLimit(1)
                
                Text(":")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.vtsPrimary)
                
                let dvtSuffix = (item.dvt != nil && !item.dvt!.isEmpty) ? " (\(item.dvt!))" : ""
                Text("\(Double(item.trongLuongHang).toQuantityString())\(dvtSuffix)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.vtsPrimary)
                
                Spacer()
            }
            
            // Dòng 4: Khách hàng
            if let khach = item.tenKhachHang, !khach.isEmpty {
                Text(khach)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.vtsPrimary)
                    .lineLimit(2)
            }
            
            // Dòng 5: Hàng thu về (nếu có thông tin)
            let tenTV = (item.tenHangHoaTV?.isEmpty == false ? item.tenHangHoaTV : item.hangHoaTV)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if (!tenTV.isEmpty && tenTV != Strings.emptyPlaceholder) || item.trongLuongHangTV > 0 {
                HStack(spacing: 6) {
                    Text(Strings.thuVeLabel)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.vtsTxtPrimary)
                    
                    Text(tenTV.isEmpty ? Strings.thuVe : tenTV)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.vtsPrimary)
                        .lineLimit(1)
                    
                    Text(":")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.vtsPrimary)
                    
                    let dvtTVSuffix = (item.dvttv != nil && !item.dvttv!.isEmpty) ? " (\(item.dvttv!))" : ""
                    Text("\(Double(item.trongLuongHangTV).toQuantityString())\(dvtTVSuffix)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                    
                    Spacer()
                }
            }
            
            // Hàng bán / gia công (nếu có thông tin)
            let tenGC = (item.tenHangHoaGC?.isEmpty == false ? item.tenHangHoaGC : item.hangHoaGC)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if (!tenGC.isEmpty && tenGC != Strings.emptyPlaceholder) || item.trongLuongHangGC > 0 {
                HStack(spacing: 6) {
                    Text(Strings.hangBanLabel)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.vtsTxtPrimary)
                    
                    Text(tenGC.isEmpty ? Strings.hangBan : tenGC)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.vtsPrimary)
                        .lineLimit(1)
                    
                    Text(":")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.vtsPrimary)
                    
                    let dvtGCSuffix = (item.dvtgc != nil && !item.dvtgc!.isEmpty) ? " (\(item.dvtgc!))" : ""
                    Text("\(Double(item.trongLuongHangGC).toQuantityString())\(dvtGCSuffix)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.vtsPrimary)
                    
                    Spacer()
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
