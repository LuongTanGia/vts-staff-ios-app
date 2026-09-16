//
//  XeDetailView.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct XeDetailView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let titleNew = "Thêm xe mới"
        static let titleEdit = "Chỉnh sửa xe nhà"
        static let titleInfo = "Thông tin xe nhà"
        static let emptyTitle = "Không thể tải dữ liệu"
        static let emptySubtitle = "Vui lòng kiểm tra kết nối mạng và thử lại."
        static let btnCancel = "Hủy"
        static let btnSave = "Lưu"
        static let btnEdit = "Sửa"
        static let btnOK = "OK"
        static let defaultNewVehicle = "Tạo mới phương tiện"
        static let defaultVehicle = "Phương tiện"
        static let placeholderHyphen = "—"
        static let fieldBienSo = "Biển số"
        static let fieldTenGoiNho = "Tên gợi nhớ của xe"
        static let fieldLoaiXe = "Loại xe"
        static let fieldNhomXe = "Nhóm xe"
        static let fieldTaiXeCoDinh = "Tài xế cố định"
        static let fieldGhiChu = "Ghi chú"
        static let optionNone = "Không chọn"
        static let unconfigured = "Chưa thiết lập"
        static let errBienSo = "Vui lòng nhập biển số xe"
        static let errTenXe = "Vui lòng nhập tên xe"
        static let errLoaiXe = "Vui lòng chọn loại xe"
        static let errNhomXe = "Vui lòng chọn nhóm xe"
        static let errTaiXe = "Vui lòng chọn tài xế"
        static let alertInputErrorTitle = "Lỗi nhập liệu"
        static let alertInputErrorSub = "Vui lòng hoàn thiện các trường thông tin bắt buộc."
        static let alertSuccessTitle = "Thành công"
        static let alertAddSuccessSub = "Thêm phương tiện mới thành công."
        static let alertUpdateSuccessSub = "Cập nhật thông tin phương tiện thành công."
        static let alertErrorTitle = "Lỗi"
        static func copiedMessage(_ label: String) -> String { "Đã sao chép \(label.lowercased())" }
    }
    
    @Environment(\.router) private var router
    @StateObject private var viewModel: XeDetailViewModel
    
    @State private var isEditMode: Bool = false
    private let initialEditMode: Bool
    
    @State private var ma: String = ""
    @State private var ten: String = ""
    @State private var selectedLoai: String = ""
    @State private var selectedNhom: String = ""
    @State private var selectedTaiXe: String = ""
    @State private var ghiChu: String = ""
    @State private var isSaving: Bool = false
    
    @State private var maError: String? = nil
    @State private var tenError: String? = nil
    @State private var loaiError: String? = nil
    @State private var nhomError: String? = nil
    @State private var taiXeError: String? = nil
    
    private var hasEditPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_XE")?.edit == true
    }
    
    private var hasAddPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_XE")?.add == true
    }
    
    init(maXe: String?, isEditMode: Bool = false) {
        self.initialEditMode = isEditMode
        self._isEditMode = State(initialValue: isEditMode || maXe == nil || maXe?.isEmpty == true)
        _viewModel = StateObject(wrappedValue: XeDetailViewModel(maXe: maXe))
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VTSAsyncContent(
                state: viewModel.state,
                emptyTitle: Strings.emptyTitle,
                emptySubtitle: Strings.emptySubtitle,
                emptyIcon: "exclamationmark.triangle.fill",
                retry: {
                    Task {
                        await viewModel.loadData()
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
                            vehicleInfoCard(details: details)
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
            await viewModel.loadData()
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: viewModel.isNew ? Strings.titleNew : (isEditMode ? Strings.titleEdit : Strings.titleInfo),
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
                                    Text(Strings.btnCancel)
                                        .font(.vtsHeadline)
                                }
                                .foregroundColor(.red)
                            }
                            .disabled(isSaving)
                        }
                        
                        Button {
                            Task {
                                await saveVehicle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.primary)
                                } else {
                                    LucideIcon(.check, size: 18)
                                    Text(Strings.btnSave)
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
                                Text(Strings.btnEdit)
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
        .onChange(of: selectedLoai) { _, newValue in
            if !newValue.isEmpty {
                loaiError = nil
            }
        }
        .onChange(of: selectedNhom) { _, newValue in
            if !newValue.isEmpty {
                nhomError = nil
            }
        }
        .onChange(of: selectedTaiXe) { _, newValue in
            if !newValue.isEmpty {
                taiXeError = nil
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
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                
                LucideIcon(.truck, size: 24, color: Color(hex: "00497C"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ma.isEmpty ? (viewModel.isNew ? Strings.defaultNewVehicle : Strings.defaultVehicle) : ma)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(ten.isEmpty ? Strings.placeholderHyphen : ten)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                let txTen = selectedTaiXe.isEmpty ? (selectedLoai.isEmpty ? Strings.placeholderHyphen : (viewModel.loaiXes.first(where: { $0.ma == selectedLoai })?.ten ?? selectedLoai)) : (viewModel.taiXes.first(where: { $0.ma == selectedTaiXe })?.ten ?? selectedTaiXe)
                Text(txTen)
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
    private func vehicleInfoCard(details: TXe_ThongTin?) -> some View {
        VTSLiquidFormCard {
            VStack(alignment: .leading, spacing: 14) {
                VTSLiquidTextField(
                    label: Strings.fieldBienSo,
                    text: $ma,
                    isReadOnly: !viewModel.isNew || !isEditMode,
                    errorMessage: maError
                )
                
                VTSLiquidTextField(
                    label: Strings.fieldTenGoiNho,
                    text: $ten,
                    isReadOnly: !isEditMode,
                    errorMessage: tenError
                )
                
                VTSLiquidPickerField(
                    label: Strings.fieldLoaiXe,
                    selection: $selectedLoai,
                    options: [""] + viewModel.loaiXes.map { $0.ma },
                    displayName: { code in
                        if code.isEmpty { return Strings.optionNone }
                        return viewModel.loaiXes.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: loaiError
                )
                .disabled(!isEditMode)
                
                VTSLiquidPickerField(
                    label: Strings.fieldNhomXe,
                    selection: $selectedNhom,
                    options: [""] + viewModel.nhomXes.map { $0.ma },
                    displayName: { code in
                        if code.isEmpty { return Strings.optionNone }
                        return viewModel.nhomXes.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: nhomError
                )
                .disabled(!isEditMode)
                
                VTSLiquidPickerField(
                    label: Strings.fieldTaiXeCoDinh,
                    selection: $selectedTaiXe,
                    options: [""] + viewModel.taiXes.map { $0.ma },
                    displayName: { code in
                        if code.isEmpty { return Strings.optionNone }
                        return viewModel.taiXes.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: taiXeError
                )
                .disabled(!isEditMode)
                
                VTSLiquidTextField(
                    label: Strings.fieldGhiChu,
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
                ErrorManager.shared.showSuccess(Strings.copiedMessage(label))
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
                    
                    Text(value.isEmpty ? Strings.unconfigured : value)
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
        return "XE"
    }
    
    private func populateFields(with details: TXe_ThongTin) {
        self.ma = details.ma
        self.ten = details.ten
        self.selectedLoai = details.loai
        self.selectedNhom = details.nhom ?? ""
        self.selectedTaiXe = details.taiXe
        self.ghiChu = details.ghiChu ?? ""
    }
    
    private func saveVehicle() async {
        var hasError = false
        
        if ma.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            maError = Strings.errBienSo
            hasError = true
        } else {
            maError = nil
        }
        
        if ten.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tenError = Strings.errTenXe
            hasError = true
        } else {
            tenError = nil
        }
        
        if selectedLoai.isEmpty {
            loaiError = Strings.errLoaiXe
            hasError = true
        } else {
            loaiError = nil
        }
        
        if selectedNhom.isEmpty {
            nhomError = Strings.errNhomXe
            hasError = true
        } else {
            nhomError = nil
        }
        
        if selectedTaiXe.isEmpty {
            taiXeError = Strings.errTaiXe
            hasError = true
        } else {
            taiXeError = nil
        }
        
        if hasError {
            router.showAlert(.alert, title: Strings.alertInputErrorTitle, subtitle: Strings.alertInputErrorSub) {
                Button(Strings.btnOK) {}
            }
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        let data = DataIn_List_Xe(
            ma: ma,
            ten: ten.isEmpty ? nil : ten,
            loai: selectedLoai.isEmpty ? nil : selectedLoai,
            nhom: selectedNhom.isEmpty ? nil : selectedNhom,
            taiXe: selectedTaiXe.isEmpty ? nil : selectedTaiXe,
            ghiChu: ghiChu.isEmpty ? nil : ghiChu
        )
        
        do {
            if viewModel.isNew {
                let _ = try await XeService.shared.them(data)
                router.showAlert(.alert, title: Strings.alertSuccessTitle, subtitle: Strings.alertAddSuccessSub) {
                    Button(Strings.btnOK) {
                        router.dismissScreen()
                    }
                }
            } else {
                let _ = try await XeService.shared.sua(data)
                router.showAlert(.alert, title: Strings.alertSuccessTitle, subtitle: Strings.alertUpdateSuccessSub) {
                    Button(Strings.btnOK) {
                        isEditMode = false
                        Task {
                            await viewModel.loadData()
                        }
                    }
                }
            }
        } catch {
            router.showAlert(.alert, title: Strings.alertErrorTitle, subtitle: error.localizedDescription) {
                Button(Strings.btnOK) {}
            }
        }
    }
}

#Preview {
    let _ = AuthManager.shared.saveTokens(access: "mock_jwt_token_for_vts_staff_bypass", refresh: "mock_refresh")
    return RouterView { _ in
        XeDetailView(maXe: nil)
    }
}
