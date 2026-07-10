//
//  LoginView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
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
                            Text("VTS STAFF")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.vtsBg)
                                .tracking(2)
                            
                            Text("Hệ thống quản lý vận chuyển nội bộ")
                                .font(.vtsCallout)
                                .foregroundColor(.vtsBg)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    
                    // MARK: Glass Form Card
                    VTSGlassCard {
                        VStack(spacing: VTSSpacing.xl) {
                            Text("ĐĂNG NHẬP")
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .tracking(1)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                // Username Field
                                VTSInputField(
                                    label: "Tên đăng nhập",
                                    placeholder: "Nhập tài khoản nhân viên...",
                                    text: $viewModel.username,
                                    icon: "person.fill"
                                )
                                .focused($isFocused)
                                
                                // Password Field
                                VTSInputField(
                                    label: "Mật khẩu",
                                    placeholder: "Nhập mật khẩu an toàn...",
                                    text: $viewModel.password,
                                    icon: "lock.fill",
                                    isSecure: true
                                )
                                .focused($isFocused)
                            }
                            
                            
                            
                            
                            // MARK: Submit Button & FaceID
                            HStack(spacing: VTSSpacing.md) {
                                VTSButton(
                                    "Đăng nhập",
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
                                        Image(systemName: "faceid")
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
                    
                    // MARK: Footer Version
                    Text("Phiên bản 1.0.0 (VTS Tech)")
                        .font(.vtsCaption)
                        .foregroundColor(.vtsTxtTertiary)
                        .padding(.bottom, 20)
                }
                .padding(VTSSpacing.xl)
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            viewModel.checkBiometricAvailability()
            if viewModel.enableBiometrics {
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                    await viewModel.loginWithBiometrics()
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
