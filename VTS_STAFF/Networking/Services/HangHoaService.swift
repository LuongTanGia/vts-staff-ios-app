
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
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                THangHoa_DanhSach(ma: "HH001", ten: "Dừa Xiêm Bến Tre", loai: .dừa, nhom: "Nông sản", dvt: .kg, ghiChu: "Dừa tươi loại 1"),
                THangHoa_DanhSach(ma: "HH002", ten: "Than Củi Đước", loai: .than, nhom: "Chất đốt", dvt: .kg, ghiChu: "Than khô chất lượng cao"),
                THangHoa_DanhSach(ma: "HH003", ten: "Dừa Sáp Cầu Kè", loai: .dừa, nhom: "Đặc sản", dvt: .kg, ghiChu: "Đặc sản Trà Vinh")
            ])
        }
        return try await net.post(path: "/api/hanghoa/DanhSach")
    }
    
    // MARK: - Thông tin chi tiết
    func thongTin(ma: String) async throws -> APIObjectResponse<THangHoa_ThongTin> {
        if AuthManager.shared.isBypassActive {
            let mockData =   THangHoa_ThongTin(ma: "HH001", ten: "Dừa Xiêm Bến Tre", loai: "Dừa", tenLoai: "Dừa tươi", nhom: "Nông sản", tenNhom: "Nông sản xuất khẩu", dvt: "Quả", ghiChu: "Dừa tươi loại 1 thu hoạch trực tiếp tại vườn", ngayTAO: "2025-01-20T08:00:00Z", nguoiTAO: "Admin", ngaySuaCuoi: "2026-06-15T10:00:00Z", nguoiSuaCuoi: "NV009")
            
            let res = mockData
            return APIObjectResponse(DataError: 0, DataErrorDescription: nil, DataResult: res)
        }
        let body = Params_Ma(ma: ma)
        return try await net.post(path: "/api/hanghoa/ThongTin", body: body)
    }
    
    // MARK: - Thêm mới
    func them(_ data: DataIn_List_HangHoa) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/hanghoa/Them", body: data)
    }
    
    // MARK: - Sửa
    func sua(_ data: DataIn_List_HangHoa) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/hanghoa/Sua", body: data)
    }
    
    // MARK: - Xoá
    func xoa(ma: String) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        let body = Params_Ma(ma: ma)
        return try await net.post(path: "/api/hanghoa/Xoa", body: body)
    }
}
