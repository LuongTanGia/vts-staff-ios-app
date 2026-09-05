//
//  VTSPhotoGalleryView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 11/08/2026.
//

import SwiftUI

struct VTSPhotoGalleryItem: Identifiable {
    let id: Int
    let title: String
    let image: UIImage?
    let ocrText: String?
}

struct VTSPhotoGalleryView: View {
    let items: [VTSPhotoGalleryItem]
    @Binding var selectedIndex: Int
    var isEditable: Bool = false
    var onUpdateImage: ((Int, UIImage) -> Void)? = nil
    var onFetchFullImage: ((Int) async -> UIImage?)? = nil
    let onClose: () -> Void
    
    @State private var zoomScale: CGFloat = 1.0
    @State private var showOCRText: Bool = true
    @State private var editingImage: IdentifiableImage? = nil
    @State private var localUpdatedImages: [Int: UIImage] = [:]
    @State private var loadedOriginalImages: [Int: UIImage] = [:]
    @State private var loadingSlotIds: Set<Int> = []
    
    private func getImage(for item: VTSPhotoGalleryItem) -> UIImage? {
        localUpdatedImages[item.id] ?? loadedOriginalImages[item.id] ?? item.image
    }
    
    private func fetchFullImageIfNeeded(for slotId: Int) {
        guard let onFetchFullImage = onFetchFullImage else { return }
        guard loadedOriginalImages[slotId] == nil && localUpdatedImages[slotId] == nil else { return }
        guard !loadingSlotIds.contains(slotId) else { return }
        
        // Chỉ fetch nếu slot này đã có ảnh (thumbnail hoặc initial)
        guard let item = items.first(where: { $0.id == slotId }), item.image != nil else { return }
        
        loadingSlotIds.insert(slotId)
        Task {
            if let fullImg = await onFetchFullImage(slotId) {
                await MainActor.run {
                    loadedOriginalImages[slotId] = fullImg
                    loadingSlotIds.remove(slotId)
                }
            } else {
                await MainActor.run {
                    loadingSlotIds.remove(slotId)
                }
            }
        }
    }
    
    var currentItem: VTSPhotoGalleryItem? {
        items.first(where: { $0.id == selectedIndex }) ?? items.first
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            
            // Paging TabView
            TabView(selection: $selectedIndex) {
                ForEach(items) { item in
                    ZStack {
                        if let img = getImage(for: item) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(zoomScale)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            zoomScale = value
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) {
                                                zoomScale = 1.0
                                            }
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    withAnimation(.spring()) {
                                        zoomScale = zoomScale > 1.0 ? 1.0 : 2.0
                                    }
                                }
                            
                            // Loading indicator for full image
                            if loadingSlotIds.contains(item.id) {
                                VStack {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        Text("Đang tải ảnh gốc...")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(Color.black.opacity(0.65))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    )
                                    .padding(.top, 100)
                                    
                                    Spacer()
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.exclamationmark")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.4))
                                Text(item.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Chưa có ảnh ở ô này")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }
                    .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: selectedIndex) { _, newIndex in
                zoomScale = 1.0
                fetchFullImageIfNeeded(for: newIndex)
            }
            .onAppear {
                fetchFullImageIfNeeded(for: selectedIndex)
            }
            
            // Overlay controls (Header & Footer)
            VStack {
                // Top Bar
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentItem?.title ?? "")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("Ảnh \(selectedIndex) / \(items.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Nút Sửa ảnh khi isEditable == true và có ảnh hiện tại
                    if isEditable, let current = currentItem, let img = getImage(for: current) {
                        Button {
                            editingImage = IdentifiableImage(image: img)
                        } label: {
                            HStack(spacing: 6) {
                                LucideIcon(.crop, size: 16, color: .white)
                                Text("Sửa ảnh")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.22))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                        }
                        .buttonStyle(VTSPressButtonStyle())
                    }
                    
                    Button(action: onClose) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 36, height: 36)
                            LucideIcon(.x, size: 18, color: .white)
                        }
                    }
                    .buttonStyle(VTSPressButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)
                .padding(.bottom, 12)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.8), Color.black.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
                
                // Navigation Buttons (Left / Right) & Scanned Text Box
                VStack(spacing: 12) {
                    // Left / Right navigation bar
                    HStack {
                        Button {
                            if selectedIndex > 1 {
                                withAnimation {
                                    selectedIndex -= 1
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                LucideIcon(.chevronLeft, size: 16)
                                Text("Ảnh trước")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedIndex > 1 ? .white : .white.opacity(0.3))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(20)
                        }
                        .disabled(selectedIndex <= 1)
                        
                        Spacer()
                        
                        // Page Dots / Selector
                        HStack(spacing: 6) {
                            ForEach(items) { item in
                                Circle()
                                    .fill(item.id == selectedIndex ? Color.white : (getImage(for: item) != nil ? Color.blue.opacity(0.6) : Color.white.opacity(0.2)))
                                    .frame(width: item.id == selectedIndex ? 8 : 6, height: item.id == selectedIndex ? 8 : 6)
                                    .onTapGesture {
                                        withAnimation {
                                            selectedIndex = item.id
                                        }
                                    }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            if selectedIndex < items.count {
                                withAnimation {
                                    selectedIndex += 1
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Ảnh sau")
                                LucideIcon(.chevronRight, size: 14, color: .gray.opacity(0.6))
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedIndex < items.count ? .white : .white.opacity(0.3))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(20)
                        }
                        .disabled(selectedIndex >= items.count)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0), Color.black.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .fullScreenCover(item: $editingImage) { item in
            VTSImageEditorView(
                inputImage: item.image,
                onSave: { croppedImg in
                    localUpdatedImages[selectedIndex] = croppedImg
                    onUpdateImage?(selectedIndex, croppedImg)
                    editingImage = nil
                },
                onCancel: {
                    editingImage = nil
                }
            )
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}
