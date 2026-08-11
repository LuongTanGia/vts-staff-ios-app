//
//  VTSImageEditorView.swift
//  VTS_STAFF
//
//  Màn hình Cắt - Xoay ảnh (Image Editor)
//  Hỗ trợ cắt tự do bằng cách kéo 4 góc khung cắt, xoay 90° (trái/phải), lật và phóng to ảnh.
//

import SwiftUI
import CoreGraphics

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct VTSImageEditorView: View {
    let inputImage: UIImage
    let onSave: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var rotationDegrees: Double = 0
    @State private var isFlippedHorizontally: Bool = false
    
    // Zoom & Drag State for Image
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // Aspect Ratio options
    enum AspectRatioType: String, CaseIterable, Identifiable {
        case free = "Tự do"
        case square = "1:1"
        case ratio4_3 = "4:3"
        case ratio16_9 = "16:9"
        
        var id: String { rawValue }
        
        var ratio: CGFloat? {
            switch self {
            case .free: return nil
            case .square: return 1.0
            case .ratio4_3: return 4.0 / 3.0
            case .ratio16_9: return 16.0 / 9.0
            }
        }
    }
    
    @State private var selectedRatio: AspectRatioType = .free
    
    // Crop Box State (Position & Size in view coordinates)
    @State private var cropRect: CGRect = .zero
    @State private var initialCropRectSet: Bool = false
    @State private var dragStartCropRect: CGRect? = nil
    
    enum CornerHandle {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerView
            
            // Image Canvas & Interactive Crop Box
            ZStack {
                Color.black.ignoresSafeArea()
                
                GeometryReader { geometry in
                    let containerSize = geometry.size
                    
                    ZStack {
                        // Editable Image
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(.degrees(rotationDegrees))
                            .scaleEffect(x: isFlippedHorizontally ? -1 : 1, y: 1)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { val in
                                        offset = CGSize(
                                            width: lastOffset.width + val.translation.width,
                                            height: lastOffset.height + val.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .simultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        let delta = val / lastScale
                                        lastScale = val
                                        scale = max(0.8, min(scale * delta, 5.0))
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        if scale < 1.0 {
                                            withAnimation(.spring()) {
                                                scale = 1.0
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                        
                        // Interactive Crop Frame & Corner Handles
                        cropOverlayView(containerSize: containerSize)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        initCropRectIfNeeded(containerSize: containerSize)
                    }
                    .onChange(of: selectedRatio) { _ in
                        resetCropRect(containerSize: containerSize)
                    }
                }
            }
            
            // Footer Controls
            footerToolbar
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button("Huỷ") {
                onCancel()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            
            Spacer()
            
            Text("Chỉnh sửa ảnh")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Xong") {
                renderAndSave()
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.vtsPrimary)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .padding(.top, 52)
        .background(Color.black)
    }
    
    // MARK: - Footer Toolbar
    private var footerToolbar: some View {
        VStack(spacing: 14) {
            // Ratio selection
            HStack(spacing: 16) {
                ForEach(AspectRatioType.allCases) { ratioType in
                    Button {
                        withAnimation {
                            selectedRatio = ratioType
                        }
                    } label: {
                        Text(ratioType.rawValue)
                            .font(.system(size: 13, weight: selectedRatio == ratioType ? .bold : .regular))
                            .foregroundColor(selectedRatio == ratioType ? .vtsPrimary : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedRatio == ratioType ? Color.vtsPrimary.opacity(0.2) : Color.clear)
                            )
                    }
                }
            }
            .padding(.top, 8)
            
            // Editing buttons (Xoay, Lật, Reset)
            HStack(spacing: 28) {
                // Xoay 90° Trái
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        rotationDegrees -= 90
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "rotate.left")
                            .font(.system(size: 20))
                        Text("Xoay trái")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white)
                }
                
                // Xoay 90° Phải
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        rotationDegrees += 90
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "rotate.right")
                            .font(.system(size: 20))
                        Text("Xoay phải")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white)
                }
                
                // Lật ngang
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isFlippedHorizontally.toggle()
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20))
                        Text("Lật ngang")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white)
                }
                
                // Đặt lại
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        rotationDegrees = 0
                        isFlippedHorizontally = false
                        scale = 1.0
                        offset = .zero
                        lastOffset = .zero
                        selectedRatio = .free
                        initialCropRectSet = false
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "gobackward")
                            .font(.system(size: 20))
                        Text("Đặt lại")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }
    
    // MARK: - Crop Box Setup & Reset
    private func initCropRectIfNeeded(containerSize: CGSize) {
        guard !initialCropRectSet, containerSize.width > 0, containerSize.height > 0 else { return }
        resetCropRect(containerSize: containerSize)
        initialCropRectSet = true
    }
    
    private func resetCropRect(containerSize: CGSize) {
        let margin: CGFloat = 24
        let maxWidth = containerSize.width - margin * 2
        let maxHeight = containerSize.height - margin * 2
        
        var w = maxWidth
        var h = maxHeight
        
        if let ratio = selectedRatio.ratio {
            h = w / ratio
            if h > maxHeight {
                h = maxHeight
                w = h * ratio
            }
        } else {
            h = min(maxHeight, w * 1.2)
        }
        
        let x = (containerSize.width - w) / 2
        let y = (containerSize.height - h) / 2
        cropRect = CGRect(x: x, y: y, width: w, height: h)
    }
    
    // MARK: - Interactive Crop Overlay View
    @ViewBuilder
    private func cropOverlayView(containerSize: CGSize) -> some View {
        let activeRect = cropRect.width > 0 ? cropRect : CGRect(x: 24, y: 24, width: containerSize.width - 48, height: containerSize.height - 48)
        
        ZStack(alignment: .topLeading) {
            // Dimmed mask outside crop box
            Path { path in
                path.addRect(CGRect(origin: .zero, size: containerSize))
                path.addRect(activeRect)
            }
            .fill(Color.black.opacity(0.5), style: FillStyle(eoFill: true))
            .allowsHitTesting(false)
            
            // White Crop Border Frame
            Rectangle()
                .stroke(Color.white, lineWidth: 1.5)
                .frame(width: activeRect.width, height: activeRect.height)
                .overlay(
                    // Rule of Thirds Grid
                    VStack {
                        Spacer()
                        Divider().background(Color.white.opacity(0.35))
                        Spacer()
                        Divider().background(Color.white.opacity(0.35))
                        Spacer()
                    }
                )
                .overlay(
                    HStack {
                        Spacer()
                        Divider().background(Color.white.opacity(0.35))
                        Spacer()
                        Divider().background(Color.white.opacity(0.35))
                        Spacer()
                    }
                )
                .offset(x: activeRect.minX, y: activeRect.minY)
                .allowsHitTesting(false)
            
            // 4 Corner Drag Handles (L-shaped thick handles)
            cornerHandleView(corner: .topLeft, activeRect: activeRect, containerSize: containerSize)
            cornerHandleView(corner: .topRight, activeRect: activeRect, containerSize: containerSize)
            cornerHandleView(corner: .bottomLeft, activeRect: activeRect, containerSize: containerSize)
            cornerHandleView(corner: .bottomRight, activeRect: activeRect, containerSize: containerSize)
        }
    }
    
    // MARK: - Corner Drag Handle Builder
    @ViewBuilder
    private func cornerHandleView(corner: CornerHandle, activeRect: CGRect, containerSize: CGSize) -> some View {
        let handleSize: CGFloat = 40
        let lineLen: CGFloat = 20
        let lineThick: CGFloat = 3.5
        
        let position: CGPoint = {
            switch corner {
            case .topLeft:     return CGPoint(x: activeRect.minX, y: activeRect.minY)
            case .topRight:    return CGPoint(x: activeRect.maxX, y: activeRect.minY)
            case .bottomLeft:  return CGPoint(x: activeRect.minX, y: activeRect.maxY)
            case .bottomRight: return CGPoint(x: activeRect.maxX, y: activeRect.maxY)
            }
        }()
        
        ZStack {
            // Touch Hit-Test Target (Invisible area)
            Rectangle()
                .fill(Color.white.opacity(0.001))
                .frame(width: handleSize, height: handleSize)
            
            // Visual L-Shape Handle
            Path { path in
                switch corner {
                case .topLeft:
                    path.move(to: CGPoint(x: handleSize/2, y: handleSize/2 + lineLen))
                    path.addLine(to: CGPoint(x: handleSize/2, y: handleSize/2))
                    path.addLine(to: CGPoint(x: handleSize/2 + lineLen, y: handleSize/2))
                case .topRight:
                    path.move(to: CGPoint(x: handleSize/2 - lineLen, y: handleSize/2))
                    path.addLine(to: CGPoint(x: handleSize/2, y: handleSize/2))
                    path.addLine(to: CGPoint(x: handleSize/2, y: handleSize/2 + lineLen))
                case .bottomLeft:
                    path.move(to: CGPoint(x: handleSize/2, y: handleSize/2 - lineLen))
                    path.addLine(to: CGPoint(x: handleSize/2, y: handleSize/2))
                    path.addLine(to: CGPoint(x: handleSize/2 + lineLen, y: handleSize/2))
                case .bottomRight:
                    path.move(to: CGPoint(x: handleSize/2 - lineLen, y: handleSize/2))
                    path.addLine(to: CGPoint(x: handleSize/2, y: handleSize/2))
                    path.addLine(to: CGPoint(x: handleSize/2, y: handleSize/2 - lineLen))
                }
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: lineThick, lineCap: .round, lineJoin: .miter))
        }
        .frame(width: handleSize, height: handleSize)
        .position(x: position.x, y: position.y)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { val in
                    if dragStartCropRect == nil {
                        dragStartCropRect = cropRect
                    }
                    guard let start = dragStartCropRect else { return }
                    updateCropRectOnCornerDrag(corner: corner, translation: val.translation, startRect: start, containerSize: containerSize)
                }
                .onEnded { _ in
                    dragStartCropRect = nil
                }
        )
    }
    
    private func updateCropRectOnCornerDrag(corner: CornerHandle, translation: CGSize, startRect: CGRect, containerSize: CGSize) {
        let minSize: CGFloat = 60
        let margin: CGFloat = 12
        
        var newX = startRect.minX
        var newY = startRect.minY
        var newW = startRect.width
        var newH = startRect.height
        
        switch corner {
        case .topLeft:
            let targetX = min(startRect.maxX - minSize, max(margin, startRect.minX + translation.width))
            let targetY = min(startRect.maxY - minSize, max(margin, startRect.minY + translation.height))
            newX = targetX
            newY = targetY
            newW = startRect.maxX - newX
            newH = startRect.maxY - newY
            
        case .topRight:
            let targetX = max(startRect.minX + minSize, min(containerSize.width - margin, startRect.maxX + translation.width))
            let targetY = min(startRect.maxY - minSize, max(margin, startRect.minY + translation.height))
            newW = targetX - startRect.minX
            newY = targetY
            newH = startRect.maxY - newY
            
        case .bottomLeft:
            let targetX = min(startRect.maxX - minSize, max(margin, startRect.minX + translation.width))
            let targetY = max(startRect.minY + minSize, min(containerSize.height - margin, startRect.maxY + translation.height))
            newX = targetX
            newW = startRect.maxX - newX
            newH = targetY - startRect.minY
            
        case .bottomRight:
            let targetX = max(startRect.minX + minSize, min(containerSize.width - margin, startRect.maxX + translation.width))
            let targetY = max(startRect.minY + minSize, min(containerSize.height - margin, startRect.maxY + translation.height))
            newW = targetX - startRect.minX
            newH = targetY - startRect.minY
        }
        
        // If locked ratio is selected, adjust height to maintain ratio
        if let ratio = selectedRatio.ratio {
            newH = newW / ratio
        }
        
        cropRect = CGRect(x: newX, y: newY, width: newW, height: newH)
    }
    
    // MARK: - Render & Crop CoreGraphics
    private func renderAndSave() {
        // 1. Fix orientation & Apply Rotate / Flip
        var processed = fixOrientation(inputImage)
        if rotationDegrees != 0 || isFlippedHorizontally {
            let normalizedDegrees = (Int(rotationDegrees) % 360 + 360) % 360
            processed = rotateAndFlipImage(processed, degrees: normalizedDegrees, flipHorizontal: isFlippedHorizontally) ?? processed
        }
        
        // 2. Crop accurately using cropRect
        if cropRect.width > 0, cropRect.height > 0, let cropped = cropImageToRect(processed, cropRect: cropRect) {
            processed = cropped
        }
        
        onSave(processed)
    }
    
    private func fixOrientation(_ img: UIImage) -> UIImage {
        if img.imageOrientation == .up, img.cgImage != nil { return img }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        img.draw(in: CGRect(origin: .zero, size: img.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? img
        UIGraphicsEndImageContext()
        return normalized
    }
    
    private func cropImageToRect(_ img: UIImage, cropRect: CGRect) -> UIImage? {
        let normalizedImg = fixOrientation(img)
        guard let cgImg = normalizedImg.cgImage else { return img }
        
        let imgPixelWidth = CGFloat(cgImg.width)
        let imgPixelHeight = CGFloat(cgImg.height)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = max(300, UIScreen.main.bounds.height - 120)
        
        let aspectWidth = screenWidth / imgPixelWidth
        let aspectHeight = screenHeight / imgPixelHeight
        let aspectFitScale = min(aspectWidth, aspectHeight)
        
        let fittedWidth = imgPixelWidth * aspectFitScale * scale
        let fittedHeight = imgPixelHeight * aspectFitScale * scale
        
        let centerX = screenWidth / 2 + offset.width
        let centerY = screenHeight / 2 + offset.height
        
        let imgOriginX = centerX - fittedWidth / 2
        let imgOriginY = centerY - fittedHeight / 2
        
        let relX = max(0, min(1.0, (cropRect.minX - imgOriginX) / max(1, fittedWidth)))
        let relY = max(0, min(1.0, (cropRect.minY - imgOriginY) / max(1, fittedHeight)))
        let relW = max(0.05, min(1.0 - relX, cropRect.width / max(1, fittedWidth)))
        let relH = max(0.05, min(1.0 - relY, cropRect.height / max(1, fittedHeight)))
        
        let cropPixelX = relX * imgPixelWidth
        let cropPixelY = relY * imgPixelHeight
        let cropPixelW = relW * imgPixelWidth
        let cropPixelH = relH * imgPixelHeight
        
        let pixelRect = CGRect(x: cropPixelX, y: cropPixelY, width: cropPixelW, height: cropPixelH)
        
        if let croppedCG = cgImg.cropping(to: pixelRect) {
            return UIImage(cgImage: croppedCG, scale: img.scale, orientation: .up)
        }
        return img
    }
    
    private func rotateAndFlipImage(_ img: UIImage, degrees: Int, flipHorizontal: Bool) -> UIImage? {
        let normalizedImg = fixOrientation(img)
        guard let cgImg = normalizedImg.cgImage else { return img }
        
        let radians = CGFloat(degrees) * .pi / 180.0
        var newSize = CGRect(origin: .zero, size: normalizedImg.size)
            .applying(CGAffineTransform(rotationAngle: radians)).size
        newSize.width = floor(abs(newSize.width))
        newSize.height = floor(abs(newSize.height))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, normalizedImg.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return img }
        
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        if flipHorizontal {
            context.scaleBy(x: -1.0, y: 1.0)
        }
        context.rotate(by: radians)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let drawRect = CGRect(x: -normalizedImg.size.width / 2, y: -normalizedImg.size.height / 2, width: normalizedImg.size.width, height: normalizedImg.size.height)
        context.draw(cgImg, in: drawRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
