//
//  NhanVienDetailView.swift
//  VTS_STAFF
//
//  Created by viettas on 25/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct NhanVienDetailView: View {
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
                emptyTitle: "Không tìm thấy thông tin nhân viên",
                emptySubtitle: "Hồ sơ có thể đã bị xóa hoặc không hợp lệ.",
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
                }
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
            subtitle: isEditMode ? "Chỉnh sửa nhân viên" : "Thông tin nhân viên",
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
                                Image(systemName: "xmark")
                                Text("Huỷ")
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
        VStack {
            HStack(spacing: 16) {
                // Avatar with initials
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Text(getInitials(name: getFullName(ho: emHo, ten: emTen)))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    let fullName = getFullName(ho: emHo, ten: emTen)
                    Text(fullName.isEmpty ? "Nhân viên" : fullName)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    // Job Information (Moved up to header card)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Phòng ban")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                            Text(details.emTenPhongBanHH ?? "Chưa phân phòng")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 1, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ngày vào làm")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                            Text((details.emNgayBatDauHH ?? "").toDisplayDate())
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
    private func personalInfoCard(details: TNhanVien_ThongTin) -> some View {
        VTSGlassCard(padding: VTSSpacing.lg) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "person.text.rectangle.fill")
                        .foregroundColor(Color.vtsPrimary)
                    Text("Hồ sơ cá nhân")
                        .font(.vtsHeadline.bold())
                        .foregroundColor(.vtsTxtPrimary)
                }
                Divider()
                
                if isEditMode {
                    HStack(spacing: 12) {
                        VTSLiquidTextField(label: "Họ và tên đệm", text: $emHo, isReadOnly: false, errorMessage: hoError)
                        VTSLiquidTextField(label: "Tên", text: $emTen, isReadOnly: false, errorMessage: tenError)
                            .frame(width: 120)
                    }
                    
                    HStack(spacing: 12) {
                        VTSLiquidTextField(label: "Ngày sinh", text: $emNgaySinhStr, isReadOnly: false, errorMessage: ngaySinhError)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Giới tính")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                            Picker("Giới tính", selection: $isFemale) {
                                Text("Nam").tag(false)
                                Text("Nữ").tag(true)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    
                    VTSLiquidTextField(label: "Số căn cước", text: $emcccdppSo, keyboardType: .numberPad, isReadOnly: false, errorMessage: cccdError)
                } else {
                    infoRow(label: "Họ và tên", value: getFullName(ho: details.emHo, ten: details.emTen), icon: "person.fill")
                    infoRow(label: "Giới tính", value: details.emGioiTinh == 0 ? "Nữ" : "Nam", icon: "figure.dress.line.vertical.figure.wave")
                    infoRow(label: "Ngày sinh", value: (details.emNgaySinh ?? "").toDisplayDate(), icon: "calendar")
                    infoRow(label: "Số căn cước (CCCD)", value: details.emcccdppSo ?? "", icon: "doc.text.viewfinder")
                }
                
                if isEditMode {
                    VTSLiquidTextField(label: "Điện thoại liên hệ", text: $emDienThoai, keyboardType: .phonePad, isReadOnly: false)
                    VTSLiquidTextField(label: "Email", text: $emEmail, keyboardType: .emailAddress, isReadOnly: false)
                    VTSLiquidTextField(label: "Số, đường", text: $emDiaChiSoDuong, isReadOnly: false, errorMessage: diaChiError)
                    
                    VTSLiquidPickerField(
                        label: "Phường, Xã",
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
                    
                    VTSLiquidTextField(
                        label: "Tỉnh, Thành",
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
                } else {
                    infoRow(label: "Điện thoại di động", value: details.emDienThoai ?? "", icon: "phone.fill")
                    infoRow(label: "Thư điện tử (Email)", value: details.emEmail ?? "", icon: "envelope.fill")
                    
                    let address = getFullAddress(details: details)
                    infoRow(label: "Địa chỉ thường trú", value: address, icon: "mappin.and.ellipse")
                }
                
                if isEditMode {
                    VTSTextArea(label: "Nội dung ghi chú", placeholder: "Thêm ghi chú...", text: $ghiChu, minHeight: 100)
                } else {
                    Text(details.ghiChu ?? "Chưa có ghi chú nào")
                        .font(.vtsBody)
                        .foregroundColor(details.ghiChu == nil ? .vtsTxtTertiary : .vtsTxtPrimary)
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
            hoError = "Vui lòng nhập họ và tên đệm"
            hasError = true
        } else {
            hoError = nil
        }
        
        if emTen.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tenError = "Vui lòng nhập tên"
            hasError = true
        } else {
            tenError = nil
        }
        
        if emNgaySinhStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ngaySinhError = "Vui lòng nhập ngày sinh"
            hasError = true
        } else {
            ngaySinhError = nil
        }
        
        if emcccdppSo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cccdError = "Vui lòng nhập số căn cước"
            hasError = true
        } else {
            cccdError = nil
        }
        
        
        
        if emDiaChiSoDuong.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            diaChiError = "Vui lòng nhập số nhà, tên đường"
            hasError = true
        } else {
            diaChiError = nil
        }
        
        if emDiaChiPhuongXa.isEmpty {
            phuongXaError = "Vui lòng chọn phường xã"
            hasError = true
        } else {
            phuongXaError = nil
        }
        
        if hasError {
            router.showAlert(.alert, title: "Lỗi nhập liệu", subtitle: "Vui lòng hoàn thiện các trường thông tin bắt buộc.") {
                Button("OK") {}
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
            router.showAlert(.alert, title: "Thành công", subtitle: "Thông tin nhân viên đã được cập nhật.") {
                Button("OK") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isEditMode = false
                    }
                    Task {
                        await viewModel.loadDetails()
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
        NhanVienDetailView(maNV: "NV001")
    }
}
