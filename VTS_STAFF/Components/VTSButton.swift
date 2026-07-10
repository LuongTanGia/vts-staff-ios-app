
//
//  VTSButton.swift
//  VTS_STAFF
//
//  Các kiểu button: Primary, Secondary, Outline, Destructive, Icon, Ghost
//

import SwiftUI

// MARK: - Button Style Enum
enum VTSButtonStyle {
    case primary      // Gradient xanh
    case secondary    // Surface mờ
    case outline      // Viền, trong suốt
    case destructive  // Đỏ
    case ghost        // Không nền
}

// MARK: - VTSButton
struct VTSButton: View {
    
    let title: String
    let icon: String?
    let style: VTSButtonStyle
    let size: VTSButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    enum VTSButtonSize { case small, medium, large }
    
    // Convenience init
    init(
        _ title: String,
        icon: String? = nil,
        style: VTSButtonStyle = .primary,
        size: VTSButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title      = title
        self.icon       = icon
        self.style      = style
        self.size       = size
        self.isLoading  = isLoading
        self.isDisabled = isDisabled
        self.action     = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(textColor)
                        .scaleEffect(0.8)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .semibold))
                }
                if !title.isEmpty {
                    Text(title)
                        .font(titleFont)
                }
            }
            .foregroundColor(textColor)
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .frame(maxWidth: size == .large ? .infinity : nil)
            .background(background)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 4)
            .opacity(isDisabled || isLoading ? 0.5 : 1)
        }
        .disabled(isDisabled || isLoading)
        .animation(.easeInOut(duration: 0.15), value: isLoading)
        .buttonStyle(VTSPressButtonStyle())
    }
    
    // MARK: Computed properties
    private var height: CGFloat {
        switch size {
        case .small:  return 34
        case .medium: return 44
        case .large:  return 52
        }
    }
    private var horizontalPadding: CGFloat {
        switch size {
        case .small:  return 12
        case .medium: return 18
        case .large:  return 20
        }
    }
    private var cornerRadius: CGFloat {
        switch size {
        case .small:  return VTSRadius.sm
        case .medium: return VTSRadius.md
        case .large:  return VTSRadius.lg
        }
    }
    private var titleFont: Font {
        switch size {
        case .small:  return .vtsCaption.bold()
        case .medium: return .vtsCallout.bold()
        case .large:  return .vtsBody.bold()
        }
    }
    private var iconSize: CGFloat { size == .small ? 12 : 14 }
    
    @ViewBuilder private var background: some View {
        switch style {
        case .primary:     Color.vtsPrimary
        case .destructive: LinearGradient.vtsDanger
        case .secondary:   Color.vtsSurfaceMid
        case .outline:     Color.clear
        case .ghost:       Color.clear
        }
    }
    private var textColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary:             return .vtsTxtPrimary
        case .outline:               return .vtsPrimary
        case .ghost:                 return .vtsTxtSecondary
        }
    }
    private var borderColor: Color {
        switch style {
        case .outline: return .vtsPrimary.opacity(0.6)
        default:       return .clear
        }
    }
    private var borderWidth: CGFloat { style == .outline ? 1.5 : 0 }
    private var shadowColor: Color {
        switch style {
        case .primary:     return .vtsPrimary.opacity(0.35)
        case .destructive: return .vtsDanger.opacity(0.35)
        default:           return .clear
        }
    }
    private var shadowRadius: CGFloat { style == .primary || style == .destructive ? 10 : 0 }
}

// MARK: - Icon-only Button
struct VTSIconButton: View {
    let icon: String
    let style: VTSButtonStyle
    let size: CGFloat
    let action: () -> Void
    
    init(_ icon: String, style: VTSButtonStyle = .secondary, size: CGFloat = 40, action: @escaping () -> Void) {
        self.icon   = icon
        self.style  = style
        self.size   = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(style == .destructive ? .vtsDanger : .vtsPrimary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(style == .destructive
                              ? Color.vtsDanger.opacity(0.12)
                              : Color.vtsSurfaceMid)
                )
        }
        .buttonStyle(VTSPressButtonStyle())
    }
}

// MARK: - Press animation button style
struct VTSPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Buttons") {
    ZStack {
        LinearGradient.vtsBackground.ignoresSafeArea()
        VStack(spacing: 16) {
            VTSButton("Đăng nhập", icon: "arrow.right", style: .primary, size: .large) {}
            VTSButton("Huỷ bỏ", icon: "xmark", style: .secondary) {}
            VTSButton("Thêm mới", icon: "plus", style: .outline) {}
            VTSButton("Xoá", icon: "trash", style: .destructive, size: .small) {}
            HStack {
                VTSIconButton("plus", style: .primary) {}
                VTSIconButton("trash", style: .destructive) {}
                VTSIconButton("pencil") {}
            }
        }
        .padding()
    }
}
