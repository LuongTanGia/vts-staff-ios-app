//
//  PhieuNhapDetailView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import SwiftUI
import SwiftfulRouting
import PhotosUI

struct PhieuNhapDetailView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: PhieuNhapDetailViewModel
    
    @State private var isEditMode: Bool = false
    private let initialEditMode: Bool
    
    // Form fields State
    @State private var ngay: Date = Date()
    @State private var xeNgoai: Bool = false
    @State private var soXeNgoai: String = ""
    @State private var soXeNha: String = ""
    @State private var taiXe: String = ""
    @State private var khachHang: String = ""
    @State private var hangHoa: String = ""
    @State private var trongLuongHang: String = ""
    @State private var thoiGianCanHang: Date = Date()
    @State private var ghiChu: String = ""
    @State private var trangThai: String = "HT"
    
    // Image states
    @State private var hinh01: UIImage? = nil
    @State private var hinh02: UIImage? = nil
    @State private var showingImagePickerForSlot: Int? = nil // 1 or 2
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var showingCameraForSlot: Int? = nil // 1 or 2
    @State private var showingFullscreenImage: UIImage? = nil
    @State private var showingActionSheetForSlot: Int? = nil // 1 or 2
    
    @State private var isSaving: Bool = false
    
    // Errors state
    @State private var soXeError: String? = nil
    @State private var taiXeError: String? = nil
    @State private var hangHoaError: String? = nil
    @State private var khachHangError: String? = nil
    @State private var trongLuongHangError: String? = nil
    
    private var hasEditPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUNHAP")?.edit == true
    }
    
    private var hasAddPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUNHAP")?.add == true
    }
    
    private var hasDeletePermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUNHAP")?.del == true
    }
    
    init(soPhieu: String?, existing: TPhieuvc_Nhap_DanhSach? = nil, isEditMode: Bool = false) {
        self.initialEditMode = isEditMode
        self._isEditMode = State(initialValue: isEditMode || soPhieu == nil || soPhieu?.isEmpty == true)
        _viewModel = StateObject(wrappedValue: PhieuNhapDetailViewModel(soPhieu: soPhieu))
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VTSAsyncContent(
                state: viewModel.state,
                emptyTitle: "Không tìm thấy thông tin phiếu nhập",
                emptySubtitle: "Số phiếu có thể không tồn tại hoặc đã bị xóa.",
                emptyIcon: "doc.text.fill",
                retry: {
                    Task {
                        await viewModel.loadDetails()
                    }
                }
            ) { details in
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            formFieldsCard(details: details)
                            
                            if !viewModel.isNew && isEditMode && hasDeletePermission {
                                Button(role: .destructive) {
                                    router.showAlert(.alert, title: "Xác nhận xoá", subtitle: "Bạn có chắc chắn muốn xoá phiếu nhập này?") {
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
                                        Text("Xoá phiếu nhập")
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
                    
                    VTSCompanyFooter()
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
            title: "VTS-Staff",
            subtitle: "Thông tin chuyến hàng nhận",
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
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark")
                                    Text("Lưu")
                                        .font(.vtsHeadline)
                                }
                            }
                            .foregroundColor(.white)
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
                            .foregroundColor(.white)
                        }
                    }
                }
            },
            primaryAction: {
                EmptyView()
            }
        )
        .toolbar(.hidden, for: .tabBar)
        .photosPicker(isPresented: Binding(
            get: { showingImagePickerForSlot != nil },
            set: { if !$0 { showingImagePickerForSlot = nil } }
        ), selection: $photoPickerItem, matching: .images)
        .onChange(of: photoPickerItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run {
                        if showingImagePickerForSlot == 1 {
                            hinh01 = img
                        } else if showingImagePickerForSlot == 2 {
                            hinh02 = img
                        }
                        showingImagePickerForSlot = nil
                        photoPickerItem = nil
                    }
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { showingCameraForSlot != nil },
            set: { if !$0 { showingCameraForSlot = nil } }
        )) {
            let slot = showingCameraForSlot
            CameraView { capturedImg in
                if slot == 1 {
                    hinh01 = capturedImg
                } else if slot == 2 {
                    hinh02 = capturedImg
                }
                showingCameraForSlot = nil
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: Binding(
            get: { showingFullscreenImage != nil },
            set: { if !$0 { showingFullscreenImage = nil } }
        )) {
            if let img = showingFullscreenImage {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                    Button {
                        showingFullscreenImage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { showingActionSheetForSlot != nil },
            set: { if !$0 { showingActionSheetForSlot = nil } }
        )) {
            let slot = showingActionSheetForSlot
            VTSPhotoSourceSheet(
                onCamera: {
                    showingActionSheetForSlot = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingCameraForSlot = slot
                    }
                },
                onLibrary: {
                    showingActionSheetForSlot = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingImagePickerForSlot = slot
                    }
                },
                onCancel: {
                    showingActionSheetForSlot = nil
                }
            )
        }
    }
    
    @ViewBuilder
    private func formFieldsCard(details: TPhieuvc_Nhap_DanhSach?) -> some View {
        VTSLiquidFormCard {
            // Row 1: Số phiếu & Ngày
            HStack(spacing: 12) {
                VTSLiquidReadonlyField(viewModel.soPhieu ?? "", caption: "Số phiếu")
                
                VTSLiquidDateTimeField(label: "Ngày", date: $ngay, displayStyle: .dateOnly)
            }
            
            // Row 2: Số xe ngoài & Số xe nhà
            HStack(spacing: 12) {
                VTSLiquidTextField(
                    label: "Số xe ngoài",
                    text: $soXeNgoai,
                    isReadOnly: !isEditMode
                )
                .onChange(of: soXeNgoai) { _, newValue in
                    if !newValue.isEmpty {
                        xeNgoai = true
                        soXeNha = ""
                        soXeError = nil
                    }
                }
                
                VTSLiquidPickerField(
                    label: "Số xe nhà",
                    selection: $soXeNha,
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
                .onChange(of: soXeNha) { _, newSoXe in
                    if !newSoXe.isEmpty {
                        xeNgoai = false
                        soXeNgoai = ""
                        soXeError = nil
                        if let foundXe = viewModel.xeOptions.first(where: { $0.ma == newSoXe }) {
                            taiXe = foundXe.tenTaiXe
                        }
                    }
                }
                .disabled(!isEditMode)
            }
            
            // Row 3: Tài xế
            VTSLiquidTextField(
                label: "Tài xế",
                text: $taiXe,
                isReadOnly: !isEditMode,
                errorMessage: taiXeError
            )
            
            // Row 4: Khách hàng
            VTSLiquidPickerField(
                label: "Khách hàng",
                selection: $khachHang,
                options: viewModel.khachHangOptions.map { $0.ma },
                displayName: { code in
                    viewModel.khachHangOptions.first(where: { $0.ma == code })?.ten ?? code
                },
                errorMessage: khachHangError
            )
            .disabled(!isEditMode)
            
            // Row 5: Hàng nhận
            VTSLiquidPickerField(
                label: "Hàng nhận",
                selection: $hangHoa,
                options: viewModel.hangHoaOptions.map { $0.ma },
                displayName: { code in
                    viewModel.hangHoaOptions.first(where: { $0.ma == code })?.ten ?? code
                },
                errorMessage: hangHoaError
            )
            .disabled(!isEditMode)
            
            // Row 6: Số/Trọng lượng
            VTSLiquidTextField(
                label: "Số/Trọng lượng",
                text: $trongLuongHang,
                keyboardType: .numberPad,
                isReadOnly: !isEditMode,
                errorMessage: trongLuongHangError
            )
            
            // Row 7: Thời gian cân hàng
            VTSLiquidDateTimeField(
                label: "Thời gian cân hàng",
                date: $thoiGianCanHang,
                displayStyle: .dateTime
            )
            .disabled(!isEditMode)
            
            // Row 8: 2 ô ảnh
            HStack(spacing: 12) {
                photoBox(
                    slotIndex: 1,
                    iconName: "camera.badge.plus",
                    image: $hinh01
                )
                
                photoBox(
                    slotIndex: 2,
                    iconName: "photo.badge.arrow.up",
                    image: $hinh02
                )
            }
            
            // Row 9: Ghi chú (nếu có hoặc trong edit mode)
            VTSLiquidTextField(
                label: "Ghi chú",
                text: $ghiChu,
                placeholder: "Nhập ghi chú...",
                isReadOnly: !isEditMode
            )
        }
    }
    
    @ViewBuilder
    private func photoBox(slotIndex: Int, iconName: String, image: Binding<UIImage?>) -> some View {
        ZStack {
            if let img = image.wrappedValue {
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 130)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                    
                    if isEditMode {
                        HStack(spacing: 6) {
                            Button {
                                showingFullscreenImage = img
                            } label: {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            
                            Button {
                                image.wrappedValue = nil
                            } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red.opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(6)
                    }
                }
            } else {
                Button {
                    if isEditMode {
                        showingActionSheetForSlot = slotIndex
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .systemGray4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                            )
                        
                        Image(systemName: iconName)
                            .font(.system(size: 52, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .frame(height: 130)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .disabled(!isEditMode)
            }
        }
    }
    
    private func populateFields(with details: TPhieuvc_Nhap_DanhSach) {
        ngay = Date.fromAPIString(details.ngay) ?? Date()
        xeNgoai = details.xeNgoai
        if details.xeNgoai {
            soXeNgoai = details.soXe ?? ""
            soXeNha = ""
        } else {
            soXeNha = details.soXe ?? ""
            soXeNgoai = ""
        }
        taiXe = details.taiXe ?? ""
        khachHang = details.khachHang ?? ""
        hangHoa = details.hangHoa
        if details.trongLuongHang > 0 {
            trongLuongHang = String(Int(details.trongLuongHang))
        } else {
            trongLuongHang = ""
        }
        ghiChu = details.ghiChu ?? ""
        trangThai = details.trangThai ?? "HT"
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        
        let currentSoXe = xeNgoai ? soXeNgoai : soXeNha
        if currentSoXe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            soXeError = "Không được để trống."
            isValid = false
        } else {
            soXeError = nil
        }
        
        if khachHang.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            khachHangError = "Không được để trống."
            isValid = false
        } else {
            khachHangError = nil
        }
        
        if hangHoa.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hangHoaError = "Không được để trống."
            isValid = false
        } else {
            hangHoaError = nil
        }
        
        if trongLuongHang.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            trongLuongHangError = "Không được để trống."
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
        
        let hinh01Base64 = hinh01?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        let hinh02Base64 = hinh02?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        let currentSoXe = xeNgoai ? soXeNgoai : soXeNha
        
        do {
            if viewModel.isNew {
                let data = Params_ThemPhieu_Nhap(
                    ngay: ngay,
                    soThamChieu: nil,
                    xeNgoai: xeNgoai,
                    soXe: currentSoXe,
                    nhanVien: nil,
                    taiXe: taiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: thoiGianCanHang,
                    hinh01NoiDungText: nil,
                    hinh01NoiDung: hinh01Base64,
                    thoiGian02: thoiGianCanHang,
                    hinh02NoiDungText: nil,
                    hinh02NoiDung: hinh02Base64,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai
                )
                let _ = try await PhieuNhapService.shared.them(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Tạo phiếu nhập mới thành công.") {
                    Button("Xong") {
                        router.dismissScreen()
                    }
                }
            } else {
                let data = Params_SuaPhieu_Nhap(
                    ngay: ngay,
                    soThamChieu: nil,
                    xeNgoai: xeNgoai,
                    soXe: currentSoXe,
                    nhanVien: nil,
                    taiXe: taiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: thoiGianCanHang,
                    hinh01NoiDungText: nil,
                    hinh01NoiDung: hinh01Base64,
                    thoiGian02: thoiGianCanHang,
                    hinh02NoiDungText: nil,
                    hinh02NoiDung: hinh02Base64,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai,
                    soPhieu: viewModel.soPhieu,
                    xoaHinh01: false,
                    xoaHinh02: false
                )
                let _ = try await PhieuNhapService.shared.sua(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Cập nhật phiếu nhập thành công.") {
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
            let _ = try await PhieuNhapService.shared.xoa(soPhieu: soPhieu)
            router.showAlert(.alert, title: "Thành công", subtitle: "Đã xoá phiếu nhập.") {
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
