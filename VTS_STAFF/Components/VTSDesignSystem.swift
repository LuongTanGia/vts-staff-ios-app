
//
//  VTSDesignSystem.swift
//  VTS_STAFF
//
//  Design token: màu sắc, typography, spacing, radius
//  Tất cả component đều import file này để đảm bảo nhất quán.
//

import SwiftUI

// MARK: - ============================================================
//                         COLOR PALETTE
// MARK: - ============================================================

public extension Color {
    // Brand
    public static let vtsPrimary     = Color(hex: "003258")  // Deep navy (md_theme_primary)
    public static let vtsSecondary   = Color(hex: "565C67")  // Slate gray (md_theme_secondary)
    public static let vtsAccent      = Color(hex: "00497C")  // Primary container (md_theme_primaryContainer)
    
    // Background
    public static let vtsBg          = Color(hex: "F9F9FE")  // Light background (md_theme_background)
    public static let vtsBgMid       = Color(hex: "F0EDED")  // Surface container (md_theme_surfaceContainer)
    public static let vtsBgLight     = Color(hex: "E5E2E2")  // Surface container highest (md_theme_surfaceContainerHighest)
    
    // Surface (card/input)
    public static let vtsSurface     = Color(hex: "FCF8F9")  // Surface (md_theme_surface)
    public static let vtsSurfaceMid  = Color(hex: "F6F3F3")  // Surface container low (md_theme_surfaceContainerLow)
    
    // Status
    public static let vtsDanger      = Color(hex: "BA1A1A")  // Error (md_theme_error)
    public static let vtsWarning     = Color(hex: "926800")  // MyYColor
    public static let vtsSuccess     = Color(hex: "1B5E20")  // MyGColor / Tertiary (#3F6745 is also available as md_theme_tertiary)
    public static let vtsInfo        = Color(hex: "0093BC")  // logo color
    
    // Text
    public static let vtsTxtPrimary  = Color(hex: "191C1F")  // On background (md_theme_onBackground)
    public static let vtsTxtSecondary = Color(hex: "43474C")  // On surface variant (md_theme_onSurfaceVariant)
    public static let vtsTxtTertiary  = Color(hex: "74777D")  // Outline (md_theme_outline)
    
    // Border
    public static let vtsBorder      = Color(hex: "C4C6CD")  // Outline variant (md_theme_outlineVariant)
    public static let vtsBorderFocus = Color(hex: "003258").opacity(0.7)
}

// MARK: - ============================================================
//                         TYPOGRAPHY
// MARK: - ============================================================

extension Font {
    // Core hierarchy
    static let vtsLargeTitle = Font.system(size: 28, weight: .bold,   design: .rounded)
    static let vtsTitle      = Font.system(size: 20, weight: .bold,   design: .rounded)
    static let vtsTitle2     = Font.system(size: 17, weight: .semibold)
    static let vtsHeadline   = Font.system(size: 15, weight: .semibold)
    static let vtsBody       = Font.system(size: 15, weight: .regular)
    static let vtsCallout    = Font.system(size: 13, weight: .regular)
    static let vtsCaption    = Font.system(size: 12, weight: .regular)
    static let vtsMono       = Font.system(size: 13, weight: .regular, design: .monospaced)
    
    // Unified Semantic Styles
    static let vtsContent        = vtsBody              // Nội dung chính
    static let vtsScreenTitle    = vtsTitle             // Tiêu đề màn hình
    static let vtsScreenSubtitle = vtsHeadline          // Chi tiết tiêu đề màn hình
    static let vtsTableHeader    = vtsCallout.bold()    // Tiêu đề cột của bảng
    static let vtsTableContent   = vtsCallout           // Nội dung trong bảng
    static let vtsTableFooter    = vtsCallout.bold()    // Tổng kết ở cuối bảng (footer)
    static let vtsFooter         = vtsCaption           // Chú thích, thông tin chân trang
}

// MARK: - ============================================================
//                         SPACING
// MARK: - ============================================================

enum VTSSpacing {
    static let xs  : CGFloat = 4
    static let sm  : CGFloat = 8
    static let md  : CGFloat = 12
    static let lg  : CGFloat = 16
    static let xl  : CGFloat = 20
    static let xxl : CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - ============================================================
//                         RADIUS
// MARK: - ============================================================

enum VTSRadius {
    static let sm  : CGFloat = 8
    static let md  : CGFloat = 12
    static let lg  : CGFloat = 16
    static let xl  : CGFloat = 20
    static let xxl : CGFloat = 24
}

// MARK: - ============================================================
//                     GRADIENT HELPERS
// MARK: - ============================================================

extension LinearGradient {
    static let vtsPrimary = LinearGradient(
        colors: [.vtsPrimary, .vtsSecondary],
        startPoint: .leading, endPoint: .trailing
    )
    static let vtsBackground = LinearGradient(
        colors: [.vtsBg, .vtsBgMid, .vtsBgLight],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let vtsDanger = LinearGradient(
        colors: [Color(hex: "BA1A1A"), Color(hex: "93000A")],
        startPoint: .leading, endPoint: .trailing
    )
    static let vtsSuccess = LinearGradient(
        colors: [Color(hex: "1B5E20"), Color(hex: "093316")],
        startPoint: .leading, endPoint: .trailing
    )
    static let vtsWarning = LinearGradient(
        colors: [Color(hex: "926800"), Color(hex: "684900")],
        startPoint: .leading, endPoint: .trailing
    )
}




extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
