//
//  HangHoaDetailView.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct HangHoaDetailView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: HangHoaDetailViewModel
    
    @State private var isEditMode: Bool = false
    private let initialEditMode: Bool
    
    @State private var ma: String = ""
    @State private var ten: String = ""
    @State private var dvt: String = ""
    @State private var selectedLoai: String = ""
    @State private var selectedNhom: String = ""
    @State private var ghiChu: String = ""
    @State private var isSaving: Bool = false
    
    private var hasEditPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_HANGHOA")?.edit == true
    }
    
    private var hasAddPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_HANGHOA")?.add == true
    }
    
    init(maHH: String?, isEditMode: Bool = false) {
        self.initialEditMode = isEditMode
        self._isEditMode = State(initialValue: isEditMode || maHH == nil || maHH?.isEmpty == true)
        _viewModel = StateObject(wrappedValue: HangHoaDetailViewModel(maHH: maHH))
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VTSAsyncContent(
                state: viewModel.state,
                emptyTitle: "Không thể tải dữ liệu",
                emptySubtitle: "Vui lòng kiểm tra kết nối mạng và thử lại.",
                emptyIcon: "exclamationmark.triangle.fill",
                retry: {
                    Task {
                        await viewModel.loadDetails()
                    }
                }
            ) { details in
                VStack(spacing: 0) {
                    // MARK: - Static Pinned Header Card
                    if let details = details {
                        profileHeaderCard(details: details)
                            .background(Color.vtsPrimary)
                    } else {
                        VStack(spacing: 4) {
                            Text("TẠO MỚI HÀNG HOÁ")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            Text("Nhập thông tin sản phẩm mới")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .background(Color.vtsPrimary)
                    }
                    
                    // MARK: - Scrollable Details Area
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            productInfoCard(details: details)
                        }
                        .padding(.horizontal, VTSSpacing.sm)
                        .padding(.vertical, 16)
                    }
                }
                .onAppear {
                    if let details = details {
                        populateFields(with: details)
                    }
                }
                .onChange(of: details?.ma) { _, _ in
                    if let details = details {
                        populateFields(with: details)
                    }
                }
            }
        }
        .task {
            await viewModel.loadDetails()
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: viewModel.isNew ? "Thêm hàng hoá mới" : (isEditMode ? "Chỉnh sửa hàng hoá" : "Thông tin hàng hoá"),
            isWhiteText: true,
            leading: {},
            trailing: {
                if isEditMode {
                    HStack(spacing: 16) {
                        if !viewModel.isNew {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isEditMode = false
                                }
                                if case .success(let details) = viewModel.state, let details = details {
                                    populateFields(with: details)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark")
                                    Text("Huỷ")
                                        .font(.vtsHeadline)
                                }
                                .foregroundColor(.red)
                            }
                            .disabled(isSaving)
                        }
                        
                        Button {
                            Task {
                                await saveProduct()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.primary)
                                } else {
                                    Image(systemName: "checkmark")
                                    Text("Lưu")
                                        .font(.vtsHeadline)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                        .disabled(isSaving)
                    }
                } else {
                    if hasEditPermission {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                
                                isEditMode = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.pencil")
                                Text("Sửa")
                                    .font(.vtsHeadline)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            },
            primaryAction: { EmptyView() }
        )
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            if viewModel.isNew {
                if !hasAddPermission {
                    isEditMode = false
                }
            } else {
                if isEditMode && !hasEditPermission {
                    isEditMode = false
                }
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func profileHeaderCard(details: THangHoa_ThongTin) -> some View {
        VStack {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Text(getInitials(name: details.ten ?? "HH"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(details.ten ?? "Hàng hoá")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Đơn vị tính")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                            Text(details.dvt ?? "—")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 1, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mã hàng hoá")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                            Text(details.ma ?? "—")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func productInfoCard(details: THangHoa_ThongTin?) -> some View {
        VTSGlassCard(padding: VTSSpacing.lg) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "box.trend.up.fill")
                        .foregroundColor(Color.vtsPrimary)
                    Text("Thông tin hàng hoá")
                        .font(.vtsHeadline.bold())
                        .foregroundColor(.vtsTxtPrimary)
                }
                Divider()
                
                if isEditMode {
                    VTSLiquidTextField(
                        label: "Mã hàng",
                        text: $ma,
                        isReadOnly: !viewModel.isNew
                    )
                    
                    VTSLiquidTextField(
                        label: "Tên hàng",
                        text: $ten,
                        isReadOnly: false
                    )
                    
                    VTSLiquidTextField(
                        label: "ĐVT (Đơn vị tính)",
                        text: $dvt,
                        isReadOnly: false
                    )
                    
                    VTSLiquidPickerField(
                        label: "Loại hàng",
                        selection: $selectedLoai,
                        options: [""] + viewModel.loaiHHs.map { $0.ma },
                        displayName: { code in
                            if code.isEmpty { return "Không chọn" }
                            return viewModel.loaiHHs.first(where: { $0.ma == code })?.ten ?? code
                        }
                    )
                    
                    VTSLiquidPickerField(
                        label: "Nhóm hàng",
                        selection: $selectedNhom,
                        options: [""] + viewModel.nhomHHs.map { $0.ma },
                        displayName: { code in
                            if code.isEmpty { return "Không chọn" }
                            return viewModel.nhomHHs.first(where: { $0.ma == code })?.ten ?? code
                        }
                    )
                } else {
                    infoRow(label: "Mã hàng", value: details?.ma ?? "", icon: "tag.fill")
                    infoRow(label: "Tên hàng", value: details?.ten ?? "", icon: "box.relative.open")
                    infoRow(label: "Đơn vị tính", value: details?.dvt ?? "", icon: "scalemass.fill")
                    
                    let loaiTen = viewModel.loaiHHs.first(where: { $0.ma == details?.loai })?.ten ?? details?.loai ?? ""
                    infoRow(label: "Loại hàng hoá", value: loaiTen, icon: "square.grid.3x3.fill")
                    
                    let nhomTen = viewModel.nhomHHs.first(where: { $0.ma == details?.nhom })?.ten ?? details?.nhom ?? ""
                    infoRow(label: "Nhóm hàng hoá", value: nhomTen, icon: "shippingbox.fill")
                }
                
                if isEditMode {
                    VTSTextArea(label: "Ghi chú", placeholder: "Thêm ghi chú...", text: $ghiChu, minHeight: 100)
                } else {
                    Text(details?.ghiChu ?? "Chưa có ghi chú nào")
                        .font(.vtsBody)
                        .foregroundColor(details?.ghiChu == nil ? .vtsTxtTertiary : .vtsTxtPrimary)
                        .padding(.vertical, 4)
                }
            }
        }
    }
    
    @ViewBuilder
    private func infoRow(label: String, value: String, icon: String) -> some View {
        Button {
            if !value.isEmpty {
                UIPasteboard.general.string = value
                ErrorManager.shared.showSuccess("Đã sao chép \(label.lowercased())")
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color.vtsPrimary)
                    .frame(width: 28, height: 28)
                    .background(Color.vtsPrimary.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.vtsCaption)
                        .foregroundColor(.vtsTxtSecondary)
                    
                    Text(value.isEmpty ? "Chưa thiết lập" : value)
                        .font(.vtsBody.bold())
                        .foregroundColor(value.isEmpty ? .vtsTxtTertiary : .vtsTxtPrimary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if !value.isEmpty {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundColor(.vtsTxtTertiary)
                        .padding(4)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func getInitials(name: String) -> String {
        let components = name.components(separatedBy: " ")
        let filtered = components.filter { !$0.isEmpty }
        if filtered.count >= 2 {
            let first = String(filtered[filtered.count - 2].prefix(1))
            let last = String(filtered[filtered.count - 1].prefix(1))
            return (first + last).uppercased()
        } else if let single = filtered.first {
            return String(single.prefix(2)).uppercased()
        }
        return "HH"
    }
    
    private func populateFields(with details: THangHoa_ThongTin) {
        self.ma = details.ma ?? ""
        self.ten = details.ten ?? ""
        self.dvt = details.dvt ?? ""
        self.selectedLoai = details.loai ?? ""
        self.selectedNhom = details.nhom ?? ""
        self.ghiChu = details.ghiChu ?? ""
    }
    
    private func saveProduct() async {
        if ma.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            router.showAlert(.alert, title: "Lỗi", subtitle: "Vui lòng nhập mã hàng hóa.") {
                Button("OK") {}
            }
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        let data = DataIn_List_HangHoa(
            ma: ma,
            ten: ten.isEmpty ? nil : ten,
            loai: selectedLoai.isEmpty ? nil : selectedLoai,
            nhom: selectedNhom.isEmpty ? nil : selectedNhom,
            dvt: dvt.isEmpty ? nil : dvt,
            ghiChu: ghiChu.isEmpty ? nil : ghiChu
        )
        
        do {
            if viewModel.isNew {
                let _ = try await HangHoaService.shared.them(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Thêm hàng hóa mới thành công.") {
                    Button("OK") {
                        router.dismissScreen()
                    }
                }
            } else {
                let _ = try await HangHoaService.shared.sua(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Cập nhật thông tin hàng hóa thành công.") {
                    Button("OK") {
                        isEditMode = false
                        Task {
                            await viewModel.loadDetails()
                        }
                    }
                }
            }
        } catch {
            router.showAlert(.alert, title: "Lỗi", subtitle: error.localizedDescription) {
                Button("OK") {}
            }
        }
    }
}

#Preview {
    let _ = AuthManager.shared.saveTokens(access: "mock_jwt_token_for_vts_staff_bypass", refresh: "mock_refresh")
    return RouterView { _ in
        HangHoaDetailView(maHH: "HH001")
    }
}
