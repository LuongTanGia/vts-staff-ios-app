
//
//  ListHelpersService.swift
//  VTS_STAFF
//
//  Tag: ListHelpers – Các danh mục phụ trợ (không có request body, chỉ POST)
//  Endpoints:
//    /api/listhelpers/DanhSachTaiXe
//    /api/listhelpers/DanhSachXe
//    /api/listhelpers/DanhSachLoaiXe
//    /api/listhelpers/DanhSachNhomXe
//    /api/listhelpers/DanhSachLoaiHang
//    /api/listhelpers/DanhSachNhomHang
//    /api/listhelpers/DanhSachHangHoa_DUA
//    /api/listhelpers/DanhSachHangHoa_THAN
//    /api/listhelpers/DanhSachPhongBan
//    /api/listhelpers/DanhSachToNhom
//    /api/listhelpers/DanhSachCongViec
//    /api/listhelpers/DanhSachPhuongXa
//    /api/listhelpers/DanhSachTinhThanh
//    /api/listhelpers/DanhSachQuocGia
//    /api/listhelpers/DanhSachLoaiKhachHang
//    /api/listhelpers/DanhSachNhomKhachHang
//    /api/listhelpers/DanhSachKhachHang_CC
//    /api/listhelpers/DanhSachKhachHang_KH
//

import Foundation

final class ListHelpersService {
    
    static let shared = ListHelpersService()
    private init() {}
    
    private let net = NetworkManager.shared
    private let base = "/api/listhelpers"
    
    // MARK: - Xe
    func danhSachTaiXe()   async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachTaiXe") }
    func danhSachXe()      async throws -> APIListResponse<TDanhSachXe> { try await fetch("DanhSachXe") }
    func danhSachLoaiXe()  async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachLoaiXe") }
    func danhSachNhomXe()  async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachNhomXe") }
    
    // MARK: - Hàng hoá
    func danhSachLoaiHang()     async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachLoaiHang") }
    func danhSachNhomHang()     async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachNhomHang") }
    func danhSachHangHoa_DUA()  async throws -> APIListResponse<TDanhSachMaTenNhom> { try await fetch("DanhSachHangHoa_DUA") }
    func danhSachHangHoa_THAN() async throws -> APIListResponse<TDanhSachMaTenNhom> { try await fetch("DanhSachHangHoa_THAN") }
    
    // MARK: - Nhân sự
    func danhSachPhongBan() async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachPhongBan") }
    func danhSachToNhom()   async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachToNhom") }
    func danhSachCongViec() async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachCongViec") }
    
    // MARK: - Địa chính
    func danhSachPhuongXa()  async throws -> APIListResponse<TDanhSachPhuongXa> { try await fetch("DanhSachPhuongXa") }
    func danhSachTinhThanh() async throws -> APIListResponse<TDanhSachTinhThanh> { try await fetch("DanhSachTinhThanh") }
    func danhSachQuocGia()   async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachQuocGia") }
    
    // MARK: - Khách hàng
    func danhSachLoaiKhachHang()  async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachLoaiKhachHang") }
    func danhSachNhomKhachHang()  async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachNhomKhachHang") }
    func danhSachKhachHang_CC()   async throws -> APIListResponse<TDanhSachMaTenNhom> { try await fetch("DanhSachKhachHang_CC") }
    func danhSachKhachHang_KH()   async throws -> APIListResponse<TDanhSachMaTenNhom> { try await fetch("DanhSachKhachHang_KH") }
    
    // MARK: - Private helper
    private func fetch<T: Decodable>(_ endpoint: String) async throws -> APIListResponse<T> {
        return try await net.post(path: "\(base)/\(endpoint)")
    }
}

// MARK: - TDanhSachMaTen
struct TDanhSachMaTen: Decodable, Sendable {
    let ma, ten: String

    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        
    }
}
// MARK: - TDanhSachMaTenNhom
struct TDanhSachMaTenNhom: Decodable, Sendable {
    let ma, ten: String
    let nhom: String?
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case nhom = "Nhom"
    }
}


// MARK: - TDanhSachXe
struct TDanhSachXe: Decodable, Sendable  {
    let ma, ten, maTaiXe, tenTaiXe: String

    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case maTaiXe = "MaTaiXe"
        case tenTaiXe = "TenTaiXe"
    }
}
// MARK: - TDanhSachPhuongXa
struct TDanhSachPhuongXa: Decodable, Sendable {
    let ma, ten, tinhThanh, tenTinhThanh: String
    let quocGia, tenQuocGia: String

    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case tinhThanh = "TinhThanh"
        case tenTinhThanh = "TenTinhThanh"
        case quocGia = "QuocGia"
        case tenQuocGia = "TenQuocGia"
    }
}
// MARK: - TDanhSachTinhThanh
struct TDanhSachTinhThanh: Decodable, Sendable {
    let ma, ten, maThamChieu, tenThamChieu: String

    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case maThamChieu = "MaThamChieu"
        case tenThamChieu = "TenThamChieu"
    }
}
