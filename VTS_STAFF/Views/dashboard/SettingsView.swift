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
    // MARK: - UI Text Strings
    private enum Strings {
        static let toolbarTitle = "Cài đặt"
        static let btnDangXuat = "Đăng xuất khỏi tài khoản"
        static let confirmLogoutTitle = "Đăng xuất"
        static let confirmLogoutMessage = "Bạn có chắc muốn đăng xuất khỏi ứng dụng?"
        static let sectionBaoMat = "BẢO MẬT & XÁC THỰC"
        static let rowFaceID = "Sử dụng Face ID thay cho mã bảo vệ"
        static let sectionThongBao = "THÔNG BÁO"
        static let rowThongBaoTao = "Nhận thông báo khi phiếu được Tạo"
        static let rowThongBaoXoa = "Nhận thông báo khi phiếu được Xóa"
        static let sectionDashboard = "HIỂN THỊ DASHBOARD"
        static let labelHienThongKeNhan = "Hiện thống kê hàng nhận"
        static let labelHienThongKeGiao = "Hiện thống kê hàng giao"
        static let labelHomNay = "Hôm nay"
        static let labelTuanNay = "Tuần này"
    }

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
    @State private var biometryType: LABiometryType = .none
    @State private var isBiometricsPermissionDenied = false
    @State private var notificationAuthStatus: UNAuthorizationStatus = .notDetermined
    @State private var savedUsername = "gia"
    @State private var showLogoutConfirm = false
    
    private var biometryName: String {
        switch biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Sinh trắc học"
        }
    }
    
    private var biometryIcon: String {
        switch biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.shield"
        }
    }
    
    private var notificationStatusSubtitle: String {
        switch notificationAuthStatus {
        case .authorized, .provisional, .ephemeral:
            return "Đã cho phép trong Cài đặt máy"
        case .denied:
            return "Đã tắt trong Cài đặt máy"
        case .notDetermined:
            return "Chưa cấp quyền thông báo"
        @unknown default:
            return "Không xác định"
        }
    }
    
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
                    settingsSection(title: Strings.sectionBaoMat, icon: "shield.lock.fill") {
                        VStack(spacing: 0) {
                            settingRow(
                                icon: biometryIcon,
                                iconBg: Color.purple,
                                title: "Sử dụng \(biometryName)",
                                subtitle: isBiometricsPermissionDenied
                                    ? "Đã tắt trong Cài đặt máy"
                                    : (isBiometricsAvailable ? "Đăng nhập nhanh thay cho mật khẩu" : "Thiết bị không hỗ trợ hoặc chưa cài đặt")
                            ) {
                                if isBiometricsPermissionDenied {
                                    Button(action: openSystemSettings) {
                                        Text("Cài đặt")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.orange)
                                            .cornerRadius(8)
                                    }
                                } else {
                                    Toggle("", isOn: Binding(
                                        get: { enableBiometrics },
                                        set: { handleToggleBiometrics(newValue: $0) }
                                    ))
                                    .labelsHidden()
                                    .tint(.vtsPrimary)
                                    .disabled(!isBiometricsAvailable)
                                }
                            }
                        }
                    }
                    
                    // MARK: - 3. Thông báo
                    settingsSection(title: Strings.sectionThongBao, icon: "bell.badge.fill") {
                        VStack(spacing: 0) {
                            // Dòng trạng thái quyền thông báo hệ thống máy
                            settingRow(
                                icon: "bell.fill",
                                iconBg: Color.blue,
                                title: "Thông báo hệ thống",
                                subtitle: notificationStatusSubtitle
                            ) {
                                if notificationAuthStatus == .denied {
                                    Button(action: openSystemSettings) {
                                        Text("Cài đặt")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.orange)
                                            .cornerRadius(8)
                                    }
                                } else if notificationAuthStatus == .notDetermined {
                                    Button(action: requestNotificationPermission) {
                                        Text("Cho phép")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.vtsPrimary)
                                            .cornerRadius(8)
                                    }
                                } else {
                                    Text("Đã bật")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.12))
                                        .cornerRadius(8)
                                }
                            }
                            
                            VTSDivider()
                                .padding(.leading, 46)
                            
                            settingRow(
                                icon: "doc.badge.plus",
                                iconBg: Color.indigo,
                                title: Strings.rowThongBaoTao
                            ) {
                                Toggle("", isOn: $notifyTicketCreated)
                                    .labelsHidden()
                                    .tint(.vtsPrimary)
                                    .disabled(notificationAuthStatus != .authorized && notificationAuthStatus != .provisional)
                            }
                            .opacity((notificationAuthStatus == .authorized || notificationAuthStatus == .provisional) ? 1.0 : 0.5)
                            
                            VTSDivider()
                                .padding(.leading, 46)
                            
                            settingRow(
                                icon: "doc.badge.gearshape",
                                iconBg: Color.pink,
                                title: Strings.rowThongBaoXoa
                            ) {
                                Toggle("", isOn: $notifyTicketDeleted)
                                    .labelsHidden()
                                    .tint(.vtsPrimary)
                                    .disabled(notificationAuthStatus != .authorized && notificationAuthStatus != .provisional)
                            }
                            .opacity((notificationAuthStatus == .authorized || notificationAuthStatus == .provisional) ? 1.0 : 0.5)
                        }
                    }
                    
                    // MARK: - 4. Hiển thị Dashboard
                    settingsSection(title: Strings.sectionDashboard, icon: "chart.bar.fill") {
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
                                    
                                    Text(Strings.labelHienThongKeNhan)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                }
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(Strings.labelHomNay)
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        Spacer()
                                        Toggle("", isOn: $showNhapHomNay)
                                            .labelsHidden()
                                            .tint(.vtsPrimary)
                                    }
                                    
                                    HStack {
                                        Text(Strings.labelTuanNay)
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
                                    
                                    Text(Strings.labelHienThongKeGiao)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                }
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(Strings.labelHomNay)
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        Spacer()
                                        Toggle("", isOn: $showXuatHomNay)
                                            .labelsHidden()
                                            .tint(.vtsPrimary)
                                    }
                                    
                                    HStack {
                                        Text(Strings.labelTuanNay)
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
                            LucideIcon(.logOut, size: 18, color: .white)
                            Text(Strings.btnDangXuat)
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(LinearGradient.vtsPrimary)
                        .cornerRadius(20)
                        .shadow(color: Color.vtsPrimary.opacity(0.25), radius: 8, x: 0, y: 4)
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
            title: Strings.confirmLogoutTitle,
            message: Strings.confirmLogoutMessage,
            confirmLabel: Strings.btnDangXuat
        ) {
            Task {
                await AuthService.shared.dangXuat()
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: Strings.toolbarTitle,
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
                LucideIcon(icon, size: 20, color: .vtsPrimary)
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
                
                LucideIcon(icon, size: 20, color: .vtsPrimary)
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
        // 1. Kiểm tra quyền Sinh trắc học (Face ID / Touch ID) từ hệ thống máy
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        self.biometryType = context.biometryType
        self.isBiometricsAvailable = canEvaluate
        
        if canEvaluate {
            self.isBiometricsPermissionDenied = false
        } else {
            if let laError = error as? LAError, laError.code == .biometryNotAvailable && context.biometryType != .none {
                self.isBiometricsPermissionDenied = true
            } else {
                self.isBiometricsPermissionDenied = false
            }
            if enableBiometrics {
                self.enableBiometrics = false
            }
        }
        
        // 2. Kiểm tra quyền Thông báo từ Cài đặt máy
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationAuthStatus = settings.authorizationStatus
            }
        }
        
        // 3. Username Display
        if let saved = KeychainHelper.shared.load(forKey: "vts_saved_username"), !saved.isEmpty {
            self.savedUsername = saved
        } else if let maNV = authManager.maNV, !maNV.isEmpty {
            self.savedUsername = maNV
        } else {
            self.savedUsername = "gia"
        }
    }
    
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                updateDeviceSettingsState()
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func handleToggleBiometrics(newValue: Bool) {
        if newValue {
            if isBiometricsPermissionDenied {
                openSystemSettings()
                return
            }
            let context = LAContext()
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Xác thực \(biometryName) để kích hoạt đăng nhập nhanh") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.enableBiometrics = true
                    } else {
                        self.enableBiometrics = false
                    }
                    updateDeviceSettingsState()
                }
            }
        } else {
            self.enableBiometrics = false
        }
    }
}

#Preview {
    RouterView { _ in
        SettingsView()
    }
}
