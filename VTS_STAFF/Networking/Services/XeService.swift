
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
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TXe_DanhSach(ma: "XE001", ten: "Xe Đầu Kéo Freightliner Cascadia", loai: "Đầu kéo", nhom: "Đội xe A", maTaiXe: "NV003", taiXe: "Lê Thị Bình"),
                TXe_DanhSach(ma: "XE002", ten: "Xe Tải Hino 8 Tấn (51C-432.10)", loai: "Xe tải", nhom: "Đội xe B", maTaiXe: "NV001", taiXe: "Nguyễn Văn An"),
                TXe_DanhSach(ma: "XE003", ten: "Xe Đầu Kéo Hyundai HD1000", loai: "Đầu kéo", nhom: "Đội xe A", maTaiXe: "NV002", taiXe: "Trần Thế Minh"),
                TXe_DanhSach(ma: "XE004", ten: "Xe Bồn Isuzu 15m3 (29H-789.45)", loai: "Xe bồn", nhom: "Đội xe C", maTaiXe: "NV009", taiXe: "Nguyễn Văn A")
            ])
        }
        return try await net.post(path: "/api/xe/DanhSach")
    }
    
    func thongTin(ma: String) async throws -> APIObjectResponse<TXe_ThongTin> {
        if AuthManager.shared.isBypassActive {
            
            let res = TXe_ThongTin(ma: ma, ten: "Xe Liên Kết Khác", loai: "Khác", tenLoai: "Chưa phân loại", nhom: nil, tenNhom: nil, taiXe: "NV999", tenTaiXe: "Tài xế vãng lai", ghiChu: nil, ngayTAO: "2026-01-01T00:00:00Z", nguoiTAO: "System", ngaySuaCuoi: nil, nguoiSuaCuoi: nil)
            return APIObjectResponse(DataError: 0, DataErrorDescription: nil, DataResult: res)
        }
        return try await net.post(path: "/api/xe/ThongTin", body: Params_Ma(ma: ma))
    }
    
    func them(_ data: DataIn_List_Xe) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/xe/Them", body: data)
    }
    
    func sua(_ data: DataIn_List_Xe) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/xe/Sua", body: data)
    }
    
    func xoa(ma: String) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/xe/Xoa", body: Params_Ma(ma: ma))
    }
}
