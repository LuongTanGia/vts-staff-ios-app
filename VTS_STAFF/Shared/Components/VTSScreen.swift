
//
//  VTSScreen.swift
//  VTS_STAFF
//
//  Screen-level wrappers:
//    • VTSScreenBackground  – nền gradient cho mọi màn hình
//    • VTSAsyncContent      – tự động xử lý loading/error/empty/success
//    • VTSNavigationHeader  – header tuỳ chỉnh
//    • VTSPageContainer     – toàn bộ khung màn hình
//

import SwiftUI

// MARK: - ============================================================
//                  VTSScreenBackground
// MARK: - ============================================================

struct VTSScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient.vtsBackground
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func vtsBackground() -> some View {
        modifier(VTSScreenBackground())
    }
}

// MARK: - ============================================================
//      VTSAsyncContent – generic state wrapper cho mọi list screen
// MARK: - ============================================================

/// State enum cho async data
enum VTSViewState<T> {
    case idle
    case loading
    case success(T)
    case empty
    case failure(String)
}

struct VTSAsyncContent<T, Content: View, Empty: View>: View {
    let state: VTSViewState<T>
    let emptyView: () -> Empty
    let content: (T) -> Content
    let retry: (() -> Void)?
    let asyncRetry: (() async -> Void)?
    
    init(
        state: VTSViewState<T>,
        retry: (() -> Void)? = nil,
        asyncRetry: (() async -> Void)? = nil,
        @ViewBuilder emptyView: @escaping () -> Empty,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.state      = state
        self.retry      = retry
        self.asyncRetry = asyncRetry
        self.emptyView  = emptyView
        self.content    = content
    }
    
    var body: some View {
        switch state {
        case .idle:
            Color.vtsPrimary
        case .loading:
            VTSLoadingView()
        case .success(let data):
            content(data)
        case .empty:
            if let asyncRetry {
                VTSScrollableStateContainer(onRefresh: asyncRetry) {
                    emptyView()
                }
            } else if let retry {
                VTSScrollableStateContainer(onRefresh: retry) {
                    emptyView()
                }
            } else {
                emptyView()
            }
        case .failure(let msg):
            let action: (() -> Void)? = {
                if let asyncRetry {
                    return { Task { await asyncRetry() } }
                }
                return retry
            }()
            
            if let asyncRetry {
                VTSScrollableStateContainer(onRefresh: asyncRetry) {
                    VTSErrorState(msg, retry: action)
                }
            } else if let retry {
                VTSScrollableStateContainer(onRefresh: retry) {
                    VTSErrorState(msg, retry: action)
                }
            } else {
                VTSErrorState(msg, retry: action)
            }
        }
    }
}

// Convenience overload với EmptyState mặc định
extension VTSAsyncContent where Empty == VTSEmptyState {
    init(
        state: VTSViewState<T>,
        emptyTitle: String = "Không có dữ liệu",
        emptySubtitle: String? = nil,
        emptyIcon: String = "tray.fill",
        retry: (() -> Void)? = nil,
        asyncRetry: (() async -> Void)? = nil,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.init(
            state: state,
            retry: retry,
            asyncRetry: asyncRetry,
            emptyView: {
                VTSEmptyState(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle,
                              actionTitle: (retry != nil || asyncRetry != nil) ? "Tải lại" : nil,
                              action: {
                    if let asyncRetry {
                        Task { await asyncRetry() }
                    } else {
                        retry?()
                    }
                })
            },
            content: content
        )
    }
}

// MARK: - ============================================================
//            VTSScrollableStateContainer (Scrollable Pull-To-Refresh)
// MARK: - ============================================================

struct VTSScrollableStateContainer<Content: View>: View {
    let onRefresh: () async -> Void
    @ViewBuilder let content: () -> Content
    
    init(onRefresh: @escaping () async -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onRefresh = onRefresh
        self.content = content
    }
    
    init(onRefresh: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.onRefresh = {
            onRefresh?()
        }
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    content()
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, minHeight: geo.size.height)
            }
            .scrollBounceBehavior(.always, axes: .vertical)
            .refreshable {
                await onRefresh()
            }
        }
    }
}

// MARK: - ============================================================
//               VTSPageContainer (full screen wrapper)
// MARK: - ============================================================

struct VTSPageContainer<Content: View>: View {
    var hasGradient: Bool = true
    @ViewBuilder let content: () -> Content
    
    init(hasGradient: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.hasGradient = hasGradient
        self.content = content
    }
    
    var body: some View {
        ZStack {
            if hasGradient {
                LinearGradient.vtsBackground.ignoresSafeArea()
            } else {
                Color.vtsPrimary.ignoresSafeArea()
            }
            
            content()
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - ============================================================
//               VTSConfirmDialog (xác nhận hành động nguy hiểm)
// MARK: - ============================================================

struct VTSConfirmDialog: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmLabel: String
    let confirmStyle: VTSButtonStyle
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        content.alert(title, isPresented: $isPresented) {
            Button(confirmLabel, role: confirmStyle == .destructive ? .destructive : nil, action: onConfirm)
            Button("Hủy", role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}

extension View {
    func vtsConfirm(
        isPresented: Binding<Bool>,
        title: String = "Xác nhận",
        message: String,
        confirmLabel: String = "Xác nhận",
        confirmStyle: VTSButtonStyle = .destructive,
        
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(VTSConfirmDialog(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            confirmStyle: confirmStyle,
            onConfirm: onConfirm
        ))
    }
}

// MARK: - ============================================================
//               VTSDivider & Section Separator
// MARK: - ============================================================

struct VTSDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.vtsBorder)
            .frame(height: 1)
    }
}

// MARK: - ============================================================
//               VTSImagePlaceholder (ảnh + base64)
// MARK: - ============================================================

/// Hiển thị ảnh từ base64 string, fallback về icon nếu nil
struct VTSBase64Image: View {
    let base64: String?
    let size: CGFloat
    let cornerRadius: CGFloat
    let placeholder: String
    
    init(base64: String?, size: CGFloat = 80, cornerRadius: CGFloat = VTSRadius.md,
         placeholder: String = "photo.fill") {
        self.base64       = base64
        self.size         = size
        self.cornerRadius = cornerRadius
        self.placeholder  = placeholder
    }
    
    var body: some View {
        Group {
            if let base64, let image = UIImage.fromBase64(base64) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.vtsSurface
                    Image(systemName: placeholder)
                        .font(.system(size: size * 0.3))
                        .foregroundColor(.vtsTxtTertiary)
                }
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.vtsBorder, lineWidth: 1)
        )
    }
}

// MARK: - ============================================================
//               VTSFormKeyboardAdaptive (Nâng UI form khi mở bàn phím)
// MARK: - ============================================================

struct VTSFormKeyboardAdaptiveModifier: ViewModifier {
    @Binding var keyboardHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .ignoresSafeArea(edges: .bottom)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
                    withAnimation(.easeOut(duration: duration)) {
                        self.keyboardHeight = keyboardFrame.height
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
                let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
                withAnimation(.easeOut(duration: duration)) {
                    self.keyboardHeight = 0
                }
            }
            .onDisappear {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    self.keyboardHeight = 0
                }
            }
    }
}

extension View {
    func vtsFormKeyboardAdaptive(keyboardHeight: Binding<CGFloat>) -> some View {
        modifier(VTSFormKeyboardAdaptiveModifier(keyboardHeight: keyboardHeight))
    }
}

// MARK: - Preview
#Preview("Screen wrapper") {
    VTSPageContainer {
        VStack(spacing: 20) {
            // Mô phỏng state loading
            VTSAsyncContent(
                state: VTSViewState<[String]>.loading,
                emptyTitle: "Không có phiếu"
            ) { _ in EmptyView() }
                .frame(height: 150)
            
            VTSAsyncContent(
                state: VTSViewState<[String]>.empty,
                emptyTitle: "Không có phiếu",
                emptySubtitle: "Chưa có phiếu nhập nào trong khoảng thời gian này",
                emptyIcon: "doc.text"
            ) { _ in EmptyView() }
                .frame(height: 200)
        }
    }
}
