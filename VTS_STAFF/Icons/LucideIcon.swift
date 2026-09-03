//
//  LucideIcon.swift
//  VTS_STAFF
//
//  Created by Antigravity on 03/09/2026.
//  Thành phần hiển thị Lucide Icons chuẩn (https://lucide.dev/icons/)
//

import SwiftUI

/// Component hiển thị Icon từ thư viện chuẩn Lucide Icons (https://lucide.dev/icons/)
public struct LucideIcon: View {
    public let name: LucideIconName
    public let size: CGFloat
    public let color: Color?
    
    public init(_ name: LucideIconName, size: CGFloat = 20, color: Color? = nil) {
        self.name = name
        self.size = size
        self.color = color
    }
    
    public init(_ stringName: String, size: CGFloat = 20, color: Color? = nil) {
        self.name = LucideIconName.from(string: stringName)
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        Image(name.assetName)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(color ?? .primary)
    }
}

// MARK: - View Extension for Quick Usage
public extension View {
    func lucideIcon(_ name: LucideIconName, size: CGFloat = 20, color: Color? = nil) -> some View {
        HStack(spacing: 6) {
            LucideIcon(name, size: size, color: color)
            self
        }
    }
    
    func lucideIcon(_ name: String, size: CGFloat = 20, color: Color? = nil) -> some View {
        HStack(spacing: 6) {
            LucideIcon(name, size: size, color: color)
            self
        }
    }
}
