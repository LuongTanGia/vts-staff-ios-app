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
    @State private var nhanVien: String = ""
    @State private var xeNgoai: Bool = false
    @State private var soXe: String = ""
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
    @State private var trongLuongXeError: String? = nil
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
    
    private var currentNhanVienDisplay: String {
        if let found = viewModel.nhanVienOptions.first(where: { $0.emid == nhanVien }) {
            return found.emHoTen
        }
        if case .success(let details) = viewModel.state, let details = details, let name = details.tenNhanVien, !name.isEmpty {
            return name
        }
        return nhanVien.isEmpty ? "---" : nhanVien
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
    
    init(soPhieu: String?, existing: TPhieuvc_Giacong_DanhSach? = nil, isEditMode: Bool = false) {
        self.initialEditMode = isEditMode
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
                        soXe: soXe,
                        tenNhanVien: currentNhanVienDisplay,
                        tenHangHoa: currentHangHoaDisplay,
                        trongLuongHang: trongLuongHang,
                        tenKhachHang: currentKhachHangDisplay
                    )
                    
                    // Scrollable Form details
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            formFieldsCard(details: details)
                            
                            if !viewModel.isNew && isEditMode && hasDeletePermission {
                                Button(role: .destructive) {
                                    router.showAlert(.alert, title: "Xác nhận xoá", subtitle: "Bạn có chắc chắn muốn xoá phiếu gia công này?") {
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
                                        Text("Xoá phiếu gia công")
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
                    
                    Image(systemName: "gearshape.2.fill")
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
                if !isEditMode, let d = details {
                    infoRow(label: "Số phiếu", value: d.soPhieu, icon: "number")
                    infoRow(label: "Ngày lập", value: Date.fromAPIString(d.ngay)?.formatted(date: .numeric, time: .shortened) ?? d.ngay, icon: "calendar")
                    infoRow(label: "Số tham chiếu", value: d.soThamChieu ?? "", icon: "doc.text")
                    infoRow(label: "Nhân viên theo dõi", value: d.tenNhanVien ?? d.nhanVien ?? "", icon: "person.badge.shield.checkmark.fill")
                    infoRow(label: "Xe ngoài", value: d.xeNgoai ? "Có" : "Không", icon: "car.2.fill")
                    infoRow(label: "Số xe", value: d.soXe ?? "", icon: "truck.box.fill")
                    infoRow(label: "Tài xế", value: d.taiXe ?? "", icon: "person.crop.rectangle.fill")
                    infoRow(label: "Khách hàng", value: d.tenKhachHang ?? d.khachHang ?? "", icon: "building.2.fill")
                    infoRow(label: "Hàng hoá", value: d.tenHangHoa, icon: "shippingbox.fill")
                    infoRow(label: "Trọng lượng xe", value: "\(d.trongLuongXe) kg", icon: "scalemass.fill")
                    infoRow(label: "Trọng lượng hàng", value: "\(d.trongLuongHang) kg", icon: "scalemass")
                    infoRow(label: "Hàng gia công", value: d.tenHangHoaGC ?? d.hangHoaGC ?? "", icon: "gearshape")
                    infoRow(label: "Trọng lượng gia công", value: "\(d.trongLuongHangGC) kg", icon: "scalemass")
                    infoRow(label: "Hàng thu hồi", value: d.tenHangHoaTV ?? d.hangHoaTV ?? "", icon: "arrow.uturn.backward")
                    infoRow(label: "Trọng lượng thu hồi", value: "\(d.trongLuongHangTV) kg", icon: "scalemass")
                    infoRow(label: "Trạng thái", value: d.tenTrangThai ?? "", icon: "info.circle.fill")
                    infoRow(label: "Ghi chú", value: d.ghiChu ?? "", icon: "note.text")
                    
                    // Ảnh hiển thị chế độ xem
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hình ảnh hàng hoá")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.vtsPrimary)
                        
                        HStack(spacing: 12) {
                            photoBox(slotIndex: 1, label: "Ảnh hàng hoá 1", image: $hinh01)
                            photoBox(slotIndex: 2, label: "Ảnh hàng hoá 2", image: $hinh02)
                        }
                        
                        Text("Hình ảnh gia công")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.vtsPrimary)
                            .padding(.top, 4)
                        
                        HStack(spacing: 12) {
                            photoBox(slotIndex: 3, label: "Ảnh gia công 1", image: $hinh03)
                            photoBox(slotIndex: 4, label: "Ảnh gia công 2", image: $hinh04)
                        }
                        
                        Text("Hình ảnh thu hồi")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.vtsPrimary)
                            .padding(.top, 4)
                        
                        HStack(spacing: 12) {
                            photoBox(slotIndex: 5, label: "Ảnh thu hồi 1", image: $hinh05)
                            photoBox(slotIndex: 6, label: "Ảnh thu hồi 2", image: $hinh06)
                        }
                    }
                    .padding(.top, 8)
                } else {
                    VTSLiquidDateTimeField(label: "Ngày lập phiếu", date: $ngay, displayStyle: .dateTime)
                    VTSLiquidTextField(label: "Số tham chiếu", text: $soThamChieu, placeholder: "Nhập số tham chiếu...")
                    
                    VTSLiquidPickerField(
                        label: "Nhân viên theo dõi",
                        selection: $nhanVien,
                        options: viewModel.nhanVienOptions.map { $0.emid },
                        displayName: { code in
                            viewModel.nhanVienOptions.first(where: { $0.emid == code })?.emHoTen ?? code
                        }
                    )
                    
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
                        VTSLiquidTextField(
                            label: "Số xe ngoài",
                            text: $soXe,
                            placeholder: "Nhập số xe...",
                            isReadOnly: !isEditMode,
                            errorMessage: soXeError
                        )
                        .onChange(of: soXe) { _, newValue in
                            let upper = newValue.uppercased()
                            if soXe != upper {
                                soXe = upper
                            }
                            let normalizedInput = normalizePlate(upper)
                            if !normalizedInput.isEmpty,
                               let matchedXe = viewModel.xeOptions.first(where: {
                                   normalizePlate($0.ma) == normalizedInput || normalizePlate($0.ten) == normalizedInput
                               }) {
                                xeNgoai = false
                                soXe = matchedXe.ma
                                soXeError = nil
                                if !matchedXe.maTaiXe.isEmpty {
                                    nhanVien = matchedXe.maTaiXe
                                }
                            }
                        }
                        
                        VTSLiquidTextField(
                            label: "Tài xế ngoài",
                            text: $taiXe,
                            placeholder: "Nhập tên tài xế...",
                            isReadOnly: !isEditMode,
                            errorMessage: taiXeError
                        )
                    } else {
                        VTSLiquidPickerField(
                            label: "Nhân viên theo dõi",
                            selection: $nhanVien,
                            options: viewModel.nhanVienOptions.map { $0.emid },
                            displayName: { code in
                                viewModel.nhanVienOptions.first(where: { $0.emid == code })?.emHoTen ?? code
                            }
                        )
                        .disabled(!isEditMode)
                        
                        VTSLiquidPickerField(
                            label: "Số xe nhà",
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
                                if !foundXe.maTaiXe.isEmpty {
                                    nhanVien = foundXe.maTaiXe
                                }
                            }
                        }
                        .disabled(!isEditMode)
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
                        label: "Hàng hoá chính",
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
                    
                    Text("Hình ảnh hàng hoá chính")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.vtsPrimary)
                        .padding(.top, 4)
                    
                    HStack(spacing: 12) {
                        photoBox(slotIndex: 1, label: "Ảnh hàng hoá 1", image: $hinh01)
                        photoBox(slotIndex: 2, label: "Ảnh hàng hoá 2", image: $hinh02)
                    }
                    
                    // Gia Cong specific fields section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Thông tin gia công")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.vtsPrimary)
                            .padding(.top, 8)
                        
                        VTSLiquidPickerField(
                            label: "Hàng gia công",
                            selection: $hangHoaGC,
                            options: [""] + viewModel.hangHoaOptions.map { $0.ma },
                            displayName: { code in
                                code.isEmpty ? "Không chọn" : (viewModel.hangHoaOptions.first(where: { $0.ma == code })?.ten ?? code)
                            }
                        )
                        
                        VTSLiquidTextField(label: "Trọng lượng gia công (kg)", text: $trongLuongHangGC, keyboardType: .numberPad)
                        
                        HStack(spacing: 12) {
                            photoBox(slotIndex: 3, label: "Ảnh gia công 1", image: $hinh03)
                            photoBox(slotIndex: 4, label: "Ảnh gia công 2", image: $hinh04)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Thông tin thu hồi / trả về")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.vtsPrimary)
                            .padding(.top, 8)
                        
                        VTSLiquidPickerField(
                            label: "Hàng thu hồi",
                            selection: $hangHoaTV,
                            options: [""] + viewModel.hangHoaOptions.map { $0.ma },
                            displayName: { code in
                                code.isEmpty ? "Không chọn" : (viewModel.hangHoaOptions.first(where: { $0.ma == code })?.ten ?? code)
                            }
                        )
                        
                        VTSLiquidTextField(label: "Trọng lượng thu hồi (kg)", text: $trongLuongHangTV, keyboardType: .numberPad)
                        
                        HStack(spacing: 12) {
                            photoBox(slotIndex: 5, label: "Ảnh thu hồi 1", image: $hinh05)
                            photoBox(slotIndex: 6, label: "Ảnh thu hồi 2", image: $hinh06)
                        }
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
    }
    
    @ViewBuilder
    private func photoBox(slotIndex: Int, label: String, image: Binding<UIImage?>) -> some View {
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
                    
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color.vtsPrimary.opacity(0.12))
                                .frame(width: 42, height: 42)
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.vtsPrimary)
                        }
                        
                        Text(isEditMode ? "Thêm \(label.lowercased())" : "Chưa có ảnh")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(isEditMode ? .vtsTxtSecondary : .vtsTxtTertiary)
                    }
                }
                .frame(height: 120)
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
    
    private func normalizePlate(_ input: String) -> String {
        input.uppercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
    
    private func populateFields(with details: TPhieuvc_Giacong_DanhSach) {
        ngay = Date.fromAPIString(details.ngay) ?? Date()
        soThamChieu = details.soThamChieu ?? ""
        xeNgoai = details.xeNgoai
        soXe = details.soXe ?? ""
        if details.xeNgoai {
            taiXe = details.taiXe ?? ""
            nhanVien = ""
        } else {
            nhanVien = details.nhanVien ?? details.taiXe ?? ""
            taiXe = ""
        }
        khachHang = details.khachHang ?? ""
        hangHoa = details.hangHoa
        trongLuongXe = String(details.trongLuongXe)
        trongLuongHang = String(details.trongLuongHang)
        hangHoaGC = details.hangHoaGC ?? ""
        trongLuongHangGC = String(details.trongLuongHangGC)
        hangHoaTV = details.hangHoaTV ?? ""
        trongLuongHangTV = String(details.trongLuongHangTV)
        ghiChu = details.ghiChu ?? ""
        trangThai = details.trangThai ?? ""
        
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
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        
        if soXe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
        
        let finalNhanVien: String? = xeNgoai ? nil : (nhanVien.isEmpty ? nil : nhanVien)
        let finalTaiXe: String? = xeNgoai ? (taiXe.isEmpty ? nil : taiXe) : nil
        
        do {
            if viewModel.isNew {
                let data = Params_ThemPhieu_GiaCong(
                    ngay: ngay,
                    soThamChieu: soThamChieu.isEmpty ? nil : soThamChieu,
                    xeNgoai: xeNgoai,
                    soXe: soXe,
                    nhanVien: finalNhanVien,
                    taiXe: finalTaiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: Double(trongLuongXe) ?? 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: tg1, hinh01NoiDungText: hinh01Text, hinh01NoiDung: hinh01Base64,
                    thoiGian02: tg2, hinh02NoiDungText: hinh02Text, hinh02NoiDung: hinh02Base64,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai,
                    hangHoaGC: hangHoaGC.isEmpty ? nil : hangHoaGC,
                    trongLuongHangGC: Double(trongLuongHangGC) ?? 0,
                    thoiGian03: tg3, hinh03NoiDungText: hinh03Text, hinh03NoiDung: hinh03Base64,
                    thoiGian04: tg4, hinh04NoiDungText: hinh04Text, hinh04NoiDung: hinh04Base64,
                    hangHoaTV: hangHoaTV.isEmpty ? nil : hangHoaTV,
                    trongLuongHangTV: Double(trongLuongHangTV) ?? 0,
                    thoiGian05: tg5, hinh05NoiDungText: hinh05Text, hinh05NoiDung: hinh05Base64,
                    thoiGian06: tg6, hinh06NoiDungText: hinh06Text, hinh06NoiDung: hinh06Base64
                )
                let _ = try await PhieuGiaCongService.shared.them(data)
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
                    soXe: soXe,
                    nhanVien: finalNhanVien,
                    taiXe: finalTaiXe,
                    khachHang: khachHang,
                    hangHoa: hangHoa,
                    trongLuongXe: Double(trongLuongXe) ?? 0,
                    trongLuongHang: Double(trongLuongHang) ?? 0,
                    thoiGian01: tg1, hinh01NoiDungText: hinh01Text, hinh01NoiDung: hinh01Base64,
                    thoiGian02: tg2, hinh02NoiDungText: hinh02Text, hinh02NoiDung: hinh02Base64,
                    ghiChu: ghiChu.isEmpty ? nil : ghiChu,
                    trangThai: trangThai,
                    soPhieu: viewModel.soPhieu,
                    hangHoaGC: hangHoaGC.isEmpty ? nil : hangHoaGC,
                    trongLuongHangGC: Double(trongLuongHangGC) ?? 0,
                    thoiGian03: tg3, hinh03NoiDungText: hinh03Text, hinh03NoiDung: hinh03Base64,
                    thoiGian04: tg4, hinh04NoiDungText: hinh04Text, hinh04NoiDung: hinh04Base64,
                    hangHoaTV: hangHoaTV.isEmpty ? nil : hangHoaTV,
                    trongLuongHangTV: Double(trongLuongHangTV) ?? 0,
                    thoiGian05: tg5, hinh05NoiDungText: hinh05Text, hinh05NoiDung: hinh05Base64,
                    thoiGian06: tg6, hinh06NoiDungText: hinh06Text, hinh06NoiDung: hinh06Base64,
                    xoaHinh01: false, xoaHinh02: false, xoaHinh03: false, xoaHinh04: false, xoaHinh05: false, xoaHinh06: false
                )
                let _ = try await PhieuGiaCongService.shared.sua(data)
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
            router.showAlert(.alert, title: "Thành công", subtitle: "Đã xoá phiếu gia công.") {
                Button("OK") {
                    router.dismissScreen()
                }
            }
        } catch {
            router.showAlert(.alert, title: "Lỗi", subtitle: error.localizedDescription) {
                Button("OK") {}
            }
        }
    }
}
