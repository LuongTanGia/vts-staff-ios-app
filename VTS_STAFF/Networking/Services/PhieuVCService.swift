
//
//  PhieuVCService.swift
//  VTS_STAFF
//
//  Phiếu Vận Chuyển (3 loại: GiaCong, Nhap, Xuat)
//  Mỗi loại có chung cấu trúc:
//    • DanhSach   → Params_DateFromTo_Base
//    • ThongTin   → Params_SoPhieu
//    • ThongTin_HinhAnh → Params_ThongTin_HinhAnh
//    • GuiAnh     → Params_GuiAnh
//    • Them
//    • Sua
//    • Xoa        → Params_SoPhieu
//

import Foundation

// MARK: - Phiếu Gia Công
final class PhieuGiaCongService {
    
    static let shared = PhieuGiaCongService()
    private init() {}
    
    private let net = NetworkManager.shared
    private let base = "/api/phieuvc_giacong"
    
    func danhSach(dateFrom: String, dateTo: String) async throws ->APIListResponse<TPhieuvc_Giacong_DanhSach> {
        let body = Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo)
        return try await net.post(path: "\(base)/DanhSach", body: body)
    }
    
    func thongTin(soPhieu: String) async throws -> APIListResponse<String> {
        return try await net.post(path: "\(base)/ThongTin", body: Params_SoPhieu(soPhieu: soPhieu))
    }
    
    func thongTinHinhAnh(soPhieu: String, danhSachHinh: [Params_MaHinh]) async throws -> APIListResponse<String> {
        let body = Params_ThongTin_HinhAnh(soPhieu: soPhieu, danhSachHinh: danhSachHinh)
        return try await net.post(path: "\(base)/ThongTin_HinhAnh", body: body)
    }
    
    func guiAnh(soPhieu: String, noiDungText: String?, base64Anh: String) async throws -> ApiResult<AnyCodable> {
        let body = Params_GuiAnh(soPhieu: soPhieu, noiDungText: noiDungText, noiDungAnh: base64Anh)
        return try await net.post(path: "\(base)/GuiAnh", body: body)
    }
    
    func them(_ data: Params_ThemPhieu_GiaCong) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Them", body: data)
    }
    
    func sua(_ data: Params_SuaPhieu_GiaCong) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Sua", body: data)
    }
    
    func xoa(soPhieu: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Xoa", body: Params_SoPhieu(soPhieu: soPhieu))
    }
}

// MARK: - Phiếu Nhập
final class PhieuNhapService {
    
    static let shared = PhieuNhapService()
    private init() {}
    
    private let net = NetworkManager.shared
    private let base = "/api/phieuvc_nhap"
    
    func danhSach(dateFrom: String, dateTo: String) async throws -> APIListResponse<TPhieuvc_Nhap_DanhSach> {
        return try await net.post(path: "\(base)/DanhSach",
                                  body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
    }
    
    func thongTin(soPhieu: String) async throws -> APIListResponse<String> {
        return try await net.post(path: "\(base)/ThongTin", body: Params_SoPhieu(soPhieu: soPhieu))
    }
    
    func thongTinHinhAnh(soPhieu: String, danhSachHinh: [Params_MaHinh]) async throws -> APIListResponse<String> {
        return try await net.post(path: "\(base)/ThongTin_HinhAnh",
                                  body: Params_ThongTin_HinhAnh(soPhieu: soPhieu, danhSachHinh: danhSachHinh))
    }
    
    func guiAnh(soPhieu: String, noiDungText: String?, base64Anh: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/GuiAnh",
                                  body: Params_GuiAnh(soPhieu: soPhieu, noiDungText: noiDungText, noiDungAnh: base64Anh))
    }
    
    func them(_ data: Params_ThemPhieu_Nhap) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Them", body: data)
    }
    
    func sua(_ data: Params_SuaPhieu_Nhap) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Sua", body: data)
    }
    
    func xoa(soPhieu: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Xoa", body: Params_SoPhieu(soPhieu: soPhieu))
    }
}

// MARK: - Phiếu Xuất
final class PhieuXuatService {
    
    static let shared = PhieuXuatService()
    private init() {}
    
    private let net = NetworkManager.shared
    private let base = "/api/phieuvc_xuat"
    
    func danhSach(dateFrom: String, dateTo: String) async throws -> APIListResponse<TPhieuvc_Xuat_DanhSach> {
        return try await net.post(path: "\(base)/DanhSach",
                                  body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
    }
    
    func thongTin(soPhieu: String) async throws -> APIListResponse<String> {
        return try await net.post(path: "\(base)/ThongTin", body: Params_SoPhieu(soPhieu: soPhieu))
    }
    
    func thongTinHinhAnh(soPhieu: String, danhSachHinh: [Params_MaHinh]) async throws -> APIListResponse<String> {
        return try await net.post(path: "\(base)/ThongTin_HinhAnh",
                                  body: Params_ThongTin_HinhAnh(soPhieu: soPhieu, danhSachHinh: danhSachHinh))
    }
    
    func guiAnh(soPhieu: String, noiDungText: String?, base64Anh: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/GuiAnh",
                                  body: Params_GuiAnh(soPhieu: soPhieu, noiDungText: noiDungText, noiDungAnh: base64Anh))
    }
    
    func them(_ data: Params_ThemPhieu_Xuat) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Them", body: data)
    }
    
    func sua(_ data: Params_SuaPhieu_Xuat) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Sua", body: data)
    }
    
    func xoa(soPhieu: String) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "\(base)/Xoa", body: Params_SoPhieu(soPhieu: soPhieu))
    }
}
