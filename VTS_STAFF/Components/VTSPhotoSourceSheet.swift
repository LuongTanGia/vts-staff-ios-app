//
//  VTSPhotoSourceSheet.swift
//  VTS_STAFF
//
//  Created by Antigravity on 27/07/2026.
//

import SwiftUI

struct VTSPhotoSourceSheet: View {
    let onCamera: () -> Void
    let onLibrary: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Chọn nguồn ảnh")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.vtsTxtPrimary)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.vtsTxtTertiary)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Options
            VStack(spacing: 12) {
                Button {
                    onCamera()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.vtsPrimary)
                            .frame(width: 42, height: 42)
                            .background(Color.vtsPrimary.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Chụp ảnh")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.vtsTxtPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.vtsTxtTertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
                
                Button {
                    onLibrary()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 20))
                            .foregroundColor(.vtsPrimary)
                            .frame(width: 42, height: 42)
                            .background(Color.vtsPrimary.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Chọn từ thư viện")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.vtsTxtPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.vtsTxtTertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(230)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
    }
}
