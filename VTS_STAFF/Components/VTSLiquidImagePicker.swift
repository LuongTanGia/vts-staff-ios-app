
//
//  VTSLiquidImagePicker.swift
//  VTS_STAFF
//
//  Component chụp/chọn ảnh dùng trên Form Phiếu VC
//  Android: 2 ô cạnh nhau – ô trái là thumbnail có nút Xem👁 + Xoá❌,
//           ô phải là nút thêm ảnh mới (camera icon)
//
//  iOS Liquid Glass:
//    • VTSLiquidImageSlot   – 1 ô ảnh (thumbnail hoặc nút thêm)
//    • VTSLiquidImageRow    – hàng 2 ô: ô hiện tại + ô thêm mới
//    • VTSLiquidImageGrid   – nhiều hàng ảnh (tối đa maxImages)
//
//  Cách dùng (1 cặp ảnh):
//    VTSLiquidImageRow(
//        image: $viewModel.anhCanXe,
//        onView: { showFullscreen = true },
//        onDelete: { viewModel.xoaAnh() }
//    )
//
//  Cách dùng (nhiều ảnh):
//    VTSLiquidImageGrid(images: $viewModel.danhSachAnh, maxImages: 4)
//

import SwiftUI
import PhotosUI

// MARK: - ============================================================
//          VTSLiquidImageSlot – 1 ô ảnh đơn
// MARK: - ============================================================

/// Trạng thái của 1 slot ảnh
enum VTSImageSlotState {
    case empty          // Ô trống → hiện nút camera
    case hasImage(UIImage)
}

struct VTSLiquidImageSlot: View {
    @Binding var state: VTSImageSlotState
    let onView:   (() -> Void)?
    let onDelete: (() -> Void)?
    
    @State private var showPicker      = false
    @State private var showCamera      = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showActionSheet = false
    
    var body: some View {
        switch state {
        case .empty:
            addPhotoButton
        case .hasImage(let img):
            thumbnailView(img)
        }
    }
    
    // MARK: - Nút thêm ảnh (ô phải giống Android)
    private var addPhotoButton: some View {
        Button { showActionSheet = true } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
                
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.vtsPrimary.opacity(0.12))
                            .frame(width: 52, height: 52)
                        Image(systemName: "camera.badge.plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.vtsPrimary)
                    }
                    Text("Thêm ảnh")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.5, contentMode: .fit)
        }
        .buttonStyle(VTSPressButtonStyle())
        .confirmationDialog("Chọn nguồn ảnh", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Chụp ảnh") { showCamera = true }
            Button("Chọn từ thư viện") { showPicker = true }
            Button("Huỷ", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img  = UIImage(data: data) {
                    await MainActor.run { state = .hasImage(img) }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { img in
                state = .hasImage(img)
                showCamera = false
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Thumbnail (ô trái giống Android)
    @ViewBuilder
    private func thumbnailView(_ img: UIImage) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Ảnh
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(1.5, contentMode: .fit)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            // Gradient overlay phía dưới
            LinearGradient(
                colors: [.black.opacity(0.5), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            // Action buttons: Xem + Xoá
            HStack(spacing: 10) {
                // Xem
                imageActionButton(icon: "eye.fill", color: .vtsPrimary) {
                    onView?()
                }
                // Xoá
                imageActionButton(icon: "trash.fill", color: .vtsDanger) {
                    withAnimation(.spring(response: 0.3)) {
                        state = .empty
                        onDelete?()
                    }
                }
            }
            .padding(10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func imageActionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(VTSPressButtonStyle())
    }
}

// MARK: - ============================================================
//        VTSLiquidImageRow – hàng 2 ô: thumbnail + nút thêm
// MARK: - ============================================================

/// Dùng khi mỗi section chỉ có 1 ảnh (giống Android: ô ảnh + ô camera)
struct VTSLiquidImageRow: View {
    @Binding var image: UIImage?
    var onView: (() -> Void)?
    var onDelete: (() -> Void)?
    
    private var slotState: Binding<VTSImageSlotState> {
        Binding(
            get: { image.map { .hasImage($0) } ?? .empty },
            set: { newState in
                switch newState {
                case .empty:          image = nil
                case .hasImage(let i): image = i
                }
            }
        )
    }
    
    @State private var addSlotState: VTSImageSlotState = .empty
    
    var body: some View {
        HStack(spacing: 10) {
            // Slot ảnh hiện có
            VTSLiquidImageSlot(state: slotState, onView: onView, onDelete: onDelete)
            
            // Slot thêm ảnh mới (nếu đã có ảnh rồi mới hiện nút thêm)
            if image != nil {
                VTSLiquidImageSlot(
                    state: $addSlotState,
                    onView: nil,
                    onDelete: nil
                )
            }
        }
    }
}

// MARK: - ============================================================
//        VTSLiquidImageGrid – nhiều ảnh (maxImages tùy chỉnh)
// MARK: - ============================================================

struct VTSLiquidImageGrid: View {
    @Binding var images: [UIImage]
    let maxImages: Int
    @State private var fullscreenImage: UIImage?
    
    init(images: Binding<[UIImage]>, maxImages: Int = 4) {
        self._images    = images
        self.maxImages  = maxImages
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            // Existing images
            ForEach(images.indices, id: \.self) { idx in
                let slotBinding = Binding<VTSImageSlotState>(
                    get: { .hasImage(images[idx]) },
                    set: { newState in
                        switch newState {
                        case .empty:         images.remove(at: idx)
                        case .hasImage(let i): images[idx] = i
                        }
                    }
                )
                VTSLiquidImageSlot(
                    state: slotBinding,
                    onView: { fullscreenImage = images[idx] },
                    onDelete: nil
                )
            }
            
            // Add new slot (nếu chưa đủ maxImages)
            if images.count < maxImages {
                let emptySlot = Binding<VTSImageSlotState>(
                    get: { .empty },
                    set: { newState in
                        if case .hasImage(let img) = newState {
                            images.append(img)
                        }
                    }
                )
                VTSLiquidImageSlot(state: emptySlot, onView: nil, onDelete: nil)
            }
        }
        .fullScreenCover(item: Binding(
            get: { fullscreenImage.map { IdentifiableImage(image: $0) } },
            set: { fullscreenImage = $0?.image }
        )) { item in
            ImageFullscreenView(image: item.image) { fullscreenImage = nil }
        }
    }
}

// MARK: - Identifiable wrapper
private struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - Fullscreen image viewer
private struct ImageFullscreenView: View {
    let image: UIImage
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(MagnificationGesture()
                    .onChanged { scale = max(1, $0) }
                    .onEnded   { _ in withAnimation { scale = 1 } }
                )
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(20)
            }
        }
    }
}

// MARK: - Camera View (UIViewControllerRepresentable)
struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType     = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate       = context.coordinator
        picker.allowsEditing  = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage { onCapture(img) }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - UIImage extension base64
extension UIImage {
    static func fromBase64(_ string: String) -> UIImage? {
        guard let data = Data(base64Encoded: string) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Preview
#Preview("ImagePicker") {
    @State var img1: UIImage? = nil
    @State var images: [UIImage] = []
    return ScrollView {
        VStack(spacing: 20) {
            VTSLiquidImageRow(image: $img1)
            VTSLiquidImageGrid(images: $images, maxImages: 4)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
