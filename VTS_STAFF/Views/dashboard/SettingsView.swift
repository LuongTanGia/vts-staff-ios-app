//
//  SettingsView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting
import LocalAuthentication
import UserNotifications

struct SettingsView: View {
    @Environment(\.router) private var router
    @ObservedObject private var authManager = AuthManager.shared
    
    // AppStorage Settings
    @AppStorage("vts_enable_biometrics") private var enableBiometrics = false
    @AppStorage("vts_notify_ticket_created") private var notifyTicketCreated = true
    @AppStorage("vts_notify_ticket_deleted") private var notifyTicketDeleted = true
    
    // Hàng Nhận (Nhập)
    @AppStorage("vts_show_nhap_homnay") private var showNhapHomNay = true
    @AppStorage("vts_show_nhap_tuannay") private var showNhapTuanNay = false
    
    // Hàng Giao (Xuất)
    @AppStorage("vts_show_xuat_homnay") private var showXuatHomNay = true
    @AppStorage("vts_show_xuat_tuannay") private var showXuatTuanNay = false
    
    // Device / UI States
    @State private var isBiometricsAvailable = false
    @State private var savedUsername = "gia"
    @State private var showLogoutConfirm = false
    
    private var userInitials: String {
        let name = authManager.hoTen ?? savedUsername
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let last = parts[parts.count - 1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "V"
    }
    
    var body: some View {
        VTSPageContainer {
            ScrollView(showsIndicators: false) {
                VStack(spacing: VTSSpacing.lg) {
                    
                    // MARK: - 1. User Profile Hero Header Card
                    VTSGlassCard {
                        HStack(spacing: VTSSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.vtsPrimary)
                                    .frame(width: 52, height: 52)
                                    .shadow(color: Color.vtsPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
                                
                                Text(userInitials)
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(authManager.hoTen ?? savedUsername)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color(hex: "0F2D59"))
                                
                                HStack(spacing: 6) {
                                    Text("@\(savedUsername)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.vtsTxtSecondary)
                                    
                                    if let maNV = authManager.maNV, !maNV.isEmpty {
                                        Text("• \(maNV)")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.vtsPrimary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.vtsPrimary.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // MARK: - 2. Bảo mật & Xác thực
                    settingsSection(title: "BẢO MẬT & XÁC THỰC", icon: "shield.lock.fill") {
                        VStack(spacing: 0) {
                            settingRow(
                                icon: "faceid",
                                iconBg: Color.purple,
                                title: "Sử dụng Face ID thay cho mã bảo vệ"
                            ) {
                                Toggle("", isOn: $enableBiometrics)
                                    .labelsHidden()
                                    .tint(.vtsPrimary)
                                    .disabled(!isBiometricsAvailable)
                            }
                        }
                    }
                    
                    // MARK: - 3. Thông báo
                    settingsSection(title: "THÔNG BÁO", icon: "bell.badge.fill") {
                        VStack(spacing: 0) {
                            settingRow(
                                icon: "doc.badge.plus",
                                iconBg: Color.indigo,
                                title: "Nhận thông báo khi phiếu được Tạo"
                            ) {
                                Toggle("", isOn: $notifyTicketCreated)
                                    .labelsHidden()
                                    .tint(.vtsPrimary)
                            }
                            
                            VTSDivider()
                                .padding(.leading, 46)
                            
                            settingRow(
                                icon: "doc.badge.gearshape",
                                iconBg: Color.pink,
                                title: "Nhận thông báo khi phiếu được Xóa"
                            ) {
                                Toggle("", isOn: $notifyTicketDeleted)
                                    .labelsHidden()
                                    .tint(.vtsPrimary)
                            }
                        }
                    }
                    
                    // MARK: - 4. Hiển thị Dashboard
                    settingsSection(title: "HIỂN THỊ DASHBOARD", icon: "chart.bar.fill") {
                        VStack(spacing: 0) {
                            // Thống kê hàng nhận (Nhập) - Xếp trên/dưới
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                                            .fill(Color.blue.opacity(0.12))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "arrow.down.square.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Text("Hiện thống kê hàng nhận")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                }
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Hôm nay")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        Spacer()
                                        Toggle("", isOn: $showNhapHomNay)
                                            .labelsHidden()
                                            .tint(.vtsPrimary)
                                    }
                                    
                                    HStack {
                                        Text("Tuần này")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        Spacer()
                                        Toggle("", isOn: $showNhapTuanNay)
                                            .labelsHidden()
                                            .tint(.vtsPrimary)
                                    }
                                }
                                .padding(.leading, 44)
                            }
                            .padding(.vertical, 4)
                            
                            VTSDivider()
                                .padding(.leading, 46)
                            
                            // Thống kê hàng giao (Xuất) - Xếp trên/dưới
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                                            .fill(Color.green.opacity(0.12))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "arrow.up.square.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.green)
                                    }
                                    
                                    Text("Hiện thống kê hàng giao")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                }
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Hôm nay")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        Spacer()
                                        Toggle("", isOn: $showXuatHomNay)
                                            .labelsHidden()
                                            .tint(.vtsPrimary)
                                    }
                                    
                                    HStack {
                                        Text("Tuần này")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        Spacer()
                                        Toggle("", isOn: $showXuatTuanNay)
                                            .labelsHidden()
                                            .tint(.vtsPrimary)
                                    }
                                }
                                .padding(.leading, 44)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Button Đăng xuất khỏi tài khoản
                    Button(action: { showLogoutConfirm = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 15, weight: .bold))
                            Text("Đăng xuất khỏi tài khoản")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.vtsDanger, Color.red.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.vtsDanger.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 4)
                    
                    Spacer(minLength: 20)
                }
                .padding(VTSSpacing.xl)
            }
        }
        .task {
            updateDeviceSettingsState()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            updateDeviceSettingsState()
        }
        .vtsConfirm(
            isPresented: $showLogoutConfirm,
            title: "Đăng xuất",
            message: "Bạn có chắc muốn đăng xuất khỏi ứng dụng?",
            confirmLabel: "Đăng xuất"
        ) {
            Task {
                await AuthService.shared.dangXuat()
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Cài đặt",
            isWhiteText: true
        ) {
            EmptyView()
        } trailing: {
            EmptyView()
        } primaryAction: {
            EmptyView()
        }
    }
    
    // MARK: - Modern UI Helper Components
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.vtsPrimary)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.vtsTxtSecondary)
            }
            .padding(.leading, 4)
            
            VTSGlassCard {
                content()
            }
        }
    }
    
    private func settingRow<Control: View>(
        icon: String,
        iconBg: Color,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder control: @escaping () -> Control
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(iconBg.opacity(0.12))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(iconBg)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "0F2D59"))
                
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.vtsTxtSecondary)
                }
            }
            
            Spacer()
            
            control()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Device Settings Synchronization
    private func updateDeviceSettingsState() {
        // 1. Check Biometrics Availability from Device
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        self.isBiometricsAvailable = canEvaluate
        if !canEvaluate {
            self.enableBiometrics = false
        }
        
        // 2. Username Display
        if let saved = KeychainHelper.shared.load(forKey: "vts_saved_username"), !saved.isEmpty {
            self.savedUsername = saved
        } else if let maNV = authManager.maNV, !maNV.isEmpty {
            self.savedUsername = maNV
        } else {
            self.savedUsername = "gia"
        }
    }
}

#Preview {
    RouterView { _ in
        SettingsView()
    }
}
