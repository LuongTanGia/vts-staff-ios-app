//
//  LucideCatalogView.swift
//  VTS_STAFF
//
//  Created by Antigravity on 03/09/2026.
//  Màn hình Catalog tra cứu toàn bộ thư viện Lucide Icons.
//

import SwiftUI

public struct LucideCatalogView: View {
    @State private var searchText = ""
    @State private var copiedName: String? = nil
    
    private var filteredIcons: [LucideIconName] {
        if searchText.isEmpty {
            return LucideIconName.allCases
        } else {
            return LucideIconName.allCases.filter {
                $0.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                LucideIcon(.search, size: 18, color: .gray)
                TextField("Tìm kiếm Lucide icon...", text: $searchText)
                    .font(.system(size: 14))
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        LucideIcon(.x, size: 16, color: .gray)
                    }
                }
            }
            .padding(10)
            .background(Color(hex: "F1F5F9"))
            .cornerRadius(10)
            .padding(16)
            
            if let copied = copiedName {
                Text("Đã sao chép: LucideIcon(.\(copied))")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.bottom, 6)
            }
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(filteredIcons) { icon in
                        Button(action: {
                            UIPasteboard.general.string = "LucideIcon(.\(icon.rawValue))"
                            withAnimation {
                                copiedName = icon.rawValue
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    copiedName = nil
                                }
                            }
                        }) {
                            VStack(spacing: 8) {
                                LucideIcon(icon, size: 28, color: Color.vtsPrimary)
                                    .frame(height: 32)
                                
                                Text(icon.rawValue)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(Color(hex: "0F2D59"))
                                    .lineLimit(1)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color(hex: "F8FAFC"))
        .navigationTitle("Lucide Icons")
        .navigationBarTitleDisplayMode(.inline)
    }
}
