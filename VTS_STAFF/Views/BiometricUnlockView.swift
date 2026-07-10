//
//  BiometricUnlockView.swift
//  VTS_STAFF
//
//  Created by viettas on 01/07/2026.
//

import SwiftUI

struct BiometricUnlockView: View {
    let onUnlockAttempt: () -> Void
    let onLogout: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VStack(spacing: VTSSpacing.xxxl) {
                Spacer()
                
                // MARK: Icon FaceID & Glow Animation
                VStack(spacing: VTSSpacing.xl) {
                    ZStack {
                        // Vòng tròn hào quang phát sáng đằng sau
                        Circle()
                            .fill(Color.vtsPrimary.opacity(0.12))
                            .frame(width: 140, height: 140)
                            .scaleEffect(isAnimating ? 1.2 : 0.9)
                            .opacity(isAnimating ? 0.6 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.vtsPrimary.opacity(0.6), .vtsSecondary.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: isAnimating)
                        
                        // Icon FaceID
                        Image(systemName: "faceid")
                            .font(.system(size: 64))
                            .foregroundColor(.vtsPrimary)
                            .scaleEffect(isAnimating ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    }
                    
                    VStack(spacing: VTSSpacing.sm) {
                        Text("Ứng dụng đang khóa")
                            .font(.vtsTitle.bold())
                            .foregroundColor(.vtsTxtPrimary)
                        
                        Text("Xác thực FaceID để mở khóa ứng dụng VTS STAFF")
                            .font(.vtsCallout)
                            .foregroundColor(.vtsTxtSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, VTSSpacing.xxl)
                    }
                }
                
                Spacer()
                
                // MARK: Actions Area
                VStack(spacing: VTSSpacing.lg) {
                    VTSButton(
                        "Mở khóa bằng Face ID",
                        icon: "faceid",
                        style: .primary,
                        size: .large
                    ) {
                        onUnlockAttempt()
                    }
                    
                    VTSButton(
                        "Đăng nhập tài khoản khác",
                        icon: "rectangle.portrait.and.arrow.right",
                        style: .ghost,
                        size: .medium
                    ) {
                        onLogout()
                    }
                }
                .padding(.horizontal, VTSSpacing.xl)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isAnimating = true
            // Tự động gọi lần xác thực đầu tiên khi view hiển thị
            onUnlockAttempt()
        }
    }
}

#Preview {
    BiometricUnlockView(
        onUnlockAttempt: {},
        onLogout: {}
    )
}
