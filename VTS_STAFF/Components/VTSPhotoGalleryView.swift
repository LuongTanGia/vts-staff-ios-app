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
    let onClose: () -> Void
    
    @State private var zoomScale: CGFloat = 1.0
    @State private var showOCRText: Bool = true
    
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
                        if let img = item.image {
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
            .onChange(of: selectedIndex) { _, _ in
                zoomScale = 1.0
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
                    
                    Button(action: onClose) {
                        LucideIcon(.xCircle, size: 18, color: .gray)
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                    }
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
                                    .fill(item.id == selectedIndex ? Color.white : (item.image != nil ? Color.blue.opacity(0.6) : Color.white.opacity(0.2)))
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
        .ignoresSafeArea()
    }
}
