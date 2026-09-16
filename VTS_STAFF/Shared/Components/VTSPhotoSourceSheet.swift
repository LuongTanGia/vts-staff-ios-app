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
                    LucideIcon(.xCircle, size: 18, color: .gray)
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
                        LucideIcon(.camera, size: 22, color: .vtsPrimary)
                            .font(.system(size: 20))
                            .foregroundColor(.vtsPrimary)
                            .frame(width: 42, height: 42)
                            .background(Color.vtsPrimary.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Chụp ảnh")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.vtsTxtPrimary)
                        
                        Spacer()
                        
                        LucideIcon(.chevronRight, size: 14, color: .gray.opacity(0.6))
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
                        LucideIcon(.image, size: 22, color: Color(hex: "0284C7"))
                            .font(.system(size: 20))
                            .foregroundColor(.vtsPrimary)
                            .frame(width: 42, height: 42)
                            .background(Color.vtsPrimary.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("Chọn từ thư viện")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.vtsTxtPrimary)
                        
                        Spacer()
                        
                        LucideIcon(.chevronRight, size: 14, color: .gray.opacity(0.6))
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
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
    }
}
