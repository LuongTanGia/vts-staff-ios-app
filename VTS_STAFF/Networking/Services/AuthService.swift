
//
//  AuthService.swift
//  VTS_STAFF
//
//  Tag: Auth
//  Endpoints:
//    • POST /api/auth/DangNhap
//    • POST /api/auth/RefreshToken
//

import Foundation

final class AuthService {
    
    static let shared = AuthService()
    private init() {}
    
    private let net = NetworkManager.shared
    
    // MARK: - Đăng nhập
    /// Gọi API đăng nhập, lưu token tự động vào Keychain qua AuthManager.
    /// - Parameters:
    ///   - user: Tên đăng nhập
    ///   - pass: Mật khẩu
    ///   - deviceToken: FCM / APNS push token (tuỳ chọn)
    @discardableResult
    func dangNhap(user: String, pass: String, deviceToken: String? = nil) async throws -> TDangNhap {
        var body = Params_UserPass_Base(tokenID: deviceToken, user: user, pass: pass)
        body.clientToken = UserDefaults.standard.string(forKey: "fcmToken")
        
        // Không cần auth header khi đăng nhập
        let response: TDangNhap = try await net.post(
            path: "/api/auth/DangNhap",
            body: body,
            requiresAuth: false
        )
        
        // Lưu session & token
        if let token = response.tkn {
            AuthManager.shared.saveSession(
                access:  token,
                refresh: response.rtkn,
                hoTen:   user,
                maNV:    "",
                avatar:  "",
                chucNangPhanQuyens: response.chucNangPhanQuyens
            )
        } else {
            throw AuthError.invalidCredentials
        }
        
        return response
    }
    
    // MARK: - Refresh Token (thủ công)
    /// Thường không cần gọi tay – NetworkManager tự động gọi khi nhận 401.
    @discardableResult
    func refreshToken() async throws -> String {
        return try await AuthManager.shared.refreshAccessToken()
    }
    
    // MARK: - Đăng xuất (local only)
    func dangXuat() async {
        AuthManager.shared.logout()
    }
}
