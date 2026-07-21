
//
//  XeService.swift
//  VTS_STAFF
//
//  Tag: Xe
//  Endpoints:
//    • POST /api/xe/DanhSach
//    • POST /api/xe/ThongTin
//    • POST /api/xe/Them
//    • POST /api/xe/Sua
//    • POST /api/xe/Xoa
//

import Foundation

final class XeService {
    
    static let shared = XeService()
    private init() {}
    
    private let net = NetworkManager.shared
    
    func danhSach() async throws -> APIListResponse<TXe_DanhSach> {
        return try await net.post(path: "/api/xe/DanhSach")
    }
    
    func thongTin(ma: String) async throws -> APIObjectResponse<TXe_ThongTin> {
        return try await net.post(path: "/api/xe/ThongTin", body: Params_Ma(ma: ma))
    }
    
    func them(_ data: DataIn_List_Xe) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/xe/Them", body: data)
    }
    
    func sua(_ data: DataIn_List_Xe) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/xe/Sua", body: data)
    }
    
    func xoa(ma: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/xe/Xoa", body: Params_Ma(ma: ma))
    }
}
