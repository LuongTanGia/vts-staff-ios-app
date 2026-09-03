//
//  ThongBaoService.swift
//  VTS_STAFF
//
//  Created by Antigravity on 13/08/2026.
//

import Foundation

final class ThongBaoService {
    
    static let shared = ThongBaoService()
    private init() {}
    
    private let net = NetworkManager.shared
    
    // MARK: - API Thông Báo (/api/thongbao)
    
    /// Lấy danh sách thông báo theo khoảng ngày
    func danhSach(dateFrom: String, dateTo: String) async throws -> APIListResponse<TThongBao_DanhSach> {
        let body = Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo)
        return try await net.post(path: "/api/thongbao/DanhSach", body: body)
    }
    
    /// Cập nhật trạng thái đã đọc cho 1 thông báo
    func capNhatTrangThaiDaDoc(ma: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/thongbao/CapNhatTrangThaiDaDoc", body: Params_Ma(ma: ma))
    }
    
    /// Cập nhật trạng thái đã đọc cho danh sách thông báo hoặc tất cả
    func capNhatTrangThaiDaDocTatCa(maThongBaos: [String] = []) async throws -> ApiResult<AnyCodable> {
        let list = maThongBaos.map { Params_Ma(ma: $0) }
        let body = Params_ThongBao(maThongBaos: list.isEmpty ? nil : list)
        return try await net.post(path: "/api/thongbao/CapNhatTrangThaiDaDocTatCa", body: body)
    }
    
    // MARK: - API Cài Đặt Thông Báo (/api/settings)
    
    /// Lấy cấu hình thông báo khi tạo phiếu
    func getMsgTaoPhieu() async throws -> ApiResult<AnyCodable> {
        let emptyBody: [String: String]? = nil
        return try await net.post(path: "/api/settings/GET_MSG_TAOPHIEU", body: emptyBody)
    }
    
    /// Cập nhật cấu hình thông báo khi tạo phiếu
    func setMsgTaoPhieu(clientToken: String?, enabled: Bool) async throws -> ApiResult<AnyCodable> {
        let body = Params_MSG_TAOPHIEU(clientToken: clientToken, msgTaoPhieu: enabled)
        return try await net.post(path: "/api/settings/SET_MSG_TAOPHIEU", body: body)
    }
    
    /// Lấy cấu hình thông báo khi xoá phiếu
    func getMsgXoaPhieu() async throws -> ApiResult<AnyCodable> {
        let emptyBody: [String: String]? = nil
        return try await net.post(path: "/api/settings/GET_MSG_XOAPHIEU", body: emptyBody)
    }
    
    /// Cập nhật cấu hình thông báo khi xoá phiếu
    func setMsgXoaPhieu(clientToken: String?, enabled: Bool) async throws -> ApiResult<AnyCodable> {
        let body = Params_MSG_XOAPHIEU(clientToken: clientToken, msgXoaPhieu: enabled)
        return try await net.post(path: "/api/settings/SET_MSG_XOAPHIEU", body: body)
    }
}
