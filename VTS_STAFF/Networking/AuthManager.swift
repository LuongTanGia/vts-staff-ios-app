
//
//  AuthManager.swift
//  VTS_STAFF
//
//  Quản lý vòng đời token:
//    • Lưu / đọc access token & refresh token từ Keychain
//    • Tự động gắn Bearer header vào mọi request
//    • Tự động refresh token khi nhận 401 (một lần duy nhất)
//    • Đăng xuất và xoá toàn bộ session
//

import Foundation
import Combine


// MARK: - Auth Error
enum AuthError: LocalizedError {
    case notLoggedIn
    case refreshFailed
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .notLoggedIn:        return "Người dùng chưa đăng nhập."
        case .refreshFailed:      return "Không thể làm mới phiên. Vui lòng đăng nhập lại."
        case .invalidCredentials: return "Tên đăng nhập hoặc mật khẩu không đúng."
        }
    }
}

// MARK: - AuthManager
@MainActor
final class AuthManager: ObservableObject {
    
    // MARK: Singleton
    static let shared = AuthManager()
    private init() { loadTokenFromKeychain() }
    
    // MARK: Published
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var accessToken: String? = nil
    @Published private(set) var hoTen: String? = nil
    @Published private(set) var maNV: String? = nil
    @Published private(set) var avatar: String? = nil
    @Published private(set) var chucNangPhanQuyens: [TChucNangPhanQuyen] = []
    
    var isBypassActive: Bool {
        #if DEBUG
        return accessToken == "mock_jwt_token_for_vts_staff_bypass"
        #else
        return false
        #endif
    }
    
    // MARK: Private state
    private var refreshToken: String? = nil
    private var isRefreshing: Bool = false
    
    // Continuation queue: các request chờ refresh xong
    private var waitingContinuations: [CheckedContinuation<String, Error>] = []
    
    // MARK: - Load from Keychain on startup
    private func loadTokenFromKeychain() {
        accessToken  = KeychainHelper.shared.load(forKey: AppConfig.keychainAccessToken)
        refreshToken = KeychainHelper.shared.load(forKey: AppConfig.keychainRefreshToken)
        isLoggedIn   = accessToken != nil
        hoTen        = UserDefaults.standard.string(forKey: "vts_user_hoten")
        maNV         = UserDefaults.standard.string(forKey: "vts_user_manv")
        avatar       = UserDefaults.standard.string(forKey: "vts_user_avatar")
        if let data = UserDefaults.standard.data(forKey: "vts_user_functions"),
           let decoded = try? JSONDecoder().decode([TChucNangPhanQuyen].self, from: data) {
            chucNangPhanQuyens = decoded
        }
    }
    
    // MARK: - Save after login (tokens only)
    func saveTokens(access: String, refresh: String?) {
        accessToken  = access
        refreshToken = refresh
        isLoggedIn   = true
        KeychainHelper.shared.save(access, forKey: AppConfig.keychainAccessToken)
        if let r = refresh {
            KeychainHelper.shared.save(r, forKey: AppConfig.keychainRefreshToken)
        }
    }
    
    // MARK: - Save session with profile (after explicit login)
    func saveSession(access: String, refresh: String?, hoTen: String?, maNV: String?, avatar: String?, chucNangPhanQuyens: [TChucNangPhanQuyen] = []) {
        self.accessToken  = access
        self.refreshToken = refresh
        self.hoTen        = hoTen
        self.maNV         = maNV
        self.avatar       = avatar
        self.chucNangPhanQuyens = chucNangPhanQuyens
        self.isLoggedIn   = true
        
        KeychainHelper.shared.save(access, forKey: AppConfig.keychainAccessToken)
        if let r = refresh {
            KeychainHelper.shared.save(r, forKey: AppConfig.keychainRefreshToken)
        }
        
        UserDefaults.standard.set(hoTen, forKey: "vts_user_hoten")
        UserDefaults.standard.set(maNV, forKey: "vts_user_manv")
        UserDefaults.standard.set(avatar, forKey: "vts_user_avatar")
        if let encoded = try? JSONEncoder().encode(chucNangPhanQuyens) {
            UserDefaults.standard.set(encoded, forKey: "vts_user_functions")
        }
    }
    
    // MARK: - Valid Bearer header value
    var bearerHeader: String? {
        guard let token = accessToken else { return nil }
        return "Bearer \(token)"
    }
    
    // MARK: - Logout
    func logout() {
        accessToken  = nil
        refreshToken = nil
        hoTen        = nil
        maNV         = nil
        avatar       = nil
        chucNangPhanQuyens = []
        isLoggedIn   = false
        KeychainHelper.shared.clearAll()
        
        // Clear saved account & disable biometric login
        KeychainHelper.shared.delete(forKey: "vts_saved_username")
        KeychainHelper.shared.delete(forKey: "vts_saved_password")
        UserDefaults.standard.removeObject(forKey: "vts_remember_account")
        UserDefaults.standard.set(false, forKey: "vts_enable_biometrics")
        
        UserDefaults.standard.removeObject(forKey: "vts_user_hoten")
        UserDefaults.standard.removeObject(forKey: "vts_user_manv")
        UserDefaults.standard.removeObject(forKey: "vts_user_avatar")
        UserDefaults.standard.removeObject(forKey: "vts_user_functions")
    }
    
    // MARK: - Refresh token (async, concurrent-safe)
    /// Trả về access token mới, hoặc throw AuthError.refreshFailed
    func refreshAccessToken() async throws -> String {
        // Nếu đang refresh, chờ kết quả từ refresh đang chạy
        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                waitingContinuations.append(continuation)
            }
        }
        
        guard let currentRefresh = refreshToken else {
            logout()
            throw AuthError.refreshFailed
        }
        
        isRefreshing = true
        defer {
            isRefreshing = false
        }
        
        do {
            // Gọi trực tiếp không qua NetworkManager để tránh vòng lặp
            let url = URL(string: AppConfig.baseURL + "/api/auth/RefreshToken")!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue(AppConfig.contentTypeJSON, forHTTPHeaderField: "Content-Type")
            
            let body = ["TokenID": currentRefresh]
           
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: req)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw AuthError.refreshFailed
            }
            
            let decoded = try JSONDecoder().decode(TDangNhap.self, from: data)
            guard let newToken = decoded.tkn else {
                throw AuthError.refreshFailed
            }
            
            self.chucNangPhanQuyens = decoded.chucNangPhanQuyens
            if let encoded = try? JSONEncoder().encode(decoded.chucNangPhanQuyens) {
                UserDefaults.standard.set(encoded, forKey: "vts_user_functions")
            }
            
            saveTokens(access: newToken, refresh: decoded.rtkn ?? currentRefresh)
            
            // Trả kết quả cho các request đang chờ
            waitingContinuations.forEach { $0.resume(returning: newToken) }
            waitingContinuations.removeAll()
            
            return newToken
            
        } catch {
            waitingContinuations.forEach { $0.resume(throwing: error) }
            waitingContinuations.removeAll()
            logout()
            throw error
        }
    }
    
    func getPermission(for code: String) -> TChucNangPhanQuyen? {
        chucNangPhanQuyens.first(where: { $0.maChucNang == code })
    }
}
