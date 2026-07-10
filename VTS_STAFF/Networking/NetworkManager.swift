
//
//  NetworkManager.swift
//  VTS_STAFF
//
//  Core HTTP client:
//    • Tự động gắn Bearer token từ AuthManager vào mọi request
//    • Tự động retry một lần khi nhận 401 (refresh token → gọi lại)
//    • Generic decode: trả về T: Decodable hoặc raw Data
//    • Hỗ trợ logging request/response ở debug mode
//

import Foundation

// MARK: - API Response Wrapper (nếu server wrap dữ liệu)
/// Server trả về JSON dạng { "Success": true, "Data": ..., "Message": "..." }
/// Điều chỉnh CodingKeys theo thực tế của server bạn.
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool?
    let data: T?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case data    = "Data"
        case message = "Message"
    }
}

// MARK: - NetworkManager
final class NetworkManager {
    
    // MARK: Singleton
    static let shared = NetworkManager()
    private init() {}
    
    // MARK: URLSession
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = AppConfig.requestTimeoutInterval
        config.timeoutIntervalForResource = AppConfig.resourceTimeoutInterval
        return URLSession(configuration: config)
    }()
    
    // MARK: JSONDecoder
    private lazy var decoder: JSONDecoder = {
        let d = JSONDecoder()
        let fmt = DateFormatter()
        fmt.dateFormat = AppConfig.apiDateFormat
        d.dateDecodingStrategy = .formatted(fmt)
        return d
    }()
    
    // MARK: - Hàm chính: POST với body Encodable, trả về T: Decodable
    /// - Parameters:
    ///   - path: path của API, ví dụ "/api/hanghoa/DanhSach"
    ///   - body: request body (Encodable), nil nếu không có body
    ///   - requiresAuth: true (mặc định) → gắn Bearer header
    ///   - retried: dùng nội bộ để tránh retry vô tận
    func post<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body? = nil as String?,
        requiresAuth: Bool = true,
        retried: Bool = false
    ) async throws -> Response {
        let data = try await performRequest(path: path, body: body, requiresAuth: requiresAuth)
        do {
            // 1. Nếu Response là một Mảng (ví dụ: [Xe])
            if let arrayType = Response.self as? DecodableArray.Type {
                return try arrayType.decodeList(from: data, decoder: decoder) as! Response
            }
            
            // 2. Thử decode theo APIObjectResponse<Response>
            if let objectResponse = try? decoder.decode(APIObjectResponse<Response>.self, from: data) {
                if objectResponse.DataError != 0 {
                    throw NetworkError.serverError(statusCode: objectResponse.DataError, message: objectResponse.DataErrorDescription ?? "Unknown error")
                }
                if let result = objectResponse.DataResult {
                    return result
                }
            }
            
            // 3. Fallback: decode trực tiếp (dành cho các response dạng phẳng như LoginResponse)
            let directResult = try decoder.decode(Response.self, from: data)
            
            // Nếu có giao thức APIBaseResponse, kiểm tra lỗi nghiệp vụ
            if let baseResponse = directResult as? APIBaseResponse {
                if baseResponse.DataError != 0 {
                    throw NetworkError.serverError(statusCode: baseResponse.DataError, message: baseResponse.DataErrorDescription ?? "Unknown error")
                }
            }
            
            return directResult
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    /// Overload: trả về raw Data (khi không cần decode)
    func postRaw<Body: Encodable>(
        path: String,
        body: Body? = nil as String?,
        requiresAuth: Bool = true
    ) async throws -> Data {
        return try await performRequest(path: path, body: body, requiresAuth: requiresAuth)
    }
    
    /// Overload không có body
    func post<Response: Decodable>(
        path: String,
        requiresAuth: Bool = true
    ) async throws -> Response {
        return try await post(path: path, body: EmptyBody?.none, requiresAuth: requiresAuth)
    }
    
    // MARK: - Internal: Tạo & thực thi request
    private func performRequest<Body: Encodable>(
        path: String,
        body: Body?,
        requiresAuth: Bool,
        retried: Bool = false
    ) async throws -> Data {
        guard let url = URL(string: AppConfig.baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(AppConfig.contentTypeJSON, forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.contentTypeJSON, forHTTPHeaderField: "Accept")
        
        // Gắn Bearer token
        if requiresAuth {
            guard let bearer = AuthManager.shared.bearerHeader else {
                throw NetworkError.unauthorized
            }
            request.setValue(bearer, forHTTPHeaderField: AppConfig.authHeaderKey)
        }
        
        // Encode body
        if let body = body {
            let encoder = JSONEncoder()
            let fmt = DateFormatter()
            fmt.dateFormat = AppConfig.apiDateFormat
            encoder.dateEncodingStrategy = .formatted(fmt)
            request.httpBody = try encoder.encode(body)
        }
        
#if DEBUG
        logRequest(request)
#endif
        
        // Thực thi
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet: throw NetworkError.noInternetConnection
            case .timedOut:               throw NetworkError.timeout
            default:                      throw NetworkError.unknown(urlError)
            }
        }
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "NetworkManager", code: -1))
        }
        
#if DEBUG
        logResponse(http, data: data)
#endif
        
        // Xử lý 401 → thử refresh một lần
        if http.statusCode == 401 && !retried {
            _ = try await AuthManager.shared.refreshAccessToken()
            return try await performRequest(path: path, body: body, requiresAuth: requiresAuth, retried: true)
        }
        
        // Kiểm tra lỗi nghiệp vụ từ phản hồi JSON của server (Ví dụ: DataError: -100)
        if let commonError = try? decoder.decode(APICommonError.self, from: data),
           let errCode = commonError.DataError, errCode != 0 {
            
            // Nếu Token hết hạn (DataError == -108) và chưa retry
            if (errCode == -108 && !retried) || (errCode == -107 && !retried) {
#if DEBUG
                print("🔄 Token expired (DataError: -108). Attempting to refresh access token...")
#endif
                do {
                    _ = try await AuthManager.shared.refreshAccessToken()
#if DEBUG
                    print("🔄 Token refreshed successfully. Retrying request for path: \(path)")
#endif
                    return try await performRequest(path: path, body: body, requiresAuth: requiresAuth, retried: true)
                } catch {
#if DEBUG
                    print("🔴 Token refresh failed: \(error.localizedDescription)")
#endif
                    throw NetworkError.unauthorized
                }
            }
            
            throw NetworkError.serverError(statusCode: errCode, message: commonError.DataErrorDescription ?? "Unknown API Error")
        }
        
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.from(statusCode: http.statusCode, body: data)
        }
        
        return data
    }
    
    // MARK: - Debug Logging
    private func logRequest(_ request: URLRequest) {
        print("\n🔵 [REQUEST] \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("   Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
            print("   Body: \(bodyStr)")
        }
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        let statusIcon = (200..<300).contains(response.statusCode) ? "🟢" : "🔴"
        print("\(statusIcon) [RESPONSE] \(response.statusCode) \(response.url?.absoluteString ?? "")")
        if let str = String(data: data, encoding: .utf8) {
            print("   Body: \(str)") // giới hạn 500 ký tự
        }
    }
}

// MARK: - Helper: Empty body sentinel
private struct EmptyBody: Encodable {}

// MARK: - Helper: Common error response format
private struct APICommonError: Decodable {
    let DataError: Int?
    let DataErrorDescription: String?
}

// MARK: - Helper: Decodable Array interface for generic unwrapping
protocol DecodableArray {
    static func decodeList(from data: Data, decoder: JSONDecoder) throws -> Self
}

extension Array: DecodableArray where Element: Decodable {
    static func decodeList(from data: Data, decoder: JSONDecoder) throws -> Self {
        let wrapper = try decoder.decode(APIListResponse<Element>.self, from: data)
        if wrapper.DataError != 0 {
            throw NetworkError.serverError(statusCode: wrapper.DataError, message: wrapper.DataErrorDescription ?? "Unknown error")
        }
        return (wrapper.DataResults ?? []) as! Self
    }
}
