//
//  SettingsView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

import SwiftUI
import SwiftfulRouting

struct SettingsView: View {
    @Environment(\.router) private var router
    @ObservedObject private var authManager = AuthManager.shared
    
    @AppStorage("vts_enable_notifications") private var enableNotifications = true
    @AppStorage("vts_enable_biometrics") private var enableBiometrics = false
    @AppStorage("vts_remember_account") private var savePasswordLocal = true
    
    // Hàng Nhận (Nhập)
    @AppStorage("vts_show_nhap_homnay") private var showNhapHomNay = true
    @AppStorage("vts_show_nhap_tuannay") private var showNhapTuanNay = false
    @AppStorage("vts_show_nhap_tuantruoc") private var showNhapTuanTruoc = false
    
    // Hàng Giao (Xuất)
    @AppStorage("vts_show_xuat_homnay") private var showXuatHomNay = true
    @AppStorage("vts_show_xuat_tuannay") private var showXuatTuanNay = false
    @AppStorage("vts_show_xuat_tuantruoc") private var showXuatTuanTruoc = false
    
    @State private var showLogoutConfirm = false
    
    private var hasHomePermission: Bool {
        authManager.getPermission(for: "VTSSTAFF_DASBOARD_NHANVIEN")?.visible == true &&
        authManager.getPermission(for: "VTSSTAFF_DASBOARD_NHANVIEN")?.view == true
    }
    
    var body: some View {
        VTSPageContainer {
            ScrollView(showsIndicators: false) {
                VStack(spacing: VTSSpacing.xl) {
                    
                    // MARK: General Settings
                    VTSGlassCard {
                        VStack(alignment: .leading, spacing: VTSSpacing.xl) {
                            Text("Cấu hình chung")
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                // Notification Switch
                                Toggle(isOn: $enableNotifications) {
                                    Label {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Thông báo đẩy")
                                                .font(.vtsCallout.bold())
                                                .foregroundColor(.vtsTxtPrimary)
                                            Text("Nhận thông báo khi có phiếu vận chuyển mới")
                                                .font(.vtsCaption)
                                                .foregroundColor(.vtsTxtSecondary)
                                        }
                                    } icon: {
                                        Image(systemName: "bell.badge.fill")
                                            .foregroundColor(.vtsPrimary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                // FaceID / TouchID Switch
                                Toggle(isOn: $enableBiometrics) {
                                    Label {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Xác thực sinh trắc học")
                                                .font(.vtsCallout.bold())
                                                .foregroundColor(.vtsTxtPrimary)
                                            Text("Sử dụng FaceID / Vân tay để mở khóa")
                                                .font(.vtsCaption)
                                                .foregroundColor(.vtsTxtSecondary)
                                        }
                                    } icon: {
                                        Image(systemName: "faceid")
                                            .foregroundColor(.vtsPrimary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                // Save Password Switch
                                Toggle(isOn: $savePasswordLocal) {
                                    Label {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Ghi nhớ tài khoản")
                                                .font(.vtsCallout.bold())
                                                .foregroundColor(.vtsTxtPrimary)
                                            Text("Lưu tài khoản đăng nhập cho lần sau")
                                                .font(.vtsCaption)
                                                .foregroundColor(.vtsTxtSecondary)
                                        }
                                    } icon: {
                                        Image(systemName: "key.fill")
                                            .foregroundColor(.vtsPrimary)
                                    }
                                }
                                .tint(.vtsPrimary)
                            }
                        }
                    }
                    
                    // MARK: Nhận (Nhập) Settings Card
                    VTSGlassCard {
                        VStack(alignment: .leading, spacing: VTSSpacing.xl) {
                            Text("Dữ liệu Hàng nhận (Nhập)")
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                Toggle(isOn: $showNhapHomNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu hôm nay")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng nhận hôm nay")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showNhapTuanNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần này")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng nhận tuần này")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showNhapTuanTruoc) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần trước")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng nhận tuần trước")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                            }
                        }
                    }
                    .disabled(!hasHomePermission)
                    .opacity(hasHomePermission ? 1.0 : 0.6)
                    
                    // MARK: Giao (Xuất) Settings Card
                    VTSGlassCard {
                        VStack(alignment: .leading, spacing: VTSSpacing.xl) {
                            Text("Dữ liệu Hàng giao (Xuất)")
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                Toggle(isOn: $showXuatHomNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu hôm nay")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng giao hôm nay")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showXuatTuanNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần này")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng giao tuần này")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showXuatTuanTruoc) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần trước")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng giao tuần trước")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                            }
                        }
                    }
                    .disabled(!hasHomePermission)
                    .opacity(hasHomePermission ? 1.0 : 0.6)
                    
                    // MARK: Danger Logout Button
                    VTSButton(
                        "Đăng xuất khỏi hệ thống",
                        icon: "rectangle.portrait.and.arrow.right",
                        style: .destructive,
                        size: .large
                    ) {
                        showLogoutConfirm = true
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(VTSSpacing.xl)
            }
        }
        .onChange(of: savePasswordLocal) { _, newValue in
            if !newValue {
                enableBiometrics = false
            }
        }
        .onChange(of: enableBiometrics) { _, newValue in
            if newValue && !savePasswordLocal {
                savePasswordLocal = true
            }
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
            subtitle: "Cài đặt"
            
        ){
            
        } trailing: {
            
            Button(
                "Options",
                systemImage: "ellipsis"
            ) {
                
            }
            
        } primaryAction: {
            
        }
    }
}

#Preview {
    RouterView { _ in
        SettingsView()
    }
}
