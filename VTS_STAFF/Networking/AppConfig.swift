
//
//  AppConfig.swift
//  VTS_STAFF
//
//  Cấu hình toàn cục: base URL, timeout, keychain key, v.v.
//

import Foundation

enum AppConfig {
    // MARK: - Base URL
    /// Thay đổi URL này theo môi trường (Dev / Staging / Production)
    static let baseURL: String = "https://vtsstaff.viettassaigon.vn"
    
    // MARK: - Timeout
    static let requestTimeoutInterval: TimeInterval = 30
    static let resourceTimeoutInterval: TimeInterval = 60
    
    // MARK: - Keychain keys
    static let keychainAccessToken  = "vts_access_token"
    static let keychainRefreshToken = "vts_refresh_token"
    static let keychainTokenExpiry  = "vts_token_expiry"
    
    // MARK: - HTTP Headers
    static let contentTypeJSON = "application/json"
    static let authHeaderKey   = "Authorization"
    
    // MARK: - Date format (API trả về ISO8601)
    static let apiDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
}
