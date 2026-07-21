
//
//  NhanVienService.swift
//  VTS_STAFF
//
//  Tag: NhanVien
//  Endpoints:
//    • POST /api/nhanvien/DanhSach
//    • POST /api/nhanvien/ThongTin
//    • POST /api/nhanvien/Sua
//

import Foundation

final class NhanVienService {
    
    static let shared = NhanVienService()
    private init() {}
    
    private let net = NetworkManager.shared
    
    func danhSach() async throws -> APIListResponse<TNhanVien_DanhSach> {
        return try await net.post(path: "/api/nhanvien/DanhSach")
    }
    
    func thongTin(ma: String) async throws -> APIObjectResponse<TNhanVien_ThongTin> {
        return try await net.post(path: "/api/nhanvien/ThongTin", body: Params_Ma(ma: ma))
    }
    
    func sua(_ data: DataIn_NhanVien) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/nhanvien/Sua", body: data)
    }
}
