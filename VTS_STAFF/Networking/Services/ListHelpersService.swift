
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
    func danhSachTaiXe()   async throws -> APIListResponse<TDanhSachMaTen> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachMaTen(ma: "NV001", ten: "Nguyễn Văn An"),
                TDanhSachMaTen(ma: "NV002", ten: "Trần Thế Minh"),
                TDanhSachMaTen(ma: "NV003", ten: "Lê Thị Bình"),
                TDanhSachMaTen(ma: "NV009", ten: "Nguyễn Văn A")
            ])
        }
        return try await fetch("DanhSachTaiXe")
    }
    func danhSachXe()      async throws -> APIListResponse<TDanhSachXe> { try await fetch("DanhSachXe") }
    func danhSachLoaiXe()  async throws -> APIListResponse<TDanhSachMaTen> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachMaTen(ma: "Xe tải", ten: "Xe tải"),
                TDanhSachMaTen(ma: "Đầu kéo", ten: "Đầu kéo"),
                TDanhSachMaTen(ma: "Bán Tải", ten: "Bán Tải"),
                TDanhSachMaTen(ma: "Xe bồn", ten: "Xe bồn")
            ])
        }
        return try await fetch("DanhSachLoaiXe")
    }
    func danhSachNhomXe()  async throws -> APIListResponse<TDanhSachMaTen> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachMaTen(ma: "Đội xe A", ten: "Đội xe A"),
                TDanhSachMaTen(ma: "Đội xe B", ten: "Đội xe B"),
                TDanhSachMaTen(ma: "Đội xe C", ten: "Đội xe C")
            ])
        }
        return try await fetch("DanhSachNhomXe")
    }
    
    // MARK: - Hàng hoá
    func danhSachLoaiHang()     async throws -> APIListResponse<TDanhSachMaTen> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachMaTen(ma: "Dừa", ten: "Dừa"),
                TDanhSachMaTen(ma: "Than", ten: "Than"),
                TDanhSachMaTen(ma: "Khác", ten: "Khác")
            ])
        }
        return try await fetch("DanhSachLoaiHang")
    }
    func danhSachNhomHang()     async throws -> APIListResponse<TDanhSachMaTen> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachMaTen(ma: "Nhóm dừa trái", ten: "Nhóm dừa trái"),
                TDanhSachMaTen(ma: "Nhóm than thiêu", ten: "Nhóm than thiêu"),
                TDanhSachMaTen(ma: "Nhóm dịch vụ", ten: "Nhóm dịch vụ")
            ])
        }
        return try await fetch("DanhSachNhomHang")
    }
    func danhSachHangHoa_DUA()  async throws -> APIListResponse<TDanhSachMaTenNhom> { try await fetch("DanhSachHangHoa_DUA") }
    func danhSachHangHoa_THAN() async throws -> APIListResponse<TDanhSachMaTenNhom> { try await fetch("DanhSachHangHoa_THAN") }
    
    // MARK: - Nhân sự
    func danhSachPhongBan() async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachPhongBan") }
    func danhSachToNhom()   async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachToNhom") }
    func danhSachCongViec() async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachCongViec") }
    
    // MARK: - Địa chính
    func danhSachPhuongXa()  async throws -> APIListResponse<TDanhSachPhuongXa> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachPhuongXa(ma: "Phường Bến Tre", ten: "Phường Bến Tre", tinhThanh: "Tỉnh Bến Tre", tenTinhThanh: "Tỉnh Bến Tre", quocGia: "VN", tenQuocGia: "Việt Nam"),
                TDanhSachPhuongXa(ma: "Phường An Hội", ten: "Phường An Hội", tinhThanh: "Tỉnh Bến Tre", tenTinhThanh: "Tỉnh Bến Tre", quocGia: "VN", tenQuocGia: "Việt Nam"),
                TDanhSachPhuongXa(ma: "Phường Phú Khương", ten: "Phường Phú Khương", tinhThanh: "Tỉnh Bến Tre", tenTinhThanh: "Tỉnh Bến Tre", quocGia: "VN", tenQuocGia: "Việt Nam"),
                TDanhSachPhuongXa(ma: "Phường 1", ten: "Phường 1", tinhThanh: "TP. Hồ Chí Minh", tenTinhThanh: "TP. Hồ Chí Minh", quocGia: "VN", tenQuocGia: "Việt Nam"),
                TDanhSachPhuongXa(ma: "Xã Mỹ Thạnh An", ten: "Xã Mỹ Thạnh An", tinhThanh: "Tỉnh Bến Tre", tenTinhThanh: "Tỉnh Bến Tre", quocGia: "VN", tenQuocGia: "Việt Nam")
            ])
        }
        return try await fetch("DanhSachPhuongXa")
    }
    
    func danhSachTinhThanh() async throws -> APIListResponse<TDanhSachTinhThanh> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachTinhThanh(ma: "Tỉnh Bến Tre", ten: "Tỉnh Bến Tre", maThamChieu: "BT", tenThamChieu: "Bến Tre"),
                TDanhSachTinhThanh(ma: "Tỉnh Vĩnh Long", ten: "Tỉnh Vĩnh Long", maThamChieu: "VL", tenThamChieu: "Vĩnh Long"),
                TDanhSachTinhThanh(ma: "TP. Hồ Chí Minh", ten: "TP. Hồ Chí Minh", maThamChieu: "HCM", tenThamChieu: "Hồ Chí Minh"),
                TDanhSachTinhThanh(ma: "Tỉnh Trà Vinh", ten: "Tỉnh Trà Vinh", maThamChieu: "TV", tenThamChieu: "Trà Vinh")
            ])
        }
        return try await fetch("DanhSachTinhThanh")
    }
    
    func danhSachQuocGia()   async throws -> APIListResponse<TDanhSachMaTen> { try await fetch("DanhSachQuocGia") }
    
    // MARK: - Khách hàng
    func danhSachLoaiKhachHang()  async throws -> APIListResponse<TDanhSachMaTen> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachMaTen(ma: "Cá nhân", ten: "Cá nhân"),
                TDanhSachMaTen(ma: "Doanh nghiệp", ten: "Doanh nghiệp"),
                TDanhSachMaTen(ma: "Đại lý", ten: "Đại lý")
            ])
        }
        return try await fetch("DanhSachLoaiKhachHang")
    }
    func danhSachNhomKhachHang()  async throws -> APIListResponse<TDanhSachMaTen> {
        if AuthManager.shared.isBypassActive {
            return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: [
                TDanhSachMaTen(ma: "VIP", ten: "Khách hàng VIP"),
                TDanhSachMaTen(ma: "Bán buôn", ten: "Khách mua sỉ"),
                TDanhSachMaTen(ma: "Bán lẻ", ten: "Khách mua lẻ"),
                TDanhSachMaTen(ma: "Thân thiết", ten: "Khách hàng thân thiết")
            ])
        }
        return try await fetch("DanhSachNhomKhachHang")
    }
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
