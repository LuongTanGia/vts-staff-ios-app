
//
//  KhachHangService.swift
//  VTS_STAFF
//
//  Tag: KhachHang
//  Endpoints:
//    • POST /api/khachhang/DanhSach
//    • POST /api/khachhang/ThongTin
//    • POST /api/khachhang/Them
//    • POST /api/khachhang/Sua
//    • POST /api/khachhang/Xoa
//

import Foundation

final class KhachHangService {
    
    static let shared = KhachHangService()
    private init() {}
    
    private let net = NetworkManager.shared
    
    func danhSach() async throws -> APIListResponse<TKhachhang_TDanhSach> {
        return try await net.post(path: "/api/khachhang/DanhSach")
    }
    
    func thongTin(ma: String) async throws -> APIObjectResponse<TKhachhang_ThongTin> {
        return try await net.post(path: "/api/khachhang/ThongTin", body: Params_Ma(ma: ma))
    }
    
    func them(_ data: DataIn_List_KhachHang) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/khachhang/Them", body: data)
    }
    
    func sua(_ data: DataIn_List_KhachHang) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/khachhang/Sua", body: data)
    }
    
    func xoa(ma: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/khachhang/Xoa", body: Params_Ma(ma: ma))
    }
}
