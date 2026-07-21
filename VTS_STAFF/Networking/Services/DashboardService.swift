//
//  DashboardService.swift
//  VTS_STAFF
//
//  Tag: Dasboard
//  Endpoints:
//    • POST /api/dasboard/NhanVienInOut
//    • POST /api/dasboard/NhanVienPhongBan
//    • POST /api/dasboard/HangHoa_ChuyenXe
//    • POST /api/dasboard/HangNhap
//    • POST /api/dasboard/HangXuat
//

import Foundation

final class DashboardService {
    
    static let shared = DashboardService()
    private init() {}
    
    private let net = NetworkManager.shared
    
    /// Thống kê nhân viên vào/ra hôm nay
    func nhanVienInOut() async throws -> APIListResponse<TNhanVienInOutDataResult> {
        return try await net.post(path: "/api/dasboard/NhanVienInOut")
    }
    
    /// Nhân viên theo phòng ban
    func nhanVienPhongBan() async throws ->APIListResponse<TNhanVienPhongBanDataResult>{
        return try await net.post(path: "/api/dasboard/NhanVienPhongBan")
    }
    
    /// Hàng hoá đang vận chuyển
    func hangHoa_ChuyenXe() async throws -> APIListResponse<THangHoa_ChuyenXeDataResult> {
        return try await net.post(path: "/api/dasboard/HangHoa_ChuyenXe")
    }
    
    /// Thống kê hàng nhập
    func hangNhap() async throws -> APIListResponse<THangNhapDataResult> {
        return try await net.post(path: "/api/dasboard/HangNhap")
    }
    
    /// Thống kê hàng xuất
    func hangXuat() async throws -> APIListResponse<THangXuatDataResult> {
        return try await net.post(path: "/api/dasboard/HangXuat")
    }
    
    /// Tải toàn bộ dữ liệu thống kê cho trang Home song song
    func getHomeData() async throws -> HomeDashboardData {
        async let inOutRes = nhanVienInOut()
        async let phongBanRes = nhanVienPhongBan()
        async let chuyenXeRes = hangHoa_ChuyenXe()
        async let hangNhapRes = hangNhap()
        async let hangXuatRes = hangXuat()
        
        let (inOut, phongBan, chuyenXe, hangNhap, hangXuat) = try await (inOutRes, phongBanRes, chuyenXeRes, hangNhapRes, hangXuatRes)
        
        return HomeDashboardData(
            nhanVienInOut: inOut.DataResults ?? [],
            nhanVienPhongBan: phongBan.DataResults ?? [],
            hangHoaChuyenXe: chuyenXe.DataResults ?? [],
            hangNhap: hangNhap.DataResults ?? [],
            hangXuat: hangXuat.DataResults ?? []
        )
    }
}

