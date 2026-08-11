//
//  PhieuXuatDetailView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import SwiftUI
import SwiftfulRouting
import PhotosUI

struct PhieuXuatDetailView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: PhieuXuatDetailViewModel
    
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
    @State private var hinh01Text: String? = nil
    @State private var hinh02Text: String? = nil
    @State private var showingImagePickerForSlot: Int? = nil // 1 or 2
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var showingCameraForSlot: Int? = nil // 1 or 2
    @State private var showingFullscreenIndex: Int? = nil // 1 or 2
    @State private var showingActionSheetForSlot: Int? = nil // 1 or 2
    @State private var editingImage: IdentifiableImage? = nil
    @State private var editingSlot: Int? = nil
    @State private var activeSlot: Int? = nil
    
    @State private var isSaving: Bool = false
    
    private var galleryItems: [VTSPhotoGalleryItem] {
        [
            VTSPhotoGalleryItem(id: 1, title: "Ảnh 1 - Phiếu xuất 1", image: hinh01, ocrText: hinh01Text),
            VTSPhotoGalleryItem(id: 2, title: "Ảnh 2 - Phiếu xuất 2", image: hinh02, ocrText: hinh02Text)
        ]
    }
    
    // Errors state
    @State private var soXeError: String? = nil
    @State private var taiXeError: String? = nil
    @State private var hangHoaError: String? = nil
    @State private var khachHangError: String? = nil
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
    
    private var currentNhanVienDisplay: String {
        if let found = viewModel.taiXeOptions.first(where: { $0.ma == taiXe }) {
            return found.ten
        }
        if case .success(let details) = viewModel.state, let details = details, let name = details.tenNhanVien, !name.isEmpty {
            return name
        }
        return taiXe.isEmpty ? "---" : taiXe
    }
    
    private var currentHangHoaDisplay: String {
        if let found = viewModel.hangHoaOptions.first(where: { $0.ma == hangHoa }) {
            return found.ten
        }
        if case .success(let details) = viewModel.state, let details = details, !details.tenHangHoa.isEmpty {
            return details.tenHangHoa
        }
        return hangHoa.isEmpty ? "---" : hangHoa
    }
    
    private var currentKhachHangDisplay: String {
        if let found = viewModel.khachHangOptions.first(where: { $0.ma == khachHang }) {
            return found.ten
        }
        if case .success(let details) = viewModel.state, let details = details, let name = details.tenKhachHang, !name.isEmpty {
            return name
        }
        return khachHang.isEmpty ? "---" : khachHang
    }
    
    private var headerTitleDisplay: String {
        if viewModel.isNew {
            return "Chuyến hàng giao mới"
        } else if isEditMode {
            return "Cập nhật chuyến hàng giao"
        } else {
            return "Thông tin chuyến hàng giao"
        }
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
                    VTSVoucherHeaderProfileCard(
                        iconName: "building.2.fill",
                        soXe: xeNgoai ? soXeNgoai : soXeNha,
                        tenNhanVien: currentNhanVienDisplay,
                        tenHangHoa: currentHangHoaDisplay,
                        trongLuongHang: trongLuongHang,
                        tenKhachHang: currentKhachHangDisplay
                    )
                    
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
            subtitle: headerTitleDisplay,
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
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let newItem = newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run {
                        let slot = showingImagePickerForSlot ?? activeSlot
                        showingImagePickerForSlot = nil
                        photoPickerItem = nil
                        editingSlot = slot
                        editingImage = IdentifiableImage(image: img)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { showingCameraForSlot != nil },
            set: { if !$0 { showingCameraForSlot = nil } }
        )) {
            let slot = showingCameraForSlot ?? activeSlot
            CameraView { capturedImg in
                showingCameraForSlot = nil
                editingSlot = slot
                editingImage = IdentifiableImage(image: capturedImg)
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(item: $editingImage) { item in
            VTSImageEditorView(
                inputImage: item.image,
                onSave: { croppedImg in
                    let target = editingSlot ?? activeSlot ?? 1
                    if target == 1 {
                        hinh01 = croppedImg
                        Task {
                            hinh01Text = await VTSImageOCRHelper.performOCR(on: croppedImg)
                        }
                    } else if target == 2 {
                        hinh02 = croppedImg
                        Task {
                            hinh02Text = await VTSImageOCRHelper.performOCR(on: croppedImg)
                        }
                    }
                    editingImage = nil
                    editingSlot = nil
                    activeSlot = nil
                },
                onCancel: {
                    editingImage = nil
                    editingSlot = nil
                    activeSlot = nil
                }
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: Binding(
            get: { showingFullscreenIndex != nil },
            set: { if !$0 { showingFullscreenIndex = nil } }
        )) {
            VTSPhotoGalleryView(
                items: galleryItems,
                selectedIndex: Binding(
                    get: { showingFullscreenIndex ?? 1 },
                    set: { showingFullscreenIndex = $0 }
                ),
                onClose: {
                    showingFullscreenIndex = nil
                }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: Binding(
            get: { showingActionSheetForSlot != nil },
            set: { if !$0 { showingActionSheetForSlot = nil } }
        )) {
            let slot = showingActionSheetForSlot
            VTSPhotoSourceSheet(
                onCamera: {
                    showingActionSheetForSlot = nil
                    activeSlot = slot
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingCameraForSlot = slot
                    }
                },
                onLibrary: {
                    showingActionSheetForSlot = nil
                    activeSlot = slot
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
    private func formFieldsCard(details: TPhieuvc_Xuat_DanhSach?) -> some View {
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
                    let upper = newValue.uppercased()
                    if soXeNgoai != upper {
                        soXeNgoai = upper
                    }
                    let normalizedInput = normalizePlate(upper)
                    if !normalizedInput.isEmpty,
                       let matchedXe = viewModel.xeOptions.first(where: {
                           normalizePlate($0.ma) == normalizedInput || normalizePlate($0.ten) == normalizedInput
                       }) {
                        xeNgoai = false
                        soXeNha = matchedXe.ma
                        soXeNgoai = ""
                        soXeError = nil
                        if !matchedXe.maTaiXe.isEmpty {
                            taiXe = matchedXe.maTaiXe
                        }
                    } else if !upper.isEmpty {
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
                            taiXe = foundXe.maTaiXe
                        }
                    }
                }
                .disabled(!isEditMode)
            }
            
            // Row 3: Tài xế (Picker nếu xe nhà, Text Input nếu xe ngoài)
            if xeNgoai {
                VTSLiquidTextField(
                    label: "Tài xế ngoài",
                    text: $taiXe,
                    placeholder: "Nhập tên tài xế...",
                    isReadOnly: !isEditMode,
                    errorMessage: taiXeError
                )
            } else {
                VTSLiquidPickerField(
                    label: "Tài xế",
                    selection: $taiXe,
                    options: viewModel.taiXeOptions.map { $0.ma },
                    displayName: { code in
                        viewModel.taiXeOptions.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: taiXeError
                )
                .disabled(!isEditMode)
            }
            
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
            
            // Row 5: Hàng giao
            VTSLiquidPickerField(
                label: "Hàng giao",
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
            
            // Row 9: Ghi chú
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingFullscreenIndex = slotIndex
                        }
                    
                    HStack(spacing: 6) {
                        Button {
                            showingFullscreenIndex = slotIndex
                        } label: {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        if isEditMode {
                            Button {
                                editingSlot = slotIndex
                                editingImage = IdentifiableImage(image: img)
                            } label: {
                                Image(systemName: "crop")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.8))
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
                    }
                    .padding(6)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                    
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.vtsPrimary.opacity(0.12))
                                .frame(width: 48, height: 48)
                            Image(systemName: "photo.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.vtsPrimary)
                        }
                        
                        Text(isEditMode ? "Thêm ảnh" : "Chưa có ảnh")
                            .font(.vtsCaption)
                            .foregroundColor(isEditMode ? .vtsTxtSecondary : .vtsTxtTertiary)
                    }
                }
                .frame(height: 130)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isEditMode {
                        showingActionSheetForSlot = slotIndex
                    }
                }
            }
        }
    }
    
    private func normalizePlate(_ input: String) -> String {
        input.uppercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
    
    private func populateFields(with details: TPhieuvc_Xuat_DanhSach) {
        ngay = Date.fromAPIString(details.ngay) ?? Date()
        xeNgoai = details.xeNgoai
        if details.xeNgoai {
            soXeNgoai = details.soXe ?? ""
            soXeNha = ""
            taiXe = details.taiXe ?? ""
        } else {
            soXeNha = details.soXe ?? ""
            soXeNgoai = ""
            taiXe = details.nhanVien ?? details.taiXe ?? ""
        }
        khachHang = details.khachHang ?? ""
        hangHoa = details.hangHoa
        if details.trongLuongHang > 0 {
            trongLuongHang = String(Int(details.trongLuongHang))
        } else {
            trongLuongHang = ""
        }
        ghiChu = details.ghiChu ?? ""
        trangThai = details.trangThai ?? "HT"
        
        if let img1 = UIImage.fromBase64(details.image1Base64) {
            hinh01 = img1
        }
        hinh01Text = details.hinh01NoiDungText
        
        if let img2 = UIImage.fromBase64(details.image2Base64) {
            hinh02 = img2
        }
        hinh02Text = details.hinh02NoiDungText
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
        let finalNhanVien: String? = xeNgoai ? nil : (taiXe.isEmpty ? nil : taiXe)
        let finalTaiXe: String? = xeNgoai ? (taiXe.isEmpty ? nil : taiXe) : nil
        
        do {
            if viewModel.isNew {
                let data = Params_ThemPhieu_Xuat(
                    ngay: ngay,
                    soThamChieu: nil,
                    xeNgoai: xeNgoai,
                    soXe: currentSoXe,
                    nhanVien: finalNhanVien,
                    taiXe: finalTaiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: thoiGianCanHang,
                    hinh01NoiDungText: hinh01Text,
                    hinh01NoiDung: hinh01Base64,
                    thoiGian02: thoiGianCanHang,
                    hinh02NoiDungText: hinh02Text,
                    hinh02NoiDung: hinh02Base64,
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
                    soXe: currentSoXe,
                    nhanVien: finalNhanVien,
                    taiXe: finalTaiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: thoiGianCanHang,
                    hinh01NoiDungText: hinh01Text,
                    hinh01NoiDung: hinh01Base64,
                    thoiGian02: thoiGianCanHang,
                    hinh02NoiDungText: hinh02Text,
                    hinh02NoiDung: hinh02Base64,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai,
                    soPhieu: viewModel.soPhieu,
                    xoaHinh01: false,
                    xoaHinh02: false
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
