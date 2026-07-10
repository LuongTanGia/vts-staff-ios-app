
//
//  KeychainHelper.swift
//  VTS_STAFF
//
//  Lưu/đọc token an toàn qua Keychain (iOS/macOS).
//

import Foundation
import Security

final class KeychainHelper {
    
    static let shared = KeychainHelper()
    private init() {}
    
    // MARK: - Save
    @discardableResult
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData:   data
        ]
        
        // Xoá nếu đã tồn tại
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Load
    func load(forKey key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrAccount:      key,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    // MARK: - Delete
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
    
    // MARK: - Clear all app keys
    func clearAll() {
        delete(forKey: AppConfig.keychainAccessToken)
        delete(forKey: AppConfig.keychainRefreshToken)
        delete(forKey: AppConfig.keychainTokenExpiry)
    }
}
