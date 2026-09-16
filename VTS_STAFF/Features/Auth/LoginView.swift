//
//  LoginView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct LoginView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let appTitle = "VTS STAFF"
        static let appSubtitle = "Hệ thống quản lý vận chuyển nội bộ"
        static let formTitle = "ĐĂNG NHẬP"
        static let usernameLabel = "Tên đăng nhập"
        static let usernamePlaceholder = "Nhập tài khoản nhân viên..."
        static let passwordLabel = "Mật khẩu"
        static let passwordPlaceholder = "Nhập mật khẩu an toàn..."
        static let agreePrefix = "Tôi đồng ý với"
        static let termsTitle = "Điều khoản dịch vụ"
        static let termsSheetTitle = "Điều khoản sử dụng"
        static let loginButton = "Đăng nhập"
        static let version = "Phiên bản 1.0.0 (VTS Tech)"
    }

    @StateObject private var viewModel = LoginViewModel()
    @State private var showPolicySheet: Bool = false
    
    // Focus state for dismiss keyboard
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VTSPageContainer(hasGradient: false) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: VTSSpacing.xxxl) {
                    
                    Spacer(minLength: 40)
                    
                    // MARK: Logo & Title Area
                    VStack(spacing: VTSSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient.vtsPrimary)
                                .frame(width: 80, height: 80)
                                .shadow(color: .vtsPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "person.badge.key.fill")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: VTSSpacing.xs) {
                            Text(Strings.appTitle)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.vtsBg)
                                .tracking(2)
                            
                            Text(Strings.appSubtitle)
                                .font(.vtsCallout)
                                .foregroundColor(.vtsBg)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    
                    // MARK: Glass Form Card
                    VTSGlassCard {
                        VStack(spacing: VTSSpacing.xl) {
                            Text(Strings.formTitle)
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .tracking(1)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                // Username Field
                                VTSInputField(
                                    label: Strings.usernameLabel,
                                    placeholder: Strings.usernamePlaceholder,
                                    text: $viewModel.username,
                                    icon: "person.fill"
                                )
                                .focused($isFocused)
                                
                                // Password Field
                                VTSInputField(
                                    label: Strings.passwordLabel,
                                    placeholder: Strings.passwordPlaceholder,
                                    text: $viewModel.password,
                                    icon: "lock.fill",
                                    isSecure: true
                                )
                                .focused($isFocused)
                            }
                            // MARK: Terms & Conditions Checkbox
                            HStack(alignment: .center, spacing: 8) {
                                Button {
                                    if !viewModel.hasAcceptedTerms {
                                        showPolicySheet = true
                                    } else {
                                        viewModel.hasAcceptedTerms.toggle()
                                    }
                                } label: {
                                    Image(systemName: viewModel.hasAcceptedTerms ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(viewModel.hasAcceptedTerms ? .vtsPrimary : .gray)
                                }
                                .buttonStyle(.plain)
                                
                                HStack(spacing: 4) {
                                    Text(Strings.agreePrefix)
                                        .foregroundColor(.vtsTxtSecondary)
                                    Button {
                                        showPolicySheet = true
                                    } label: {
                                        Text(Strings.termsTitle)
                                            .foregroundColor(.vtsPrimary)
                                            .fontWeight(.semibold)
                                            .underline()
                                    }
                                    .buttonStyle(.plain)
                                }
                                .font(.system(size: 13))
                                
                                Spacer()
                            }
                            .padding(.top, 2)
                            
                            // MARK: Submit Button & FaceID
                            HStack(spacing: VTSSpacing.md) {
                                VTSButton(
                                    Strings.loginButton,
                                    icon: "arrow.right.circle.fill",
                                    style: .primary,
                                    size: .large,
                                    isLoading: viewModel.isLoading,
                                    isDisabled: viewModel.isSubmitDisabled
                                ) {
                                    isFocused = false
                                    Task {
                                        await viewModel.login()
                                    }
                                }
                                
                                if viewModel.showBiometricButton {
                                    Button {
                                        isFocused = false
                                        Task {
                                            await viewModel.loginWithBiometrics()
                                        }
                                    } label: {
                                        LucideIcon(.scanFace, size: 28, color: .vtsPrimary)
                                            .font(.system(size: 26))
                                            .foregroundColor(.vtsPrimary)
                                            .frame(width: 52, height: 52)
                                            .background(Color.white.opacity(0.07))
                                            .cornerRadius(VTSRadius.lg)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: VTSRadius.lg)
                                                    .stroke(Color.vtsPrimary.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(VTSPressButtonStyle())
                                }
                            }
                            .padding(.top, VTSSpacing.sm)
                        }
                    }
                    .padding(.horizontal, VTSSpacing.sm)
                    
                    Spacer(minLength: 40)
                    
                    // MARK: Footer Policy & Version
                    VStack(spacing: 8) {
                        Button {
                            showPolicySheet = true
                        } label: {
                            HStack(spacing: 6) {
                                LucideIcon(.info, size: 15, color: .vtsTxtSecondary)
                                Text(Strings.termsTitle)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.vtsTxtSecondary)
                                    .underline()
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Text(Strings.version)
                            .font(.vtsCaption)
                            .foregroundColor(.vtsTxtTertiary)
                    }
                    .padding(.bottom, 20)
                }
                .padding(VTSSpacing.xl)
            }
        }
        .environment(\.colorScheme, .light)
        .sheet(isPresented: $showPolicySheet) {
            RouterView { _ in
                PolicyDocumentView(
                    documentName: "terms",
                    title: Strings.termsSheetTitle,
                    showAcceptButton: true,
                    onAccept: {
                        viewModel.hasAcceptedTerms = true
                    }
                )
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            viewModel.checkBiometricAvailability()
            
            // Chỉ hỏi điều khoản lần đầu vào app nếu chưa từng chấp nhận
            if !viewModel.hasAcceptedTerms {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showPolicySheet = true
                }
            } else if viewModel.enableBiometrics {
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                    await viewModel.loginWithBiometrics()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.checkBiometricAvailability()
        }
    }
}

#Preview {
    LoginView()
}
