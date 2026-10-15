import Foundation
import SwiftUI
import Combine
import LocalAuthentication
import AuthenticationServices

@MainActor
final class LoginViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var username = ""
    @Published var password = ""
    @Published var isDemoMode = false
    @Published var isLoading = false
    
    @Published var savePasswordLocal = true
    @Published var enableBiometrics = false
    @Published var showBiometricButton = false
    
    @Published var appleAuthResult: AppleAuthResult? = nil
    
    private var appleAuthController: ASAuthorizationController?
    
    private let termsKey = "vts_has_accepted_terms"
    @Published var hasAcceptedTerms: Bool {
        didSet {
            UserDefaults.standard.set(hasAcceptedTerms, forKey: termsKey)
        }
    }
    
    var isAgreedToPrivacyPolicy: Bool {
        get { hasAcceptedTerms }
        set { hasAcceptedTerms = newValue }
    }
    
    private let authService: AuthService
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? .shared
        
        // Tải cấu hình từ UserDefaults
        self.savePasswordLocal = UserDefaults.standard.object(forKey: "vts_remember_account") as? Bool ?? true
        self.enableBiometrics = UserDefaults.standard.bool(forKey: "vts_enable_biometrics")
        self.hasAcceptedTerms = UserDefaults.standard.bool(forKey: "vts_has_accepted_terms")
        
        super.init()
        checkBiometricAvailability()
    }
    
    var isSubmitDisabled: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.isEmpty ||
        !hasAcceptedTerms
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
        guard hasAcceptedTerms else { return }
        
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
        guard hasAcceptedTerms else {
            showPrivacyWarning()
            return
        }
        isLoading = true
        
        do {
            if isDemoMode {
                // Giả lập độ trễ
                try await Task.sleep(nanoseconds: 800_000_000)
                
                // Lưu mock session vào AuthManager
                AuthManager.shared.saveSession(
                    access: "mock_jwt_token_for_vts_staff_bypass",
                    refresh: "mock_refresh_token_id_123456",
                    hoTen: "Nguyễn Văn A",
                    maNV: "NV009",
                    avatar: nil,
                    chucNangPhanQuyens: getDefaultPermissions(),
                    soLEHeThong: TSoLeHeThong(solesoluong: 1, soledongia: 0, solesotien: 0, soletyle: 0)
                )
                
                KeychainHelper.shared.save(username, forKey: "vts_saved_username")
                KeychainHelper.shared.save(password, forKey: "vts_saved_password")
                UserDefaults.standard.set(savePasswordLocal, forKey: "vts_remember_account")
                UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
                UserDefaults.standard.set(false, forKey: "vts_logged_in_with_apple")
                
                ErrorManager.shared.showSuccess("Đăng nhập giả lập thành công!")
                isLoading = false
            } else {
                // Real API Authentication
                let userTrimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
                _ = try await authService.dangNhap(user: userTrimmed, pass: password)
                
                KeychainHelper.shared.save(userTrimmed, forKey: "vts_saved_username")
                KeychainHelper.shared.save(password, forKey: "vts_saved_password")
                UserDefaults.standard.set(savePasswordLocal, forKey: "vts_remember_account")
                UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
                UserDefaults.standard.set(false, forKey: "vts_logged_in_with_apple")
                
                ErrorManager.shared.showSuccess("Đăng nhập thành công!")
                isLoading = false
            }
        } catch {
            ErrorManager.shared.handleAlert(error, title: "Đăng nhập thất bại")
            isLoading = false
        }
    }
    
    // MARK: - Sign in with Apple Handlers (Chuẩn theo SKILL.md)
    
    public func showPrivacyWarning() {
        ErrorManager.shared.showWarning("Vui lòng xác nhận đồng ý Điều khoản dịch vụ để tiếp tục.")
    }
    
    public func configureAppleSignIn(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    public func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
            handleAppleAuthorization(authorization)
        case .failure(let error):
            if let asError = error as? ASAuthorizationError, asError.code == .canceled {
                print("ℹ️ [APPLE AUTH]: Người dùng đã huỷ.")
                return
            }
            showError("Đăng nhập Apple thất bại: \(error.localizedDescription)")
        }
    }
    
    public func handleAppleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            showError("Không nhận diện được chứng chỉ Apple ID.")
            return
        }
        
        guard let tokenData = appleIDCredential.identityToken,
              let identityTokenString = String(data: tokenData, encoding: .utf8) else {
            showError("Không thể trích xuất Identity Token từ Apple ID.")
            return
        }
        
        var authCodeString: String? = nil
        if let authCodeData = appleIDCredential.authorizationCode {
            authCodeString = String(data: authCodeData, encoding: .utf8)
        }
        
        var fullNameString: String? = nil
        if let nameComponents = appleIDCredential.fullName {
            let formatter = PersonNameComponentsFormatter()
            let formatted = formatter.string(from: nameComponents).trimmingCharacters(in: .whitespacesAndNewlines)
            if !formatted.isEmpty { fullNameString = formatted }
        }
        
        let appleResult = AppleAuthResult(
            appleUserId: appleIDCredential.user,
            identityToken: identityTokenString,
            authorizationCode: authCodeString,
            email: appleIDCredential.email,
            fullName: fullNameString
        )
        
        // Lưu định danh
        KeychainHelper.shared.save(appleResult.appleUserId, forKey: "vts_apple_user_id")
        UserDefaults.standard.set(appleResult.appleUserId, forKey: "vts_apple_user_id")
        UserDefaults.standard.set(true, forKey: "vts_logged_in_with_apple")
        UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
        
        self.appleAuthResult = appleResult
        
        guard let authCode = appleResult.authorizationCode, !authCode.isEmpty else {
            showError("Không lấy được authorization code từ Apple ID.")
            return
        }
        
        Task {
            await loginWithApple(authCode: authCode, result: appleResult)
        }
    }
    
    func loginWithApple(authCode: String, result: AppleAuthResult) async {
        guard isAgreedToPrivacyPolicy else {
            showPrivacyWarning()
            return
        }
        
        isLoading = true
        
        // Phục hồi họ tên / email từ cache nếu Apple không trả về ở lần này
        var displayName = result.fullName ?? ""
        if !displayName.isEmpty {
            UserDefaults.standard.set(displayName, forKey: "vts_apple_name_\(result.appleUserId)")
        } else if let cachedName = UserDefaults.standard.string(forKey: "vts_apple_name_\(result.appleUserId)"), !cachedName.isEmpty {
            displayName = cachedName
        }
        
        var userEmail = result.email
        if let email = userEmail, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: "vts_apple_email_\(result.appleUserId)")
        } else if let cachedEmail = UserDefaults.standard.string(forKey: "vts_apple_email_\(result.appleUserId)"), !cachedEmail.isEmpty {
            userEmail = cachedEmail
        }
        
        if displayName.isEmpty {
            displayName = userEmail ?? "Apple User"
        }
        
        do {
            if isDemoMode {
                try await Task.sleep(nanoseconds: 800_000_000)
                AuthManager.shared.saveSession(
                    access: result.identityToken,
                    refresh: "apple_refresh_token_\(result.appleUserId)",
                    hoTen: displayName,
                    maNV: "APPLE_\(String(result.appleUserId.prefix(6)).uppercased())",
                    avatar: nil,
                    chucNangPhanQuyens: getDefaultPermissions(),
                    soLEHeThong: TSoLeHeThong(solesoluong: 1, soledongia: 0, solesotien: 0, soletyle: 0)
                )
                UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
                UserDefaults.standard.set(true, forKey: "vts_logged_in_with_apple")
                ErrorManager.shared.showSuccess("Đăng nhập bằng Apple thành công!")
                isLoading = false
            } else {
                _ = try await authService.dangNhapApple(
                    authCode: authCode,
                    user: result.appleUserId,
                    fullName: displayName
                )
                UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
                UserDefaults.standard.set(true, forKey: "vts_logged_in_with_apple")
                ErrorManager.shared.showSuccess("Đăng nhập bằng Apple thành công!")
                isLoading = false
            }
        } catch {
            ErrorManager.shared.handleAlert(error, title: "Đăng nhập Apple thất bại")
            isLoading = false
        }
    }
    
    // MARK: - Auto Login Apple ID (Section 4 SKILL.md)
    
    func checkAndAutoLoginAppleIfNeeded() {
        guard isAgreedToPrivacyPolicy else { return }
        let manualLogout = UserDefaults.standard.bool(forKey: "vts_apple_manual_logout")
        guard !manualLogout else { return }
        let loggedInWithApple = UserDefaults.standard.bool(forKey: "vts_logged_in_with_apple")
        guard loggedInWithApple else { return }
        
        guard let appleUserId = KeychainHelper.shared.load(forKey: "vts_apple_user_id") ?? UserDefaults.standard.string(forKey: "vts_apple_user_id"),
              !appleUserId.isEmpty else {
            return
        }
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: appleUserId) { [weak self] state, error in
            Task { @MainActor in
                guard let self = self else { return }
                switch state {
                case .authorized:
                    self.performAppleSignInRequest()
                case .revoked, .notFound:
                    self.clearAppleSavedState()
                case .transferred:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func clearAppleSavedState() {
        KeychainHelper.shared.delete(forKey: "vts_apple_user_id")
        UserDefaults.standard.removeObject(forKey: "vts_apple_user_id")
        UserDefaults.standard.set(false, forKey: "vts_logged_in_with_apple")
    }
    
    func performAppleSignInRequest() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        configureAppleSignIn(request: request)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.appleAuthController = controller
        controller.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate & Presentation
    
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if Thread.isMainThread {
            return MainActor.assumeIsolated {
                guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
                    return ASPresentationAnchor()
                }
                return window
            }
        } else {
            return DispatchQueue.main.sync {
                guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
                    return ASPresentationAnchor()
                }
                return window
            }
        }
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            self.appleAuthController = nil
            UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
            self.handleAppleAuthorization(authorization)
        }
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            self.appleAuthController = nil
            self.handleAppleSignIn(result: .failure(error))
        }
    }
    
    private func showError(_ message: String) {
        ErrorManager.shared.showError(message)
    }
    
    private func getDefaultPermissions() -> [TChucNangPhanQuyen] {
        [
            TChucNangPhanQuyen(sapXep: "1", nhomChucNang: "01", tenNhomChucNang: "Hệ thống", maChucNang: "SYS_PROFILE", tenChucNang: "Thông tin cá nhân", ghiChu: "Thông tin hồ sơ nhân viên", allowVisible: true, allowView: true, allowAdd: false, allowDel: false, allowEdit: true, allowRun: true, allowExcel: false, allowToolbar: true, visible: true, view: true, add: false, del: false, edit: true, run: true, excel: false, toolbar: true),
            TChucNangPhanQuyen(sapXep: "2", nhomChucNang: "01", tenNhomChucNang: "Hệ thống", maChucNang: "SYS_SETTINGS", tenChucNang: "Cấu hình hệ thống", ghiChu: "Thiết lập cấu hình chung", allowVisible: true, allowView: true, allowAdd: false, allowDel: false, allowEdit: true, allowRun: true, allowExcel: false, allowToolbar: true, visible: true, view: true, add: false, del: false, edit: true, run: true, excel: false, toolbar: true),
            TChucNangPhanQuyen(sapXep: "1", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "WEIGH_TICKET", tenChucNang: "Danh sách phiếu cân", ghiChu: "Xem và quản lý phiếu cân hàng hóa", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true),
            TChucNangPhanQuyen(sapXep: "2", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "TRIP_SCHEDULING", tenChucNang: "Lịch trình xe chạy", ghiChu: "Lịch trình phân phối vận chuyển", allowVisible: true, allowView: true, allowAdd: true, allowDel: false, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: false, edit: true, run: true, excel: true, toolbar: true),
            TChucNangPhanQuyen(sapXep: "3", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "VTSSTAFF_DANHMUC_XE", tenChucNang: "Danh mục xe", ghiChu: "Quản lý danh sách phương tiện vận tải", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true),
            TChucNangPhanQuyen(sapXep: "4", nhomChucNang: "02", tenNhomChucNang: "Vận chuyển", maChucNang: "VTSSTAFF_DANHMUC_KHACHHANG", tenChucNang: "Danh mục đối tác", ghiChu: "Quản lý danh sách khách hàng & nhà cung cấp", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true),
            TChucNangPhanQuyen(sapXep: "1", nhomChucNang: "03", tenNhomChucNang: "Quản trị nhân sự", maChucNang: "HRM_LIST", tenChucNang: "Danh mục nhân viên", ghiChu: "Danh sách hồ sơ nhân sự", allowVisible: true, allowView: true, allowAdd: true, allowDel: true, allowEdit: true, allowRun: true, allowExcel: true, allowToolbar: true, visible: true, view: true, add: true, del: true, edit: true, run: true, excel: true, toolbar: true)
        ]
    }
}
