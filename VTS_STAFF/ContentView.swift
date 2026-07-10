//
//  ContentView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/6/26.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var errorManager = ErrorManager.shared
    @State private var isSplashActive = true
    @State private var isBiometricVerified = false
    @State private var isAuthenticatingBiometrics = false
    
    // Luồng quản lý tự động đăng nhập lại bằng FaceID khi Token hết hạn
    @State private var showFaceIDWaitingScreen = false
    @State private var isFaceIDLoggingIn = false

    var body: some View {
        ZStack {
            if isSplashActive {
                VTSSplashView()
                    .transition(.opacity)
            } else {
                Group {
                    if showFaceIDWaitingScreen {
                        BiometricUnlockView(
                            onUnlockAttempt: {
                                triggerFaceIDLogin()
                            },
                            onLogout: {
                                withAnimation {
                                    showFaceIDWaitingScreen = false
                                    authManager.logout()
                                }
                            }
                        )
                        .overlay {
                            if isFaceIDLoggingIn {
                                ZStack {
                                    Color.black.opacity(0.4)
                                        .ignoresSafeArea()
                                    
                                    VStack(spacing: 12) {
                                        ProgressView()
                                            .tint(.white)
                                            .controlSize(.large)
                                        
                                        Text("Đang kết nối lại...")
                                            .font(.vtsCallout)
                                            .foregroundColor(.white)
                                    }
                                    .padding(VTSSpacing.xl)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(VTSRadius.lg)
                                }
                            }
                        }
                        .transition(.opacity)
                    } else if authManager.isLoggedIn {
                        if isBiometricVerified {
                            MainTabView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else {
                            BiometricUnlockView(
                                onUnlockAttempt: {
                                    triggerAppLaunchBiometrics()
                                },
                                onLogout: {
                                    withAnimation {
                                        authManager.logout()
                                    }
                                }
                            )
                            .transition(.opacity)
                        }
                    } else {
                        LoginView()
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isSplashActive)
        .animation(.easeInOut(duration: 0.35), value: authManager.isLoggedIn)
        .animation(.easeInOut(duration: 0.35), value: isBiometricVerified)
        .animation(.easeInOut(duration: 0.35), value: showFaceIDWaitingScreen)
        .vtsToast(isPresented: $errorManager.showToast, message: errorManager.toastMessage, type: errorManager.toastType)
        .alert(errorManager.alertTitle, isPresented: $errorManager.showAlert) {
            Button("Xác nhận", role: .cancel) {}
        } message: {
            Text(errorManager.alertMessage)
        }
        .onAppear {
            // Thực hiện luồng kiểm tra phiên làm việc song song với hiệu ứng splash
            Task {
                let startTime = Date()
                
                if authManager.isLoggedIn {
                    await checkSessionAndLoginFlow()
                } else {
                    isBiometricVerified = true
                }
                
                // Đảm bảo splash tối thiểu hiển thị 2.5 giây cho hiệu ứng chuyển động mượt mà
                let elapsed = Date().timeIntervalSince(startTime)
                let remaining = max(0, 2.5 - elapsed)
                
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                
                withAnimation {
                    isSplashActive = false
                }
            }
        }
        .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                isBiometricVerified = true
            }
        }
    }
    
    // MARK: - Kiểm tra phiên làm việc (Session Verification)
    private func checkSessionAndLoginFlow() async {
        do {
            // Thực hiện cuộc gọi thử API cần xác thực để kiểm tra token
            _ = try await DashboardService.shared.nhanVienInOut()
            
            // API thành công -> Phiên vẫn còn hiệu lực
            await MainActor.run {
                if UserDefaults.standard.bool(forKey: "vts_enable_biometrics") {
                    isBiometricVerified = false
                    triggerAppLaunchBiometrics()
                } else {
                    isBiometricVerified = true
                }
            }
        } catch {
            // API thất bại -> NetworkManager tự động gọi refreshAccessToken()
            // Nếu refreshAccessToken() cũng thất bại -> AuthManager tự động logout & clear token
            // Khi đó isLoggedIn đã trở về false
            
            await MainActor.run {
                let biometricsEnabled = UserDefaults.standard.bool(forKey: "vts_enable_biometrics")
                let hasSavedCredentials = KeychainHelper.shared.load(forKey: "vts_saved_username") != nil &&
                                          KeychainHelper.shared.load(forKey: "vts_saved_password") != nil
                
                if biometricsEnabled && hasSavedCredentials {
                    // Chuyển sang màn hình chờ FaceID để tự động đăng nhập lại
                    withAnimation {
                        showFaceIDWaitingScreen = true
                    }
                } else {
                    // Không cài đặt sinh trắc học -> chuyển thẳng về login
                    withAnimation {
                        showFaceIDWaitingScreen = false
                    }
                }
            }
        }
    }
    
    // MARK: - Quét FaceID và đăng nhập lại
    private func triggerFaceIDLogin() {
        guard !isAuthenticatingBiometrics else { return }
        isAuthenticatingBiometrics = true
        
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Thiết bị không hỗ trợ FaceID -> Về login
            withAnimation {
                showFaceIDWaitingScreen = false
                isAuthenticatingBiometrics = false
            }
            return
        }
        
        Task {
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "Đăng nhập lại vào ứng dụng VTS STAFF"
                )
                
                if success {
                    if let savedUser = KeychainHelper.shared.load(forKey: "vts_saved_username"),
                       let savedPass = KeychainHelper.shared.load(forKey: "vts_saved_password") {
                        
                        await MainActor.run {
                            isFaceIDLoggingIn = true
                        }
                        
                        // Tiến hành gọi API Đăng nhập
                        do {
                            _ = try await AuthService.shared.dangNhap(user: savedUser, pass: savedPass)
                            
                            await MainActor.run {
                                withAnimation {
                                    isBiometricVerified = true
                                    showFaceIDWaitingScreen = false
                                    isFaceIDLoggingIn = false
                                }
                            }
                        } catch {
                            // Đăng nhập qua API lỗi -> Về Login
                            await MainActor.run {
                                withAnimation {
                                    showFaceIDWaitingScreen = false
                                    isFaceIDLoggingIn = false
                                }
                            }
                        }
                    } else {
                        // Không tìm thấy credentials -> Về login
                        await MainActor.run {
                            withAnimation {
                                showFaceIDWaitingScreen = false
                            }
                        }
                    }
                } else {
                    // Quét FaceID thất bại -> Về login
                    await MainActor.run {
                        withAnimation {
                            showFaceIDWaitingScreen = false
                        }
                    }
                }
                
                await MainActor.run {
                    isAuthenticatingBiometrics = false
                }
            } catch {
                await MainActor.run {
                    withAnimation {
                        showFaceIDWaitingScreen = false
                        isAuthenticatingBiometrics = false
                    }
                }
            }
        }
    }

    // MARK: - Mở khóa sinh trắc học khi mở app (Trường hợp session vẫn còn hạn)
    private func triggerAppLaunchBiometrics() {
        guard !isAuthenticatingBiometrics else { return }
        isAuthenticatingBiometrics = true
        
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            withAnimation {
                authManager.logout()
                isAuthenticatingBiometrics = false
            }
            return
        }
        
        Task {
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "Xác thực FaceID để mở khóa ứng dụng VTS STAFF"
                )
                
                await MainActor.run {
                    withAnimation {
                        if success {
                            isBiometricVerified = true
                        } else {
                            authManager.logout()
                        }
                        isAuthenticatingBiometrics = false
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation {
                        authManager.logout()
                        isAuthenticatingBiometrics = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
