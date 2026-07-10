
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
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TKhachhang_TDanhSach(ma: "KH001", ten: "Công ty TNHH Cát Tường", diaChi: "123 Đường Ba Tháng Hai, Quận 10, TP.HCM", mst: "0312345678", dienThoai: "02839301234", email: "info@cattuong.vn", loai: .kháchHàng, nhom: "VIP", ghiChu: "Khách hàng thân thiết"),
                TKhachhang_TDanhSach(ma: "KH002", ten: "Doanh nghiệp Tư nhân Hùng Phát", diaChi: "456 Lê Duẩn, Quận Hải Châu, Đà Nẵng", mst: "0401234567", dienThoai: "02363821456", email: "contact@hungphat.vn", loai: .nhàCungCấp, nhom: "Thường", ghiChu: nil),
                TKhachhang_TDanhSach(ma: "KH003", ten: "Công ty Cổ phần Hóa chất Đại Việt", diaChi: "789 Nguyễn Chí Thanh, Quận Đống Đa, Hà Nội", mst: "0101234567", dienThoai: "02437731234", email: "support@daivietchem.com.vn", loai: .nhàCungCấpKháchHàng, nhom: "Đối tác chiến lược", ghiChu: "Thanh toán đúng hạn")
            ])
        }
        return try await net.post(path: "/api/khachhang/DanhSach")
    }
    
    func thongTin(ma: String) async throws -> APIObjectResponse<TKhachhang_ThongTin> {
        if AuthManager.shared.isBypassActive {
            let mockData = [
                "KH001": TKhachhang_ThongTin(ma: "KH001", ten: "Công ty TNHH Cát Tường", diaChi: "123 Đường Ba Tháng Hai, Quận 10, TP.HCM", mst: "0312345678", dienThoai: "02839301234", email: "info@cattuong.vn", loai: "Khách hàng", tenLoai: "Khách hàng", nhom: "VIP", tenNhom: "Khách hàng VIP", ghiChu: "Khách hàng thân thiết từ năm 2020", ngayTAO: "2020-05-10T08:00:00Z", nguoiTAO: "Admin", ngaySuaCuoi: "2026-06-01T15:20:00Z", nguoiSuaCuoi: "NV009"),
                "KH002": TKhachhang_ThongTin(ma: "KH002", ten: "Doanh nghiệp Tư nhân Hùng Phát", diaChi: "456 Lê Duẩn, Quận Hải Châu, Đà Nẵng", mst: "0401234567", dienThoai: "02363821456", email: "contact@hungphat.vn", loai: "Nhà cung cấp", tenLoai: "Nhà cung cấp", nhom: "Thường", tenNhom: "Nhà cung cấp thường", ghiChu: nil, ngayTAO: "2021-08-15T10:30:00Z", nguoiTAO: "Admin", ngaySuaCuoi: nil, nguoiSuaCuoi: nil),
                "KH003": TKhachhang_ThongTin(ma: "KH003", ten: "Công ty Cổ phần Hóa chất Đại Việt", diaChi: "789 Nguyễn Chí Thanh, Quận Đống Đa, Hà Nội", mst: "0101234567", dienThoai: "02437731234", email: "support@daivietchem.com.vn", loai: "Nhà cung cấp + Khách hàng", tenLoai: "Đối tác hai chiều", nhom: "Đối tác chiến lược", tenNhom: "Đối tác chiến lược nhóm A", ghiChu: "Thanh toán đúng hạn, hạn mức nợ 500 triệu", ngayTAO: "2022-03-20T14:00:00Z", nguoiTAO: "Admin", ngaySuaCuoi: "2026-05-10T09:00:00Z", nguoiSuaCuoi: "Admin")
            ]
            let res = mockData[ma] ?? TKhachhang_ThongTin(ma: ma, ten: "Khách hàng Liên kết Mới", diaChi: "Chưa cập nhật địa chỉ", mst: "0000000000", dienThoai: nil, email: nil, loai: "Khách hàng", tenLoai: "Khách hàng", nhom: nil, tenNhom: nil, ghiChu: nil, ngayTAO: "2026-01-01T00:00:00Z", nguoiTAO: "System", ngaySuaCuoi: nil, nguoiSuaCuoi: nil)
            return APIObjectResponse(DataError: 0, DataErrorDescription: nil, DataResult: res)
        }
        return try await net.post(path: "/api/khachhang/ThongTin", body: Params_Ma(ma: ma))
    }
    
    func them(_ data: DataIn_List_KhachHang) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/khachhang/Them", body: data)
    }
    
    func sua(_ data: DataIn_List_KhachHang) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/khachhang/Sua", body: data)
    }
    
    func xoa(ma: String) async throws -> ApiResult<AnyCodable> {
        if AuthManager.shared.isBypassActive {
            try await Task.sleep(nanoseconds: 500_000_000)
            return ApiResult(DataError: 0, DataErrorDescription: nil, DataResult: AnyCodable("success"))
        }
        return try await net.post(path: "/api/khachhang/Xoa", body: Params_Ma(ma: ma))
    }
}
