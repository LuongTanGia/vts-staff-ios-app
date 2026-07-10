import Foundation
import SwiftUI
import Combine
import LocalAuthentication

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isDemoMode = false
    @Published var isLoading = false
    
    @Published var savePasswordLocal = true
    @Published var enableBiometrics = false
    @Published var showBiometricButton = false
    
    private let authService: AuthService
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? .shared
        
        // Tải cấu hình từ UserDefaults
        self.savePasswordLocal = UserDefaults.standard.object(forKey: "vts_remember_account") as? Bool ?? true
        self.enableBiometrics = UserDefaults.standard.bool(forKey: "vts_enable_biometrics")
        
        checkBiometricAvailability()
    }
    
    var isSubmitDisabled: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty
    }
    
    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        
        // Kiểm tra phần cứng/chính sách và cấu hình người dùng bật sinh trắc học
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let userEnabled = UserDefaults.standard.bool(forKey: "vts_enable_biometrics")
            let hasCredentials = KeychainHelper.shared.load(forKey: "vts_saved_username") != nil &&
            KeychainHelper.shared.load(forKey: "vts_saved_password") != nil
            
            self.showBiometricButton = userEnabled && hasCredentials
            self.enableBiometrics = userEnabled
        } else {
            self.showBiometricButton = false
            self.enableBiometrics = false
        }
    }
    
    func loginWithBiometrics() async {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Đăng nhập nhanh vào ứng dụng VTS STAFF"
            )
            
            if success {
                if let savedUser = KeychainHelper.shared.load(forKey: "vts_saved_username"),
                   let savedPass = KeychainHelper.shared.load(forKey: "vts_saved_password") {
                    
                    self.username = savedUser
                    self.password = savedPass
                    
                    await login()
                } else {
                    ErrorManager.shared.showWarning("Không tìm thấy thông tin đăng nhập đã lưu trong Keychain.")
                }
            }
        } catch {
            print("Biometric Authentication error: \(error.localizedDescription)")
        }
    }
    
    func login() async {
        isLoading = true
        
        do {
            if isDemoMode {
                // Simulate delay for modern aesthetic feels
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1s
                
                // Save Mock Session directly to AuthManager
                AuthManager.shared.saveSession(
                    access: "mock_jwt_token_for_vts_staff_bypass",
                    refresh: "mock_refresh_token_id_123456",
                    hoTen: "Nguyễn Văn A",
                    maNV: "NV009",
                    avatar: nil,
                    chucNangPhanQuyens: [
                        TChucNangPhanQuyen(sapXep: "1", nhomChucNang: "01", tenNhomChucNang: "Hệ thống", maChucNang: "SYS_PROFILE", tenChucNang: "Thông tin cá nhân", ghiChu: "Thông tin hồ sơ nhân viên", allowVisible: true, allowView: true, allowAdd: false, allowDel: false, allowEdit: true, allowRun: true, allowExcel: false, allowToolbar: true, visible: true, view: true, add: false, del: false, edit: true, run: true, excel: false, toolbar: true),
                        TChucNangPhanQuyen(sapXep: "2", nhomChucNang: "01", tenNhomChucNang: "Hệ thống", maChucNang: "SYS_SETTINGS", tenChucNang: "Cấu hình hệ thống", ghiChu: "Thiết lập cấu hình chung", allowVisible: true, allowView: true, allowAdd: false, allowDel: false, allowEdit: true, allowRun: true, allowExcel: false, allowToolbar: true, visible: true, view: true, add: false, del: false, edit: true, run: true, excel: false, toolbar: true),
                        TChucNangPhanQuyen(sapXep: "1", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "WEIGH_TICKET", tenChucNang: "Danh sách phiếu cân", ghiChu: "Xem và quản lý phiếu cân hàng hóa", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true),
                        TChucNangPhanQuyen(sapXep: "2", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "TRIP_SCHEDULING", tenChucNang: "Lịch trình xe chạy", ghiChu: "Lịch trình phân phối vận chuyển", allowVisible: true, allowView: true, allowAdd: true, allowDel: false, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: false, edit: true, run: true, excel: true, toolbar: true),
                        TChucNangPhanQuyen(sapXep: "3", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "VTSSTAFF_DANHMUC_XE", tenChucNang: "Danh mục xe", ghiChu: "Quản lý danh sách phương tiện vận tải", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true),
                        TChucNangPhanQuyen(sapXep: "4", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "VTSSTAFF_DANHMUC_KHACHHANG", tenChucNang: "Danh mục đối tác", ghiChu: "Quản lý danh sách khách hàng & nhà cung cấp", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true),
                        TChucNangPhanQuyen(sapXep: "1", nhomChucNang: "03", tenNhomChucNang: "Quản trị nhân sự", maChucNang: "HRM_LIST", tenChucNang: "Danh mục nhân viên", ghiChu: "Danh sách hồ sơ nhân sự", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true)
                    ]
                )
                
                // Luôn âm thầm lưu thông tin tài khoản vào Keychain
                KeychainHelper.shared.save(username, forKey: "vts_saved_username")
                KeychainHelper.shared.save(password, forKey: "vts_saved_password")
                UserDefaults.standard.set(savePasswordLocal, forKey: "vts_remember_account")
                
                ErrorManager.shared.showSuccess("Đăng nhập giả lập thành công!")
                isLoading = false
            } else {
                // Real API Authentication
                let userTrimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
                _ = try await authService.dangNhap(user: userTrimmed, pass: password)
                
                // Luôn âm thầm lưu thông tin tài khoản vào Keychain
                KeychainHelper.shared.save(userTrimmed, forKey: "vts_saved_username")
                KeychainHelper.shared.save(password, forKey: "vts_saved_password")
                UserDefaults.standard.set(savePasswordLocal, forKey: "vts_remember_account")
                
                ErrorManager.shared.showSuccess("Đăng nhập thành công!")
                isLoading = false
            }
        } catch {
            ErrorManager.shared.handleAlert(error, title: "Đăng nhập thất bại")
            isLoading = false
        }
    }
}
