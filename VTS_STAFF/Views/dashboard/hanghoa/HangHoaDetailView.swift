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
    
    @State private var maError: String? = nil
    @State private var tenError: String? = nil
    @State private var dvtError: String? = nil

    
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
                    profileHeaderCard()
                        .background(Color.vtsPrimary)
                    
                    // MARK: - Scrollable Details Area
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            productInfoCard(details: details)
                        }
                        .padding(.horizontal, VTSSpacing.sm)
                        .padding(.vertical, 16)
                    }
                    
                    VTSCompanyFooter()
                }
                .ignoresSafeArea(edges: .bottom)
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
                                    LucideIcon(.x, size: 18)
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
                                    LucideIcon(.check, size: 18)
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
                                LucideIcon(.pencil, size: 18)
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
        .onChange(of: ma) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                maError = nil
            }
        }
        .onChange(of: ten) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tenError = nil
            }
        }
        .onChange(of: dvt) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                dvtError = nil
            }
        }
        
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
    private func profileHeaderCard() -> some View {
        HStack(alignment: .center, spacing: 14) {
            // Left Icon (White circle with dark icon matching Android)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                
                LucideIcon(.package, size: 24, color: Color(hex: "00497C"))
            }
            
            // Middle Info Column (Matching Android screenshot)
            VStack(alignment: .leading, spacing: 2) {
                Text(ten.isEmpty ? (viewModel.isNew ? "Tạo mới hàng hoá" : "Hàng hoá") : ten)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(ma.isEmpty ? "—" : ma)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                let subDetails = [
                    selectedLoai.isEmpty ? nil : (viewModel.loaiHHs.first(where: { $0.ma == selectedLoai })?.ten ?? selectedLoai),
                    dvt.isEmpty ? nil : "(\(dvt))"
                ].compactMap { $0 }.joined(separator: " ")
                
                Text(subDetails.isEmpty ? (dvt.isEmpty ? "—" : dvt) : subDetails)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private func productInfoCard(details: THangHoa_ThongTin?) -> some View {
        VTSLiquidFormCard {
            VStack(alignment: .leading, spacing: 14) {
                VTSLiquidTextField(
                    label: "Mã hàng",
                    text: $ma,
                    isReadOnly: !viewModel.isNew || !isEditMode,
                    errorMessage: maError
                )
                
                VTSLiquidTextField(
                    label: "Tên hàng",
                    text: $ten,
                    isReadOnly: !isEditMode,
                    errorMessage: tenError
                )
                
                VTSLiquidTextField(
                    label: "ĐVT (Đơn vị tính)",
                    text: $dvt,
                    isReadOnly: !isEditMode,
                    errorMessage: dvtError
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
                .disabled(!isEditMode)
                
                VTSLiquidPickerField(
                    label: "Nhóm hàng",
                    selection: $selectedNhom,
                    options: [""] + viewModel.nhomHHs.map { $0.ma },
                    displayName: { code in
                        if code.isEmpty { return "Không chọn" }
                        return viewModel.nhomHHs.first(where: { $0.ma == code })?.ten ?? code
                    }
                )
                .disabled(!isEditMode)
                
                VTSLiquidTextField(
                    label: "Ghi chú",
                    text: $ghiChu,
                    placeholder: "",
                    isReadOnly: !isEditMode
                )
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
                LucideIcon(icon, size: 20, color: .vtsPrimary)
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
                    LucideIcon(.copy, size: 14, color: .vtsTxtTertiary)
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
        var hasError = false
        
        if ma.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            maError = "Vui lòng nhập mã hàng hóa"
            hasError = true
        } else {
            maError = nil
        }
        
        if ten.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tenError = "Vui lòng nhập tên hàng hóa"
            hasError = true
        } else {
            tenError = nil
        }
        
        if dvt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            dvtError = "Vui lòng nhập đơn vị tính"
            hasError = true
        } else {
            dvtError = nil
        }
        
        
        
        if hasError {
            router.showAlert(.alert, title: "Lỗi nhập liệu", subtitle: "Vui lòng hoàn thiện các trường thông tin bắt buộc.") {
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
