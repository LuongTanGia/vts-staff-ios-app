//
//  NhanVienDetailView.swift
//  VTS_STAFF
//
//  Created by viettas on 25/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct NhanVienDetailView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let titleEdit = "Chỉnh sửa nhân viên"
        static let titleInfo = "Thông tin nhân viên"
        static let emptyTitle = "Không tìm thấy thông tin nhân viên"
        static let emptySubtitle = "Hồ sơ có thể đã bị xóa hoặc không hợp lệ."
        static let btnCancel = "Hủy"
        static let btnSave = "Lưu"
        static let btnEdit = "Sửa"
        static let btnOK = "OK"
        static let defaultEmployee = "Nhân viên"
        static let placeholderHyphen = "—"
        static let fieldHoVaTenDem = "Họ và tên đệm"
        static let fieldTen = "Tên"
        static let fieldNgaySinh = "Ngày sinh"
        static let fieldGioiTinh = "Giới tính"
        static let genderMale = "Nam"
        static let genderFemale = "Nữ"
        static let fieldSoCCCD = "Số căn cước"
        static let fieldDienThoai = "Điện thoại liên hệ"
        static let fieldEmail = "Email"
        static let fieldSoDuong = "Số, đường"
        static let fieldPhuongXa = "Phường, Xã"
        static let fieldTinhThanh = "Tỉnh, Thành"
        static let fieldGhiChu = "Ghi chú"
        static let unconfigured = "Chưa thiết lập"
        static let errHo = "Vui lòng nhập họ và tên đệm"
        static let errTen = "Vui lòng nhập tên"
        static let errNgaySinh = "Vui lòng nhập ngày sinh"
        static let errCCCD = "Vui lòng nhập số căn cước"
        static let errDiaChi = "Vui lòng nhập số nhà, tên đường"
        static let errPhuongXa = "Vui lòng chọn phường xã"
        static let alertInputErrorTitle = "Lỗi nhập liệu"
        static let alertInputErrorSub = "Vui lòng hoàn thiện các trường thông tin bắt buộc."
        static let alertSuccessTitle = "Thành công"
        static let alertUpdateSuccessSub = "Thông tin nhân viên đã được cập nhật."
        static let alertErrorTitle = "Lỗi"
        static func copiedMessage(_ label: String) -> String { "Đã sao chép \(label.lowercased())" }
    }
    
    @Environment(\.router) private var router
    @StateObject private var viewModel: NhanVienDetailViewModel
    
    @State private var isEditMode: Bool = false
    private let initialEditMode: Bool
    
    // Form fields State
    @State private var emHo: String = ""
    @State private var emTen: String = ""
    @State private var emNgaySinhStr: String = ""
    @State private var isFemale: Bool = false
    @State private var emDiaChiSoDuong: String = ""
    @State private var emDiaChiPhuongXa: String = ""
    @State private var emDiaChiTinhThanh: String = ""
    @State private var emDienThoai: String = ""
    @State private var emcccdppSo: String = ""
    @State private var emEmail: String = ""
    @State private var ghiChu: String = ""
    @State private var isSaving: Bool = false
    
    @State private var hoError: String? = nil
    @State private var tenError: String? = nil
    @State private var ngaySinhError: String? = nil
    @State private var cccdError: String? = nil

    @State private var diaChiError: String? = nil
    @State private var phuongXaError: String? = nil
    
    private var hasEditPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_NHANVIEN")?.edit == true
    }
    
    init(maNV: String, isEditMode: Bool = false) {
        self.initialEditMode = isEditMode
        self._isEditMode = State(initialValue: isEditMode)
        _viewModel = StateObject(wrappedValue: NhanVienDetailViewModel(maNV: maNV))
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VTSAsyncContent(
                state: viewModel.state,
                emptyTitle: Strings.emptyTitle,
                emptySubtitle: Strings.emptySubtitle,
                emptyIcon: "person.crop.circle.badge.exclamationmark",
                retry: {
                    Task {
                        await viewModel.loadDetails()
                    }
                }
            ) { details in
                VStack(spacing: 0) {
                    // MARK: - Static Pinned Profile & Job Header Card
                    profileHeaderCard(details: details)
                        .background(Color.vtsPrimary)
                    
                    // MARK: - Scrollable Details Area (Personal, Contact, Notes)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            personalInfoCard(details: details)
                        }
                        .padding(.horizontal, VTSSpacing.sm)
                        .padding(.vertical, 16)
                    }
                    
                    VTSCompanyFooter()
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    populateFields(with: details)
                }
                .onChange(of: details.emid) { _, _ in
                    populateFields(with: details)
                }
                .onChange(of: emDiaChiPhuongXa) { _, newPhuongXa in
                    if let found = viewModel.phuongXas.first(where: { $0.ma == newPhuongXa }) {
                        let ptTinhThanh = found.tinhThanh
                        if emDiaChiTinhThanh != ptTinhThanh {
                            emDiaChiTinhThanh = ptTinhThanh
                        }
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
            subtitle: isEditMode ? Strings.titleEdit : Strings.titleInfo,
            isWhiteText: true,
            leading: {},
            trailing: {
                if isEditMode {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isEditMode = false
                            }
                            if case .success(let details) = viewModel.state {
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
                        
                        Button {
                            Task {
                                await saveEmployeeDetails()
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
            primaryAction: {
                EmptyView()
            }
        )
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: emHo) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                hoError = nil
            }
        }
        .onChange(of: emTen) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tenError = nil
            }
        }
        .onChange(of: emNgaySinhStr) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ngaySinhError = nil
            }
        }
        .onChange(of: emcccdppSo) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                cccdError = nil
            }
        }
        
        .onChange(of: emDiaChiSoDuong) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                diaChiError = nil
            }
        }
        .onChange(of: emDiaChiPhuongXa) { _, newValue in
            if !newValue.isEmpty {
                phuongXaError = nil
            }
        }
        .onAppear {
            if isEditMode && !hasEditPermission {
                isEditMode = false
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func profileHeaderCard(details: TNhanVien_ThongTin) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                
                LucideIcon(.users, size: 24, color: Color(hex: "00497C"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                let fullName = getFullName(ho: emHo, ten: emTen)
                Text(fullName.isEmpty ? Strings.defaultEmployee : fullName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(details.emid ?? Strings.placeholderHyphen)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                let sub = details.emTenPhongBanHH ?? (details.emDienThoai ?? Strings.placeholderHyphen)
                Text(sub)
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
    private func personalInfoCard(details: TNhanVien_ThongTin) -> some View {
        VTSLiquidFormCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    VTSLiquidTextField(
                        label: Strings.fieldHoVaTenDem,
                        text: $emHo,
                        isReadOnly: !isEditMode,
                        errorMessage: hoError
                    )
                    
                    VTSLiquidTextField(
                        label: Strings.fieldTen,
                        text: $emTen,
                        isReadOnly: !isEditMode,
                        errorMessage: tenError
                    )
                    .frame(width: 120)
                }
                
                HStack(spacing: 12) {
                    VTSLiquidTextField(
                        label: Strings.fieldNgaySinh,
                        text: $emNgaySinhStr,
                        isReadOnly: !isEditMode,
                        errorMessage: ngaySinhError
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Strings.fieldGioiTinh)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "475569"))
                            .padding(.leading, 4)
                        Picker(Strings.fieldGioiTinh, selection: $isFemale) {
                            Text(Strings.genderMale).tag(false)
                            Text(Strings.genderFemale).tag(true)
                        }
                        .pickerStyle(.segmented)
                        .disabled(!isEditMode)
                    }
                }
                
                VTSLiquidTextField(
                    label: Strings.fieldSoCCCD,
                    text: $emcccdppSo,
                    keyboardType: .numberPad,
                    isReadOnly: !isEditMode,
                    errorMessage: cccdError
                )
                
                VTSLiquidTextField(
                    label: Strings.fieldDienThoai,
                    text: $emDienThoai,
                    keyboardType: .phonePad,
                    isReadOnly: !isEditMode
                )
                
                VTSLiquidTextField(
                    label: Strings.fieldEmail,
                    text: $emEmail,
                    keyboardType: .emailAddress,
                    isReadOnly: !isEditMode
                )
                
                VTSLiquidTextField(
                    label: Strings.fieldSoDuong,
                    text: $emDiaChiSoDuong,
                    isReadOnly: !isEditMode,
                    errorMessage: diaChiError
                )
                
                VTSLiquidPickerField(
                    label: Strings.fieldPhuongXa,
                    selection: $emDiaChiPhuongXa,
                    options: {
                        var list = viewModel.phuongXas.map { $0.ma }
                        if !emDiaChiPhuongXa.isEmpty && !list.contains(emDiaChiPhuongXa) {
                            list.insert(emDiaChiPhuongXa, at: 0)
                        }
                        return list
                    }(),
                    displayName: { code in
                        if let found = viewModel.phuongXas.first(where: { $0.ma == code }) {
                            return found.ten
                        }
                        if case .success(let details) = viewModel.state, details.emDiaChiPhuongXa == code {
                            return details.emDiaChiTenPhuongXa ?? code
                        }
                        return code
                    },
                    displaySubtitle: { code in
                        if let found = viewModel.phuongXas.first(where: { $0.ma == code }) {
                            return found.tenTinhThanh
                        }
                        if case .success(let details) = viewModel.state, details.emDiaChiPhuongXa == code {
                            return details.emDiaChiTenTinhThanh ?? ""
                        }
                        return ""
                    },
                    errorMessage: phuongXaError
                )
                .disabled(!isEditMode)
                
                VTSLiquidTextField(
                    label: Strings.fieldTinhThanh,
                    text: Binding(
                        get: {
                            if let found = viewModel.phuongXas.first(where: { $0.ma == emDiaChiPhuongXa }) {
                                return found.tenTinhThanh
                            }
                            if case .success(let details) = viewModel.state {
                                return details.emDiaChiTenTinhThanh ?? ""
                            }
                            return ""
                        },
                        set: { _ in }
                    ),
                    isReadOnly: true
                )
                
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
    
    // MARK: - Helpers
    
    private func getFullName(ho: String?, ten: String?) -> String {
        let hoStr = ho ?? ""
        let tenStr = ten ?? ""
        if hoStr.isEmpty { return tenStr }
        if tenStr.isEmpty { return hoStr }
        return "\(hoStr) \(tenStr)"
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
        return "NV"
    }
    
    private func getFullAddress(details: TNhanVien_ThongTin) -> String {
        var parts: [String] = []
        if let st = details.emDiaChiSoDuong, !st.isEmpty { parts.append(st) }
        if let px = details.emDiaChiTenPhuongXa, !px.isEmpty { parts.append(px) }
        if let tt = details.emDiaChiTenTinhThanh, !tt.isEmpty { parts.append(tt) }
        return parts.joined(separator: ", ")
    }
    
    private func populateFields(with details: TNhanVien_ThongTin) {
        self.emHo = details.emHo ?? ""
        self.emTen = details.emTen ?? ""
        self.emNgaySinhStr = (details.emNgaySinh ?? "").toDisplayDate()
        self.isFemale = details.emGioiTinh == 0
        self.emDienThoai = details.emDienThoai ?? ""
        self.emcccdppSo = details.emcccdppSo ?? ""
        self.emEmail = details.emEmail ?? ""
        self.emDiaChiSoDuong = details.emDiaChiSoDuong ?? ""
        self.emDiaChiPhuongXa = details.emDiaChiPhuongXa ?? ""
        self.emDiaChiTinhThanh = details.emDiaChiTinhThanh ?? ""
        self.ghiChu = details.ghiChu ?? ""
    }
    
    private func saveEmployeeDetails() async {
        var hasError = false
        
        if emHo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hoError = Strings.errHo
            hasError = true
        } else {
            hoError = nil
        }
        
        if emTen.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tenError = Strings.errTen
            hasError = true
        } else {
            tenError = nil
        }
        
        if emNgaySinhStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ngaySinhError = Strings.errNgaySinh
            hasError = true
        } else {
            ngaySinhError = nil
        }
        
        if emcccdppSo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cccdError = Strings.errCCCD
            hasError = true
        } else {
            cccdError = nil
        }
        
        if emDiaChiSoDuong.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            diaChiError = Strings.errDiaChi
            hasError = true
        } else {
            diaChiError = nil
        }
        
        if emDiaChiPhuongXa.isEmpty {
            phuongXaError = Strings.errPhuongXa
            hasError = true
        } else {
            phuongXaError = nil
        }
        
        if hasError {
            router.showAlert(.alert, title: Strings.alertInputErrorTitle, subtitle: Strings.alertInputErrorSub) {
                Button(Strings.btnOK) {}
            }
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        let birthDate = emNgaySinhStr.toDate(format: "dd/MM/yyyy")
        
        let data = DataIn_NhanVien(
            emid: viewModel.maNV,
            emHo: emHo,
            emTen: emTen,
            emGioiTinh: isFemale ? 0 : 1,
            emNgaySinh: birthDate,
            emDienThoai: emDienThoai,
            emEmail: emEmail,
            emDiaChi_SoDuong: emDiaChiSoDuong,
            emDiaChi_PhuongXa: emDiaChiPhuongXa,
            emDiaChi_TinhThanh: emDiaChiTinhThanh,
            emDiaChi_QuocGia: "VN",
            emcccdpp_So: emcccdppSo,
            ghiChu: ghiChu
        )
        
        do {
            let _ = try await NhanVienService.shared.sua(data)
            router.showAlert(.alert, title: Strings.alertSuccessTitle, subtitle: Strings.alertUpdateSuccessSub) {
                Button(Strings.btnOK) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isEditMode = false
                    }
                    Task {
                        await viewModel.loadDetails()
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
        NhanVienDetailView(maNV: "NV001")
    }
}
