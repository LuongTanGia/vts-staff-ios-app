
//
//  NetworkError.swift
//  VTS_STAFF
//
//  Các lỗi mạng được chuẩn hoá toàn hệ thống.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized          // 401 – token hết hạn, đã thử refresh nhưng thất bại
    case forbidden             // 403
    case notFound              // 404
    case timeout               // request timeout
    case noInternetConnection
    case unknown(Error)
    
    // MARK: - User-facing message
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL không hợp lệ."
        case .noData:
            return "Server không trả về dữ liệu."
        case .decodingFailed(let e):
            return "Lỗi giải mã dữ liệu: \(e.localizedDescription)"
        case .serverError(let code, let msg):
            return "Lỗi server (\(code)): \(msg ?? "Không rõ nguyên nhân.")"
        case .unauthorized:
            return "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại."
        case .forbidden:
            return "Bạn không có quyền thực hiện thao tác này."
        case .notFound:
            return "Không tìm thấy tài nguyên yêu cầu."
        case .timeout:
            return "Yêu cầu quá thời gian chờ. Vui lòng thử lại."
        case .noInternetConnection:
            return "Không có kết nối Internet."
        case .unknown(let e):
            return "Lỗi không xác định: \(e.localizedDescription)"
        }
    }
    
    // MARK: - Map from HTTP status code
    static func from(statusCode: Int, body: Data?) -> NetworkError {
        let message = body.flatMap { String(data: $0, encoding: .utf8) }
        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        default:  return .serverError(statusCode: statusCode, message: message)
        }
    }
}
