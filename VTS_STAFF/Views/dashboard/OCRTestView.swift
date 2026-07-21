//
//  OCRTestView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import SwiftUI
import Vision
import PhotosUI
import SwiftfulRouting

struct OCRTestView: View {
    @Environment(\.router) private var router
    @State private var selectedImage: UIImage? = nil
    @State private var recognizedText: String = ""
    @State private var isProcessing: Bool = false
    
    @State private var showActionSheet = false
    @State private var showCamera = false
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showFullscreen = false
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: Image Selection Area
                    VStack(spacing: 12) {
                        Text("Hình ảnh cần quét")
                            .font(.vtsHeadline.bold())
                            .foregroundColor(.vtsTxtPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let img = selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 280)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        showFullscreen = true
                                    }
                                
                                Button {
                                    withAnimation {
                                        selectedImage = nil
                                        recognizedText = ""
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .padding(8)
                            }
                        } else {
                            Button {
                                showActionSheet = true
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 40))
                                        .foregroundColor(.vtsPrimary)
                                    
                                    Text("Chọn hình ảnh hoặc chụp ảnh mới")
                                        .font(.vtsBody.bold())
                                        .foregroundColor(.vtsPrimary)
                                    
                                    Text("Hỗ trợ JPG, PNG. Chụp rõ nét để nhận diện tốt nhất.")
                                        .font(.vtsCaption)
                                        .foregroundColor(.vtsTxtSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.vtsPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                                        .background(Color.white.opacity(0.6))
                                )
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    )
                    
                    // MARK: Perform OCR Action Button
                    if selectedImage != nil {
                        Button {
                            Task {
                                await runOCR()
                            }
                        } label: {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 8)
                                    Text("Đang xử lý quét chữ...")
                                } else {
                                    Image(systemName: "doc.text.viewfinder")
                                    Text("Bắt đầu nhận diện văn bản (OCR)")
                                }
                            }
                            .font(.vtsHeadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.vtsPrimary)
                            .cornerRadius(14)
                        }
                        .disabled(isProcessing)
                    }
                    
                    // MARK: OCR Results Area
                    VStack(spacing: 12) {
                        HStack {
                            Text("Kết quả nhận diện")
                                .font(.vtsHeadline.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            Spacer()
                            
                            if !recognizedText.isEmpty {
                                Button {
                                    UIPasteboard.general.string = recognizedText
                                    ErrorManager.shared.showSuccess("Đã sao chép văn bản vào bộ nhớ tạm")
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                        Text("Sao chép")
                                    }
                                    .font(.vtsCaption.bold())
                                    .foregroundColor(.vtsPrimary)
                                }
                            }
                        }
                        
                        if isProcessing {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Vui lòng chờ giây lát...")
                                    .font(.vtsCaption)
                                    .foregroundColor(.vtsTxtSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(16)
                        } else if !recognizedText.isEmpty {
                            ScrollView {
                                Text(recognizedText)
                                    .font(.vtsBody)
                                    .foregroundColor(.vtsTxtPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                            }
                            .frame(minHeight: 120, maxHeight: 300)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        } else {
                            Text("Chưa có kết quả. Chọn ảnh và bấm bắt đầu quét.")
                                .font(.vtsCallout)
                                .foregroundColor(.vtsTxtTertiary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(16)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Thử nghiệm quét chữ (OCR)",
            isWhiteText: true,
            leading: {},
            trailing: {},
            primaryAction: { EmptyView() }
        )
        .confirmationDialog("Chọn nguồn ảnh", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Chụp ảnh") { showCamera = true }
            Button("Chọn từ thư viện") { showPicker = true }
            Button("Huỷ", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = img
                        recognizedText = ""
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { img in
                selectedImage = img
                recognizedText = ""
                showCamera = false
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            if let img = selectedImage {
                ImageFullscreenView(image: img) {
                    showFullscreen = false
                }
            }
        }
    }
    
    private func runOCR() async {
        guard let img = selectedImage else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        guard let cgImage = img.cgImage else {
            recognizedText = "Lỗi: Không thể tải hình ảnh dưới dạng CGImage."
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        // Setup recognition languages. iOS 16 supports Vietnamese natively.
        if #available(iOS 16.0, *) {
            request.recognitionLanguages = ["vi-VN", "en-US"]
        } else {
            request.recognitionLanguages = ["en-US"]
        }
        
        do {
            try handler.perform([request])
            guard let observations = request.results else {
                recognizedText = "Không tìm thấy văn bản nào trong ảnh."
                return
            }
            
            let strings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            if strings.isEmpty {
                recognizedText = "Không tìm thấy văn bản nào trong ảnh."
            } else {
                recognizedText = strings.joined(separator: "\n")
            }
        } catch {
            recognizedText = "Lỗi quét ảnh: \(error.localizedDescription)"
        }
    }
}

#Preview {
    RouterView { _ in
        OCRTestView()
    }
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
