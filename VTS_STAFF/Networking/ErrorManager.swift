//
//  ErrorManager.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ErrorManager: ObservableObject {
    
    static let shared = ErrorManager()
    private init() {}
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastType: VTSToastType = .error
    
    // Alert state (for messages requiring explicit confirmation)
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = "Thông báo"
    @Published var alertMessage: String = ""
    
    /// Bắt và hiển thị lỗi dưới dạng Alert buộc xác nhận
    func handleAlert(_ error: Error, title: String = "Lỗi") {
        let message: String
        
        if let netError = error as? NetworkError {
            message = netError.errorDescription ?? "Đã xảy ra lỗi kết nối mạng."
            if case .unauthorized = netError {
                AuthManager.shared.logout()
            }
        } else if let authError = error as? AuthError {
            message = authError.errorDescription ?? "Lỗi xác thực."
        } else if let localizedError = error as? LocalizedError {
            message = localizedError.errorDescription ?? error.localizedDescription
        } else {
            message = error.localizedDescription
        }
        
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
    
    /// Hiển thị thông báo Alert thủ công
    func showAlert(title: String = "Thông báo", message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
    
    /// Bắt và thông báo lỗi API/Mạng toàn hệ thống
    func handle(_ error: Error) {
        let message: String
        
        if let netError = error as? NetworkError {
            message = netError.errorDescription ?? "Đã xảy ra lỗi kết nối mạng."
            
            // Tự động đăng xuất nếu token bị từ chối (401 - Unauthorized)
            if case .unauthorized = netError {
                AuthManager.shared.logout()
            }
        } else if let authError = error as? AuthError {
            message = authError.errorDescription ?? "Lỗi xác thực."
        } else if let localizedError = error as? LocalizedError {
            message = localizedError.errorDescription ?? error.localizedDescription
        } else {
            message = error.localizedDescription
        }
        
        self.toastMessage = message
        self.toastType = .error
        self.showToast = true
    }
    
    /// Hiển thị thông báo thành công
    func showSuccess(_ message: String) {
        self.toastMessage = message
        self.toastType = .success
        self.showToast = true
    }
    
    /// Hiển thị thông báo cảnh báo
    func showWarning(_ message: String) {
        self.toastMessage = message
        self.toastType = .warning
        self.showToast = true
    }
}
