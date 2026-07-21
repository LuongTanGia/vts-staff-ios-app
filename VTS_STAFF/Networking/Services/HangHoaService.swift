
//
//  HangHoaService.swift
//  VTS_STAFF
//
//  Tag: HangHoa
//  Endpoints:
//    • POST /api/hanghoa/DanhSach
//    • POST /api/hanghoa/ThongTin
//    • POST /api/hanghoa/Them
//    • POST /api/hanghoa/Sua
//    • POST /api/hanghoa/Xoa
//

import Foundation

final class HangHoaService {
    
    static let shared = HangHoaService()
    private init() {}
    
    private let net = NetworkManager.shared
    
    // MARK: - Danh sách hàng hoá
    func danhSach() async throws -> APIListResponse<THangHoa_DanhSach> {
        return try await net.post(path: "/api/hanghoa/DanhSach")
    }
    
    // MARK: - Thông tin chi tiết
    func thongTin(ma: String) async throws -> APIObjectResponse<THangHoa_ThongTin> {
        let body = Params_Ma(ma: ma)
        return try await net.post(path: "/api/hanghoa/ThongTin", body: body)
    }
    
    // MARK: - Thêm mới
    func them(_ data: DataIn_List_HangHoa) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/hanghoa/Them", body: data)
    }
    
    // MARK: - Sửa
    func sua(_ data: DataIn_List_HangHoa) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/hanghoa/Sua", body: data)
    }
    
    // MARK: - Xoá
    func xoa(ma: String) async throws -> ApiResult<AnyCodable> {
        let body = Params_Ma(ma: ma)
        return try await net.post(path: "/api/hanghoa/Xoa", body: body)
    }
}
