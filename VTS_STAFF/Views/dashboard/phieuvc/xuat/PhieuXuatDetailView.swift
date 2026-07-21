//
//  PhieuXuatDetailView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import SwiftUI
import SwiftfulRouting

struct PhieuXuatDetailView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: PhieuXuatDetailViewModel
    
    @State private var isEditMode: Bool = false
    private let initialEditMode: Bool
    
    // Form fields State
    @State private var ngay: Date = Date()
    @State private var soThamChieu: String = ""
    @State private var xeNgoai: Bool = false
    @State private var soXe: String = ""
    @State private var taiXe: String = ""
    @State private var khachHang: String = ""
    @State private var hangHoa: String = ""
    @State private var trongLuongXe: String = ""
    @State private var trongLuongHang: String = ""
    @State private var ghiChu: String = ""
    @State private var trangThai: String = "HT"
    @State private var isSaving: Bool = false
    
    // Errors state
    @State private var soXeError: String? = nil
    @State private var taiXeError: String? = nil
    @State private var hangHoaError: String? = nil
    @State private var khachHangError: String? = nil
    @State private var trongLuongXeError: String? = nil
    @State private var trongLuongHangError: String? = nil
    
    private var hasEditPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUXUAT")?.edit == true
    }
    
    private var hasAddPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUXUAT")?.add == true
    }
    
    private var hasDeletePermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUXUAT")?.del == true
    }
    
    init(soPhieu: String?, existing: TPhieuvc_Xuat_DanhSach? = nil, isEditMode: Bool = false) {
        self.initialEditMode = isEditMode
        self._isEditMode = State(initialValue: isEditMode || soPhieu == nil || soPhieu?.isEmpty == true)
        _viewModel = StateObject(wrappedValue: PhieuXuatDetailViewModel(soPhieu: soPhieu))
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VTSAsyncContent(
                state: viewModel.state,
                emptyTitle: "Không tìm thấy thông tin phiếu xuất",
                emptySubtitle: "Số phiếu có thể không tồn tại hoặc đã bị xóa.",
                emptyIcon: "doc.text.fill",
                retry: {
                    Task {
                        await viewModel.loadDetails()
                    }
                }
            ) { details in
                VStack(spacing: 0) {
                    // Pinned Header Card
                    profileHeaderCard(details: details)
                        .background(Color.vtsPrimary)
                    
                    // Scrollable Form details
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            formFieldsCard(details: details)
                            

                            
                            if !viewModel.isNew && isEditMode && hasDeletePermission {
                                Button(role: .destructive) {
                                    router.showAlert(.alert, title: "Xác nhận xoá", subtitle: "Bạn có chắc chắn muốn xoá phiếu xuất này?") {
                                        Button("Xoá", role: .destructive) {
                                            Task {
                                                await deleteVoucher()
                                            }
                                        }
                                        Button("Huỷ", role: .cancel) {}
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Xoá phiếu xuất")
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red.opacity(0.8))
                                    )
                                }
                                .padding(.horizontal, 4)
                                .padding(.top, 8)
                            }
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
                .onChange(of: details?.soPhieu) { _, _ in
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
            subtitle: viewModel.isNew ? "Thêm phiếu xuất" : (isEditMode ? "Chỉnh sửa phiếu xuất" : "Thông tin phiếu xuất"),
            isWhiteText: true,
            leading: {},
            trailing: {
                if isEditMode {
                    HStack(spacing: 16) {
                        Button {
                            if viewModel.isNew {
                                router.dismissScreen()
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isEditMode = false
                                }
                                if case .success(let details) = viewModel.state, let details = details {
                                    populateFields(with: details)
                                }
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
                                await saveVoucher()
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
    }
    
    @ViewBuilder
    private func profileHeaderCard(details: TPhieuvc_Xuat_DanhSach?) -> some View {
        VStack {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 54, height: 54)
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isNew ? "Phiếu xuất mới" : "Số: \(details?.soPhieu ?? "")")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text(viewModel.isNew ? "Trạng thái: Mới" : "Trạng thái: \(details?.tenTrangThai ?? "")")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func formFieldsCard(details: TPhieuvc_Xuat_DanhSach?) -> some View {
        VTSLiquidFormCard {
            if !isEditMode, let d = details {
                infoRow(label: "Số phiếu", value: d.soPhieu, icon: "number")
                infoRow(label: "Ngày lập phiếu", value: d.ngay.toUIDateString, icon: "calendar")
                infoRow(label: "Xe ngoài", value: d.xeNgoai ? "Có" : "Không", icon: "car.2.fill")
                infoRow(label: "Số xe", value: d.soXe ?? "", icon: "car.fill")
                infoRow(label: "Tài xế", value: d.taiXe ?? "", icon: "person.fill")
                infoRow(label: "Khách hàng", value: (((d.tenKhachHang?.isEmpty) != nil) ? d.khachHang : d.tenKhachHang) ?? "", icon: "building.2.fill")
                infoRow(label: "Hàng hoá", value: d.tenHangHoa.isEmpty ? d.hangHoa : d.tenHangHoa, icon: "shippingbox.fill")
                infoRow(label: "Trọng lượng xe", value: "\(Int(d.trongLuongXe)) kg", icon: "scalemass.fill")
                infoRow(label: "Trọng lượng hàng", value: "\(Int(d.trongLuongHang)) kg", icon: "scalemass")
                infoRow(label: "Trạng thái", value: d.tenTrangThai ?? "", icon: "info.circle.fill")
                infoRow(label: "Ghi chú", value: d.ghiChu ?? "", icon: "note.text")
            } else {
                VTSLiquidDateTimeField(label: "Ngày lập phiếu", date: $ngay, displayStyle: .dateTime)
                
                Toggle(isOn: $xeNgoai) {
                    HStack(spacing: 8) {
                        Image(systemName: "car.2.fill")
                            .foregroundColor(.vtsPrimary)
                        Text("Xe ngoài")
                            .font(.system(size: 15, weight: .medium))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                
                if xeNgoai {
                    VTSLiquidTextField(label: "Số xe", text: $soXe, placeholder: "Nhập số xe...", errorMessage: soXeError)
                    VTSLiquidTextField(label: "Tài xế", text: $taiXe, placeholder: "Nhập tên tài xế...", errorMessage: taiXeError)
                } else {
                    VTSLiquidPickerField(
                        label: "Số xe",
                        selection: $soXe,
                        options: viewModel.xeOptions.map { $0.ma },
                        displayName: { code in
                            viewModel.xeOptions.first(where: { $0.ma == code })?.ten ?? code
                        },
                        displaySubtitle: { code in
                            if let xe = viewModel.xeOptions.first(where: { $0.ma == code }) {
                                return "Tài xế: \(xe.tenTaiXe)"
                            }
                            return ""
                        },
                        errorMessage: soXeError
                    )
                    .onChange(of: soXe) { _, newSoXe in
                        if let foundXe = viewModel.xeOptions.first(where: { $0.ma == newSoXe }) {
                            taiXe = foundXe.tenTaiXe
                        }
                    }
                    
                    VTSLiquidPickerField(
                        label: "Tài xế",
                        selection: $taiXe,
                        options: viewModel.taiXeOptions.map { $0.ten },
                        displayName: { $0 },
                        errorMessage: taiXeError
                    )
                }
                
                VTSLiquidPickerField(
                    label: "Khách hàng",
                    selection: $khachHang,
                    options: viewModel.khachHangOptions.map { $0.ma },
                    displayName: { code in
                        viewModel.khachHangOptions.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: khachHangError
                )
                
                VTSLiquidPickerField(
                    label: "Hàng hoá",
                    selection: $hangHoa,
                    options: viewModel.hangHoaOptions.map { $0.ma },
                    displayName: { code in
                        viewModel.hangHoaOptions.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: hangHoaError
                )
                
                HStack(spacing: 12) {
                    VTSLiquidTextField(label: "Trọng lượng xe (kg)", text: $trongLuongXe, keyboardType: .numberPad, errorMessage: trongLuongXeError)
                    VTSLiquidTextField(label: "Trọng lượng hàng (kg)", text: $trongLuongHang, keyboardType: .numberPad, errorMessage: trongLuongHangError)
                }
                
                VTSLiquidPickerField(
                    label: "Trạng thái",
                    selection: $trangThai,
                    options: viewModel.statusOptions.map { $0.ma },
                    displayName: { code in
                        viewModel.statusOptions.first(where: { $0.ma == code })?.ten ?? code
                    }
                )
                
                VTSLiquidTextField(label: "Ghi chú", text: $ghiChu, placeholder: "Nhập ghi chú...")
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
                    Text(value.isEmpty ? "—" : value)
                        .font(.vtsBody.bold())
                        .foregroundColor(value.isEmpty ? .vtsTxtTertiary : .vtsTxtPrimary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if !value.isEmpty {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundColor(.vtsTxtTertiary)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    
    private func populateFields(with details: TPhieuvc_Xuat_DanhSach) {
        ngay = Date.fromAPIString(details.ngay) ?? Date()
        xeNgoai = details.xeNgoai
        soXe = details.soXe ?? ""
        taiXe = details.taiXe ?? ""
        khachHang = details.khachHang ?? ""
        hangHoa = details.hangHoa
        trongLuongXe = String(Int(details.trongLuongXe))
        trongLuongHang = String(Int(details.trongLuongHang))
        ghiChu = details.ghiChu ?? ""
        trangThai = details.trangThai ?? ""
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        
        if soXe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            soXeError = "Vui lòng nhập hoặc chọn số xe"
            isValid = false
        } else {
            soXeError = nil
        }
        
        if taiXe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            taiXeError = "Vui lòng nhập hoặc chọn tài xế"
            isValid = false
        } else {
            taiXeError = nil
        }
        
        if khachHang.isEmpty {
            khachHangError = "Vui lòng chọn khách hàng"
            isValid = false
        } else {
            khachHangError = nil
        }
        
        if hangHoa.isEmpty {
            hangHoaError = "Vui lòng chọn hàng hoá"
            isValid = false
        } else {
            hangHoaError = nil
        }
        
        if trongLuongXe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            trongLuongXeError = "Nhập trọng lượng xe"
            isValid = false
        } else if Double(trongLuongXe) == nil {
            trongLuongXeError = "Số không hợp lệ"
            isValid = false
        } else {
            trongLuongXeError = nil
        }
        
        if trongLuongHang.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            trongLuongHangError = "Nhập trọng lượng hàng"
            isValid = false
        } else if Double(trongLuongHang) == nil {
            trongLuongHangError = "Số không hợp lệ"
            isValid = false
        } else {
            trongLuongHangError = nil
        }
        
        return isValid
    }
    
    private func saveVoucher() async {
        guard validateForm() else {
            router.showAlert(.alert, title: "Lỗi nhập liệu", subtitle: "Vui lòng kiểm tra lại các trường thông tin.") {
                Button("OK") {}
            }
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            if viewModel.isNew {
                let data = Params_ThemPhieu_Xuat(
                    ngay: ngay,
                    soThamChieu: nil,
                    xeNgoai: xeNgoai,
                    soXe: soXe,
                    nhanVien: nil,
                    taiXe: taiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: Double(trongLuongXe) ?? 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: nil, hinh01NoiDungText: nil, hinh01NoiDung: nil,
                    thoiGian02: nil, hinh02NoiDungText: nil, hinh02NoiDung: nil,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai
                )
                let _ = try await PhieuXuatService.shared.them(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Tạo phiếu xuất mới thành công.") {
                    Button("Xong") {
                        router.dismissScreen()
                    }
                }
            } else {
                let data = Params_SuaPhieu_Xuat(
                    ngay: ngay,
                    soThamChieu: nil,
                    xeNgoai: xeNgoai,
                    soXe: soXe,
                    nhanVien: nil,
                    taiXe: taiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: Double(trongLuongXe) ?? 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: nil, hinh01NoiDungText: nil, hinh01NoiDung: nil,
                    thoiGian02: nil, hinh02NoiDungText: nil, hinh02NoiDung: nil,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai,
                    soPhieu: viewModel.soPhieu,
                    xoaHinh01: false, xoaHinh02: false
                )
                let _ = try await PhieuXuatService.shared.sua(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Cập nhật phiếu xuất thành công.") {
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
    
    private func deleteVoucher() async {
        guard let soPhieu = viewModel.soPhieu else { return }
        do {
            let _ = try await PhieuXuatService.shared.xoa(soPhieu: soPhieu)
            router.showAlert(.alert, title: "Thành công", subtitle: "Đã xoá phiếu xuất.") {
                Button("OK") {
                    router.dismissScreen()
                }
            }
        } catch {
            router.showAlert(.alert, title: "Lỗi xoá phiếu", subtitle: error.localizedDescription) {
                Button("OK") {}
            }
        }
    }
}
