
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
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TNhanVien_DanhSach(emid: "NV001", emHo: "Nguyễn", emTen: "Văn An", emHoTen: "Nguyễn Văn An", emTenGioiTinh: "Nam", emNgaySinh: "1990-05-12", emDienThoai: "0901234567", emEmail: "an.nv@vts.vn", emcccdppSo: "0123456789", emTenPhongBanHH: "Văn phòng", emNgayBatDauHH: "2020-01-01", emDiaChi: "TP. Hồ Chí Minh"),
                TNhanVien_DanhSach(emid: "NV002", emHo: "Trần", emTen: "Thế Minh", emHoTen: "Trần Thế Minh", emTenGioiTinh: "Nam", emNgaySinh: "1992-08-20", emDienThoai: "0912345678", emEmail: "minh.tt@vts.vn", emcccdppSo: "0234567890", emTenPhongBanHH: "Khai thác", emNgayBatDauHH: "2021-06-15", emDiaChi: "Hà Nội"),
                TNhanVien_DanhSach(emid: "NV003", emHo: "Lê", emTen: "Thị Bình", emHoTen: "Lê Thị Bình", emTenGioiTinh: "Nữ", emNgaySinh: "1995-11-02", emDienThoai: "0923456789", emEmail: "binh.lt@vts.vn", emcccdppSo: "0345678901", emTenPhongBanHH: "Tài xế", emNgayBatDauHH: "2022-03-10", emDiaChi: "Đà Nẵng")
            ])
        }
        return try await net.post(path: "/api/nhanvien/DanhSach")
    }
    
    func thongTin(ma: String) async throws -> APIObjectResponse<TNhanVien_ThongTin> {
        if AuthManager.shared.isBypassActive {
            return APIObjectResponse(DataError: 0, DataErrorDescription: nil, DataResult: TNhanVien_ThongTin(
                emid: ma,
                emHo: "Nguyễn",
                emTen: "Văn An",
                emGioiTinh: 1,
                emNgaySinh: "1990-05-12",
                emDienThoai: "0901234567",
                emEmail: "an.nv@vts.vn",
                emDiaChiSoDuong: "123 Đường số 1",
                emDiaChiPhuongXa: "Phường 1",
                emDiaChiTenPhuongXa: "Phường 1",
                emDiaChiTinhThanh: "TP. Hồ Chí Minh",
                emDiaChiTenTinhThanh: "TP. Hồ Chí Minh",
                emDiaChiQuocGia: "VN",
                emDiaChiTenQuocGia: "Việt Nam",
                emcccdppSo: "0123456789",
                emNgayBatDauHH: "2020-01-01",
                emTenPhongBanHH: "Văn phòng",
                ghiChu: "Nhân viên xuất sắc"
            ))
        }
        return try await net.post(path: "/api/nhanvien/ThongTin", body: Params_Ma(ma: ma))
    }
    
    func sua(_ data: DataIn_NhanVien) async throws -> ApiResult<AnyCodable> {
        return try await net.post(path: "/api/nhanvien/Sua", body: data)
    }
}
