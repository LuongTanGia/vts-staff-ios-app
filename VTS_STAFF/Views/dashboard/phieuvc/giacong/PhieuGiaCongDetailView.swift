//
//  PhieuGiaCongDetailView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import SwiftUI
import SwiftfulRouting
import PhotosUI

struct PhieuGiaCongDetailView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: PhieuGiaCongDetailViewModel
    
    @State private var isEditMode: Bool = false
    private let initialEditMode: Bool
    
    // Form fields State
    @State private var ngay: Date = Date()
    @State private var soThamChieu: String = ""
    @State private var xeNgoai: Bool = false
    @State private var soXeNgoai: String = ""
    @State private var soXeNha: String = ""
    @State private var taiXe: String = ""
    @State private var khachHang: String = ""
    @State private var hangHoa: String = ""
    @State private var trongLuongXe: String = ""
    @State private var trongLuongHang: String = ""
    @State private var ghiChu: String = ""
    @State private var trangThai: String = "HT"
    
    // Gia Cong & Thu Hoi specific fields
    @State private var hangHoaGC: String = ""
    @State private var trongLuongHangGC: String = ""
    @State private var hangHoaTV: String = ""
    @State private var trongLuongHangTV: String = ""
    
    // Image states (6 slots)
    @State private var hinh01: UIImage? = nil
    @State private var hinh02: UIImage? = nil
    @State private var hinh03: UIImage? = nil
    @State private var hinh04: UIImage? = nil
    @State private var hinh05: UIImage? = nil
    @State private var hinh06: UIImage? = nil
    
    @State private var hinh01Text: String? = nil
    @State private var hinh02Text: String? = nil
    @State private var hinh03Text: String? = nil
    @State private var hinh04Text: String? = nil
    @State private var hinh05Text: String? = nil
    @State private var hinh06Text: String? = nil
    
    @State private var thoiGian01: Date? = nil
    @State private var thoiGian02: Date? = nil
    @State private var thoiGian03: Date? = nil
    @State private var thoiGian04: Date? = nil
    @State private var thoiGian05: Date? = nil
    @State private var thoiGian06: Date? = nil
    
    @State private var showingImagePickerForSlot: Int? = nil // 1..6
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var showingCameraForSlot: Int? = nil // 1..6
    @State private var showingFullscreenIndex: Int? = nil // 1..6
    @State private var showingActionSheetForSlot: Int? = nil // 1..6
    @State private var editingImage: IdentifiableImage? = nil
    @State private var editingSlot: Int? = nil
    @State private var activeSlot: Int? = nil
    
    @State private var isSaving: Bool = false
    
    private var galleryItems: [VTSPhotoGalleryItem] {
        [
            VTSPhotoGalleryItem(id: 1, title: "Ảnh 1 - Hàng hoá chính 1", image: hinh01, ocrText: hinh01Text),
            VTSPhotoGalleryItem(id: 2, title: "Ảnh 2 - Hàng hoá chính 2", image: hinh02, ocrText: hinh02Text),
            VTSPhotoGalleryItem(id: 3, title: "Ảnh 3 - Hàng gia công 1", image: hinh03, ocrText: hinh03Text),
            VTSPhotoGalleryItem(id: 4, title: "Ảnh 4 - Hàng gia công 2", image: hinh04, ocrText: hinh04Text),
            VTSPhotoGalleryItem(id: 5, title: "Ảnh 5 - Hàng thu hồi 1", image: hinh05, ocrText: hinh05Text),
            VTSPhotoGalleryItem(id: 6, title: "Ảnh 6 - Hàng thu hồi 2", image: hinh06, ocrText: hinh06Text)
        ]
    }
    
    // Errors state
    @State private var soXeError: String? = nil
    @State private var taiXeError: String? = nil
    @State private var hangHoaError: String? = nil
    @State private var khachHangError: String? = nil
    @State private var trongLuongHangError: String? = nil
    
    private var hasEditPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUGIACONG")?.edit == true
    }
    
    private var hasAddPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUGIACONG")?.add == true
    }
    
    private var hasDeletePermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DULIEU_PHIEUGIACONG")?.del == true
    }
    
    private func normalizePlate(_ text: String) -> String {
        return text.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
            .uppercased()
    }
    
    private var currentTaiXeDisplay: String {
        if let found = viewModel.taiXeOptions.first(where: { $0.ma == taiXe }) {
            return found.ten
        }
        if let foundNV = viewModel.nhanVienOptions.first(where: { $0.emid == taiXe }) {
            return foundNV.emHoTen
        }
        if case .success(let details) = viewModel.state, let details = details {
            if let name = details.taiXe, !name.isEmpty {
                return name
            }
            if let name = details.tenNhanVien, !name.isEmpty {
                return name
            }
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
            return "Chuyến hàng gia công mới"
        } else if isEditMode {
            return "Cập nhật chuyến hàng gia công"
        } else {
            return "Thông tin chuyến hàng gia công"
        }
    }
    
    var onSaveSuccess: (() -> Void)? = nil
    
    init(soPhieu: String?, existing: TPhieuvc_Giacong_DanhSach? = nil, isEditMode: Bool = false, onSaveSuccess: (() -> Void)? = nil) {
        self.initialEditMode = isEditMode
        self.onSaveSuccess = onSaveSuccess
        self._isEditMode = State(initialValue: isEditMode || soPhieu == nil || soPhieu?.isEmpty == true)
        _viewModel = StateObject(wrappedValue: PhieuGiaCongDetailViewModel(soPhieu: soPhieu))
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VTSAsyncContent(
                state: viewModel.state,
                emptyTitle: "Không tìm thấy thông tin phiếu gia công",
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
                        soXe: (xeNgoai ? soXeNgoai : soXeNha).isEmpty ? "---" : (xeNgoai ? soXeNgoai : soXeNha),
                        tenNhanVien: currentTaiXeDisplay,
                        tenHangHoa: currentHangHoaDisplay,
                        trongLuongHang: trongLuongHang,
                        tenKhachHang: currentKhachHangDisplay
                    )
                    
                    // Scrollable Form details
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            formFieldsCard(details: details)
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
            leading: { EmptyView() },
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
                                LucideIcon(.x, size: 18)
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
                                    LucideIcon(.check, size: 18)
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
                                LucideIcon(.pencil, size: 18)
                                Text("Sửa")
                                    .font(.vtsHeadline)
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
            },
            primaryAction: { EmptyView() }
        )
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
        .photosPicker(
            isPresented: Binding(
                get: { showingImagePickerForSlot != nil },
                set: { if !$0 { showingImagePickerForSlot = nil } }
            ),
            selection: $photoPickerItem,
            matching: .images
        )
        .onChange(of: photoPickerItem) { newItem in
            guard let newItem = newItem else { return }
            let slot = showingImagePickerForSlot ?? activeSlot
            showingImagePickerForSlot = nil
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        editingSlot = slot
                        editingImage = IdentifiableImage(image: uiImage)
                        photoPickerItem = nil
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
                    switch target {
                    case 1:
                        hinh01 = croppedImg
                        thoiGian01 = Date()
                        Task { hinh01Text = await VTSImageOCRHelper.performOCR(on: croppedImg) }
                    case 2:
                        hinh02 = croppedImg
                        thoiGian02 = Date()
                        Task { hinh02Text = await VTSImageOCRHelper.performOCR(on: croppedImg) }
                    case 3:
                        hinh03 = croppedImg
                        thoiGian03 = Date()
                        Task { hinh03Text = await VTSImageOCRHelper.performOCR(on: croppedImg) }
                    case 4:
                        hinh04 = croppedImg
                        thoiGian04 = Date()
                        Task { hinh04Text = await VTSImageOCRHelper.performOCR(on: croppedImg) }
                    case 5:
                        hinh05 = croppedImg
                        thoiGian05 = Date()
                        Task { hinh05Text = await VTSImageOCRHelper.performOCR(on: croppedImg) }
                    case 6:
                        hinh06 = croppedImg
                        thoiGian06 = Date()
                        Task { hinh06Text = await VTSImageOCRHelper.performOCR(on: croppedImg) }
                    default: break
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
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func profileHeaderCard(details: TPhieuvc_Giacong_DanhSach?) -> some View {
        VStack(spacing: VTSSpacing.xs) {
            HStack(spacing: VTSSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    LucideIcon(.cog, size: 22, color: .white)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(details?.soPhieu.isEmpty == false ? details!.soPhieu : "Phiếu gia công mới")
                        .font(.vtsTitle)
                        .foregroundColor(.white)
                    
                    if let d = details {
                        Text("\(d.tenKhachHang ?? "Chưa chọn KH") • \(d.tenHangHoa)")
                            .font(.vtsCaption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                VTSBadge(
                    details?.tenTrangThai ?? (isEditMode ? "Đang tạo" : "Mới"),
                    color: .white
                )
            }
        }
        .padding(.horizontal, VTSSpacing.md)
        .padding(.vertical, VTSSpacing.sm)
    }
    
    @ViewBuilder
    private func formFieldsCard(details: TPhieuvc_Giacong_DanhSach?) -> some View {
        VTSLiquidFormCard {
            VStack(alignment: .leading, spacing: 14) {
                // Row 1: Left Số phiếu (Readonly) & Right Date field "Ngày"
                HStack(spacing: 12) {
                    VTSLiquidTextField(
                        label: "Số phiếu",
                        text: .constant((details?.soPhieu ?? viewModel.soPhieu) ?? "—"),
                        isReadOnly: true
                    )
                    .frame(maxWidth: .infinity)
                    
                    VTSLiquidDateTimeField(
                        label: "Ngày",
                        date: $ngay,
                        displayStyle: .dateOnly,
                        isReadOnly: !isEditMode
                    )
                    .frame(maxWidth: .infinity)
                }
                
                // Row 2: Số xe ngoài (Left) & Số xe nhà (Right)
                HStack(spacing: 12) {
                    VTSLiquidTextField(
                        label: "Số xe ngoài",
                        text: $soXeNgoai,
                        placeholder: "",
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
                
                // Row 3: Tài xế / Nhân viên (Picker nếu xe nhà, Text Input nếu xe ngoài)
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
                
                // Row 6: Số lượng (Hàng giao)
                VTSLiquidTextField(
                    label: "Số lượng",
                    text: $trongLuongHang,
                    keyboardType: .decimalPad,
                    isReadOnly: !isEditMode,
                    errorMessage: trongLuongHangError
                )
                
                // Row 7: Thời điểm giao hàng
                VTSLiquidDateTimeField(
                    label: "Thời điểm giao hàng",
                    date: Binding(
                        get: { thoiGian01 ?? Date() },
                        set: { thoiGian01 = $0; thoiGian02 = $0 }
                    ),
                    displayStyle: .dateTime,
                    isReadOnly: !isEditMode
                )
                
                // Row 8: Photo 1 & 2 for Hàng giao
                if isEditMode || hinh01 != nil || hinh02 != nil {
                    HStack(spacing: 12) {
                        photoBox(slotIndex: 1, image: $hinh01)
                        photoBox(slotIndex: 2, image: $hinh02)
                    }
                }
                
                // Row 9: Hàng bán
                VTSLiquidPickerField(
                    label: "Hàng bán",
                    selection: $hangHoaGC,
                    options: [""] + viewModel.hangHoaOptions.map { $0.ma },
                    displayName: { code in
                        code.isEmpty ? "Hàng bán" : (viewModel.hangHoaOptions.first(where: { $0.ma == code })?.ten ?? code)
                    }
                )
                .disabled(!isEditMode)
                
                // Row 10: Số lượng (Hàng bán)
                VTSLiquidTextField(
                    label: "Số lượng",
                    text: $trongLuongHangGC,
                    keyboardType: .decimalPad,
                    isReadOnly: !isEditMode
                )
                
                // Row 11: Thời điểm cân hàng bán
                VTSLiquidDateTimeField(
                    label: "Thời điểm cân hàng bán",
                    date: Binding(
                        get: { thoiGian03 ?? Date() },
                        set: { thoiGian03 = $0; thoiGian04 = $0 }
                    ),
                    displayStyle: .dateTime,
                    isReadOnly: !isEditMode
                )
                
                // Row 12: Photo 3 & 4 for Hàng bán
                if isEditMode || hinh03 != nil || hinh04 != nil {
                    HStack(spacing: 12) {
                        photoBox(slotIndex: 3, image: $hinh03)
                        photoBox(slotIndex: 4, image: $hinh04)
                    }
                }
                
                // Row 13: Hàng thu về
                VTSLiquidPickerField(
                    label: "Hàng thu về",
                    selection: $hangHoaTV,
                    options: [""] + viewModel.hangHoaOptions.map { $0.ma },
                    displayName: { code in
                        code.isEmpty ? "Hàng thu về" : (viewModel.hangHoaOptions.first(where: { $0.ma == code })?.ten ?? code)
                    }
                )
                .disabled(!isEditMode)
                
                // Row 14: Số lượng (Hàng thu về)
                VTSLiquidTextField(
                    label: "Số lượng",
                    text: $trongLuongHangTV,
                    keyboardType: .decimalPad,
                    isReadOnly: !isEditMode
                )
                
                // Row 15: Thời điểm cân hàng thu về
                VTSLiquidDateTimeField(
                    label: "Thời điểm cân hàng thu về",
                    date: Binding(
                        get: { thoiGian05 ?? Date() },
                        set: { thoiGian05 = $0; thoiGian06 = $0 }
                    ),
                    displayStyle: .dateTime,
                    isReadOnly: !isEditMode
                )
                
                // Row 16: Photo 5 & 6 for Hàng thu về
                if isEditMode || hinh05 != nil || hinh06 != nil {
                    HStack(spacing: 12) {
                        photoBox(slotIndex: 5, image: $hinh05)
                        photoBox(slotIndex: 6, image: $hinh06)
                    }
                }
                
                // Row 17: Ghi chú
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
    private func photoBox(slotIndex: Int, image: Binding<UIImage?>) -> some View {
        ZStack {
            if let img = image.wrappedValue {
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingFullscreenIndex = slotIndex
                        }
                    
                    HStack(spacing: 8) {
                        Button {
                            showingFullscreenIndex = slotIndex
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.65))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                                LucideIcon(.eye, size: 18, color: .white)
                            }
                        }
                        
                        if isEditMode {
                            Button {
                                editingSlot = slotIndex
                                editingImage = IdentifiableImage(image: img)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.65))
                                        .frame(width: 38, height: 38)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                                    LucideIcon(.crop, size: 18, color: .white)
                                }
                            }
                            
                            Button {
                                image.wrappedValue = nil
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "BA1A1A").opacity(0.85))
                                        .frame(width: 38, height: 38)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                                    LucideIcon(.trash2, size: 18, color: .white)
                                }
                            }
                        }
                    }
                    .padding(8)
                }
            } else {
                if isEditMode {
                    let enabled = isSlotEnabled(slotIndex)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "D1D5DB"), lineWidth: 1)
                            )
                        
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(enabled ? Color(hex: "DCE7F5") : Color.gray.opacity(0.12))
                                    .frame(width: 60, height: 60)
                                LucideIcon(.camera, size: 22, color: .vtsPrimary)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(enabled ? Color(hex: "004B87") : Color.gray)
                            }
                            
                            Text(enabled ? "Thêm ảnh" : "Thêm ảnh \(slotIndex - 1) trước")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(enabled ? Color(hex: "374151") : Color.gray)
                        }
                    }
                    .opacity(enabled ? 1.0 : 0.5)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if enabled {
                            showingActionSheetForSlot = slotIndex
                        } else {
                            ErrorManager.shared.showError("Vui lòng thêm ảnh \(slotIndex - 1) trước.")
                        }
                    }
                } else {
                    Color.clear
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func isSlotEnabled(_ slotIndex: Int) -> Bool {
        switch slotIndex {
        case 1: return true
        case 2: return hinh01 != nil
        case 3: return hinh02 != nil
        case 4: return hinh03 != nil
        case 5: return hinh04 != nil
        case 6: return hinh05 != nil
        default: return false
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
                    Text(value.isEmpty ? "—" : value)
                        .font(.vtsBody.bold())
                        .foregroundColor(value.isEmpty ? .vtsTxtTertiary : .vtsTxtPrimary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if !value.isEmpty {
                    LucideIcon(.copy, size: 14, color: .vtsTxtTertiary)
                        .font(.system(size: 11))
                        .foregroundColor(.vtsTxtTertiary)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    
    private func populateFields(with details: TPhieuvc_Giacong_DanhSach) {
        ngay = Date.fromAPIString(details.ngay) ?? Date()
        soThamChieu = details.soThamChieu ?? ""
        khachHang = details.khachHang ?? ""
        
        if details.xeNgoai == true {
            xeNgoai = true
            soXeNgoai = details.soXe ?? ""
            soXeNha = ""
            taiXe = details.taiXe ?? ""
        } else {
            xeNgoai = false
            soXeNha = details.soXe ?? ""
            soXeNgoai = ""
            taiXe = details.nhanVien ?? details.taiXe ?? ""
        }
        
        hangHoa = details.hangHoa
        trongLuongXe = details.trongLuongXe == 0 ? "" : ((details.trongLuongXe.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(details.trongLuongXe)) : String(details.trongLuongXe))
        trongLuongHang = details.trongLuongHang == 0 ? "" : ((details.trongLuongHang.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(details.trongLuongHang)) : String(details.trongLuongHang))
        
        hangHoaGC = details.hangHoaGC ?? ""
        trongLuongHangGC = details.trongLuongHangGC == 0 ? "" : ((details.trongLuongHangGC.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(details.trongLuongHangGC)) : String(details.trongLuongHangGC))
        
        hangHoaTV = details.hangHoaTV ?? ""
        trongLuongHangTV = details.trongLuongHangTV == 0 ? "" : ((details.trongLuongHangTV.truncatingRemainder(dividingBy: 1) == 0) ? String(Int(details.trongLuongHangTV)) : String(details.trongLuongHangTV))
        
        trangThai = details.trangThai ?? "Moi"
        ghiChu = details.ghiChu ?? ""
        
        if let img1 = UIImage.fromBase64(details.image1Base64) { hinh01 = img1 }
        hinh01Text = details.hinh01NoiDungText
        
        if let img2 = UIImage.fromBase64(details.image2Base64) { hinh02 = img2 }
        hinh02Text = details.hinh02NoiDungText
        
        if let img3 = UIImage.fromBase64(details.image3Base64) { hinh03 = img3 }
        hinh03Text = details.hinh03NoiDungText
        
        if let img4 = UIImage.fromBase64(details.image4Base64) { hinh04 = img4 }
        hinh04Text = details.hinh04NoiDungText
        
        if let img5 = UIImage.fromBase64(details.image5Base64) { hinh05 = img5 }
        hinh05Text = details.hinh05NoiDungText
        
        if let img6 = UIImage.fromBase64(details.image6Base64) { hinh06 = img6 }
        hinh06Text = details.hinh06NoiDungText
        
        if let tg1 = details.thoiGian01, let d = Date.fromAPIString(tg1) { thoiGian01 = d }
        if let tg2 = details.thoiGian02, let d = Date.fromAPIString(tg2) { thoiGian02 = d }
        if let tg3 = details.thoiGian03, let d = Date.fromAPIString(tg3) { thoiGian03 = d }
        if let tg4 = details.thoiGian04, let d = Date.fromAPIString(tg4) { thoiGian04 = d }
        if let tg5 = details.thoiGian05, let d = Date.fromAPIString(tg5) { thoiGian05 = d }
        if let tg6 = details.thoiGian06, let d = Date.fromAPIString(tg6) { thoiGian06 = d }
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
        } else if trongLuongHang.toDouble() == nil {
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
        let hinh03Base64 = hinh03?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        let hinh04Base64 = hinh04?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        let hinh05Base64 = hinh05?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        let hinh06Base64 = hinh06?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        
        let now = Date()
        let tg1 = thoiGian01 ?? (hinh01 != nil ? now : nil)
        let tg2 = thoiGian02 ?? (hinh02 != nil ? now : nil)
        let tg3 = thoiGian03 ?? (hinh03 != nil ? now : nil)
        let tg4 = thoiGian04 ?? (hinh04 != nil ? now : nil)
        let tg5 = thoiGian05 ?? (hinh05 != nil ? now : nil)
        let tg6 = thoiGian06 ?? (hinh06 != nil ? now : nil)
        
        let currentSoXe = xeNgoai ? soXeNgoai : soXeNha
        let finalNhanVien: String? = xeNgoai ? nil : (taiXe.isEmpty ? nil : taiXe)
        let finalTaiXe: String? = xeNgoai ? (taiXe.isEmpty ? nil : taiXe) : nil
        
        do {
            if viewModel.isNew {
                let data = Params_ThemPhieu_GiaCong(
                    ngay: ngay,
                    soThamChieu: soThamChieu.isEmpty ? nil : soThamChieu,
                    xeNgoai: xeNgoai,
                    soXe: currentSoXe,
                    nhanVien: finalNhanVien,
                    taiXe: finalTaiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: trongLuongXe.toDouble() ?? 0,
                    trongLuongHang: trongLuongHang.toDouble() ?? 0,
                    thoiGian01: tg1, hinh01NoiDungText: hinh01Text, hinh01NoiDung: hinh01Base64,
                    thoiGian02: tg2, hinh02NoiDungText: hinh02Text, hinh02NoiDung: hinh02Base64,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai,
                    hangHoaGC: hangHoaGC.isEmpty ? nil : hangHoaGC,
                    trongLuongHangGC: trongLuongHangGC.toDouble() ?? 0,
                    thoiGian03: tg3, hinh03NoiDungText: hinh03Text, hinh03NoiDung: hinh03Base64,
                    thoiGian04: tg4, hinh04NoiDungText: hinh04Text, hinh04NoiDung: hinh04Base64,
                    hangHoaTV: hangHoaTV.isEmpty ? nil : hangHoaTV,
                    trongLuongHangTV: trongLuongHangTV.toDouble() ?? 0,
                    thoiGian05: tg5, hinh05NoiDungText: hinh05Text, hinh05NoiDung: hinh05Base64,
                    thoiGian06: tg6, hinh06NoiDungText: hinh06Text, hinh06NoiDung: hinh06Base64
                )
                let _ = try await PhieuGiaCongService.shared.them(data)
                onSaveSuccess?()
                NotificationCenter.default.post(name: .vtsPhieuGiaCongChanged, object: nil)
                router.showAlert(.alert, title: "Thành công", subtitle: "Tạo phiếu gia công mới thành công.") {
                    Button("Xong") {
                        router.dismissScreen()
                    }
                }
            } else {
                let data = Params_SuaPhieu_GiaCong(
                    ngay: ngay,
                    soThamChieu: soThamChieu.isEmpty ? nil : soThamChieu,
                    xeNgoai: xeNgoai,
                    soXe: currentSoXe,
                    nhanVien: finalNhanVien,
                    taiXe: finalTaiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: trongLuongXe.toDouble() ?? 0,
                    trongLuongHang: trongLuongHang.toDouble() ?? 0,
                    thoiGian01: tg1, hinh01NoiDungText: hinh01Text, hinh01NoiDung: hinh01Base64,
                    thoiGian02: tg2, hinh02NoiDungText: hinh02Text, hinh02NoiDung: hinh02Base64,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai,
                    soPhieu: viewModel.soPhieu,
                    hangHoaGC: hangHoaGC.isEmpty ? nil : hangHoaGC,
                    trongLuongHangGC: trongLuongHangGC.toDouble() ?? 0,
                    thoiGian03: tg3, hinh03NoiDungText: hinh03Text, hinh03NoiDung: hinh03Base64,
                    thoiGian04: tg4, hinh04NoiDungText: hinh04Text, hinh04NoiDung: hinh04Base64,
                    hangHoaTV: hangHoaTV.isEmpty ? nil : hangHoaTV,
                    trongLuongHangTV: trongLuongHangTV.toDouble() ?? 0,
                    thoiGian05: tg5, hinh05NoiDungText: hinh05Text, hinh05NoiDung: hinh05Base64,
                    thoiGian06: tg6, hinh06NoiDungText: hinh06Text, hinh06NoiDung: hinh06Base64,
                    xoaHinh01: false, xoaHinh02: false, xoaHinh03: false, xoaHinh04: false, xoaHinh05: false, xoaHinh06: false
                )
                let _ = try await PhieuGiaCongService.shared.sua(data)
                onSaveSuccess?()
                NotificationCenter.default.post(name: .vtsPhieuGiaCongChanged, object: nil)
                router.showAlert(.alert, title: "Thành công", subtitle: "Cập nhật phiếu gia công thành công.") {
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
            let _ = try await PhieuGiaCongService.shared.xoa(soPhieu: soPhieu)
            onSaveSuccess?()
            NotificationCenter.default.post(name: .vtsPhieuGiaCongChanged, object: nil)
            router.showAlert(.alert, title: "Thành công", subtitle: "Đã xoá phiếu gia công.") {
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
