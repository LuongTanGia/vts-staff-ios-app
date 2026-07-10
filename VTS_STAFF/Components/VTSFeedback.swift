
//
//  VTSFeedback.swift
//  VTS_STAFF
//
//  Feedback components: LoadingView, SkeletonView, EmptyState, ErrorState, Toast
//

import SwiftUI

// MARK: - ============================================================
//                     LOADING SPINNER
// MARK: - ============================================================

struct VTSLoadingView: View {
    let message: String
    
    init(_ message: String = "Đang tải...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: VTSSpacing.xl) {
            ZStack {
                Circle()
                    .stroke(Color.vtsBorder, lineWidth: 3)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        LinearGradient.vtsPrimary,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                    .modifier(SpinModifier())
            }
            Text(message)
                .font(.vtsCallout)
                .foregroundColor(.vtsTxtSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Spin animation modifier
private struct SpinModifier: ViewModifier {
    @State private var angle: Double = 0
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(angle))
            .onAppear {
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
    }
}

// MARK: - ============================================================
//                     SKELETON LOADING
// MARK: - ============================================================

struct VTSSkeleton: View {
    let width: CGFloat?
    let height: CGFloat
    let radius: CGFloat
    
    @State private var shimmerPhase: CGFloat = -1
    
    init(width: CGFloat? = nil, height: CGFloat = 16, radius: CGFloat = VTSRadius.sm) {
        self.width  = width
        self.height = height
        self.radius = radius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Color.vtsPrimary)
            .frame(width: width, height: height)
            .overlay(shimmerOverlay)
            .clipped()
    }
    
    private var shimmerOverlay: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [.clear, Color.white.opacity(0.08), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 2)
            .offset(x: shimmerPhase * geo.size.width * 2)
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    shimmerPhase = 1
                }
            }
        }
    }
}

// MARK: - Skeleton cho list row
struct VTSSkeletonRow: View {
    var body: some View {
        HStack(spacing: VTSSpacing.md) {
            VTSSkeleton(width: 38, height: 38, radius: VTSRadius.sm)
            VStack(alignment: .leading, spacing: VTSSpacing.sm) {
                VTSSkeleton(height: 14)
                VTSSkeleton(width: 140, height: 11)
            }
            Spacer()
            VTSSkeleton(width: 60, height: 12)
        }
        .padding(.horizontal, VTSSpacing.xl)
        .padding(.vertical, VTSSpacing.md)
        .background(Color.vtsSurface)
        .cornerRadius(VTSRadius.md)
    }
}

// MARK: - ============================================================
//                     EMPTY STATE
// MARK: - ============================================================

struct VTSEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "tray.fill",
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon        = icon
        self.title       = title
        self.subtitle    = subtitle
        self.actionTitle = actionTitle
        self.action      = action
    }
    
    var body: some View {
        VStack(spacing: VTSSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.vtsBg.opacity(0.08))
                    .frame(width: 90, height: 90)
                Image(systemName: icon)
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.vtsPrimary.opacity(0.5))
            }
            
            VStack(spacing: VTSSpacing.sm) {
                Text(title)
                    .font(.vtsTitle2)
                    .foregroundColor(.vtsTxtPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.vtsCallout)
                        .foregroundColor(.vtsTxtSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let actionTitle, let action {
                VTSButton(actionTitle, icon: "arrow.clockwise", style: .outline, action: action)
            }
            
            Spacer()
        }
        .padding(VTSSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ============================================================
//                     ERROR STATE
// MARK: - ============================================================

struct VTSErrorState: View {
    let error: String
    let retry: (() -> Void)?
    
    init(_ error: String, retry: (() -> Void)? = nil) {
        self.error = error
        self.retry = retry
    }
    
    var body: some View {
        VStack(spacing: VTSSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.vtsDanger.opacity(0.08))
                    .frame(width: 90, height: 90)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.vtsDanger.opacity(0.6))
            }
            
            VStack(spacing: VTSSpacing.sm) {
                Text("Đã xảy ra lỗi")
                    .font(.vtsTitle2)
                    .foregroundColor(.vtsTxtPrimary)
                Text(error)
                    .font(.vtsCallout)
                    .foregroundColor(.vtsTxtSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let retry {
                VTSButton("Thử lại", icon: "arrow.clockwise", style: .outline, action: retry)
            }
            
            Spacer()
        }
        .padding(VTSSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ============================================================
//                      TOAST NOTIFICATION
// MARK: - ============================================================

enum VTSToastType { case success, error, warning, info }

struct VTSToast: View {
    let message: String
    let type: VTSToastType
    
    private var color: Color {
        switch type {
        case .success: return .vtsSuccess
        case .error:   return .vtsDanger
        case .warning: return .vtsWarning
        case .info:    return .vtsPrimary
        }
    }
    private var icon: String {
        switch type {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: VTSSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
            Text(message)
                .font(.vtsCallout.bold())
                .foregroundColor(.vtsTxtPrimary)
        }
        .padding(.horizontal, VTSSpacing.xl)
        .padding(.vertical, VTSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: VTSRadius.xxl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: VTSRadius.xxl)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.2), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Toast Modifier (dùng .vtsToast() trên View)
struct VTSToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let type: VTSToastType
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if isPresented {
                VTSToast(message: message, type: type)
                    .padding(.top, 60)
                    .padding(.horizontal, VTSSpacing.xxl)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation { isPresented = false }
                        }
                    }
                    .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
    }
}

extension View {
    /// Hiển thị toast notification ở đầu màn hình
    func vtsToast(isPresented: Binding<Bool>, message: String, type: VTSToastType = .success, duration: TimeInterval = 2.5) -> some View {
        modifier(VTSToastModifier(isPresented: isPresented, message: message, type: type, duration: duration))
    }
}

// MARK: - Preview
#Preview("Feedback") {
    ZStack {
        LinearGradient.vtsBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            VTSLoadingView("Đang tải dữ liệu...")
                .frame(height: 120)
            
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in VTSSkeletonRow() }
            }
            .padding(.horizontal)
            
            VTSToast(message: "Lưu thành công!", type: .success)
            VTSToast(message: "Kết nối thất bại", type: .error)
        }
    }
    .preferredColorScheme(.dark)
}
