
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
        
        if let err = response.dataError, err != 0 {
            throw NetworkError.serverError(statusCode: err, message: response.dataErrorDescription ?? "Đăng nhập thất bại.")
        }
        
        // Lưu session & token
        if let token = response.tkn, !token.isEmpty {
            AuthManager.shared.saveSession(
                access:  token,
                refresh: response.rtkn,
                hoTen:   user,
                maNV:    "",
                avatar:  "",
                chucNangPhanQuyens: response.chucNangPhanQuyens ?? [],
                soLEHeThong: response.soLEHeThong
            )
            UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
            UserDefaults.standard.set(false, forKey: "vts_logged_in_with_apple")
        } else {
            if let desc = response.dataErrorDescription, !desc.isEmpty {
                throw NetworkError.serverError(statusCode: response.dataError ?? -1, message: desc)
            }
            throw AuthError.invalidCredentials
        }
        
        return response
    }
    
    // MARK: - Đăng nhập bằng Apple ID
    @discardableResult
    func dangNhapApple(authCode: String, user: String? = nil, fullName: String? = nil) async throws -> TDangNhap {
        var body = Params_UserPass_Base(tokenID: authCode, user: user, pass: nil)
        body.clientToken = UserDefaults.standard.string(forKey: "fcmToken")
        
        let response: TDangNhap = try await net.post(
            path: "/api/auth/DangNhap",
            body: body,
            requiresAuth: false
        )
        
        if let err = response.dataError, err != 0 {
            throw NetworkError.serverError(statusCode: err, message: response.dataErrorDescription ?? "Đăng nhập bằng Apple ID thất bại.")
        }
        
        if let token = response.tkn, !token.isEmpty {
            AuthManager.shared.saveSession(
                access:  token,
                refresh: response.rtkn,
                hoTen:   fullName ?? user ?? "Apple User",
                maNV:    "",
                avatar:  "",
                chucNangPhanQuyens: response.chucNangPhanQuyens ?? [],
                soLEHeThong: response.soLEHeThong
            )
            UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
            UserDefaults.standard.set(true, forKey: "vts_logged_in_with_apple")
        } else {
            if let desc = response.dataErrorDescription, !desc.isEmpty {
                throw NetworkError.serverError(statusCode: response.dataError ?? -1, message: desc)
            }
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
        UserDefaults.standard.set(true, forKey: "vts_apple_manual_logout")
        AuthManager.shared.logout()
    }
}
