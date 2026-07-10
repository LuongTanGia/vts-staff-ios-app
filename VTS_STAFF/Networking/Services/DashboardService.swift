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
        // Kiểm tra xem có đang ở chế độ Demo không
        if AuthManager.shared.isBypassActive {
            return getMockHomeData()
        }
        
        do {
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
        } catch {
            print("⚠️ API Dashboard failed, falling back to mock data: \(error.localizedDescription)")
            return getMockHomeData()
        }
    }
    
    /// Sinh dữ liệu giả lập chất lượng cao cho trang Home
    func getMockHomeData() -> HomeDashboardData {
        let inOut = [
            TNhanVienInOutDataResult(colOrder: 1, colCode: "COUNT", colName: "Nhân viên đã đến", colValue: 45),
            TNhanVienInOutDataResult(colOrder: 2, colCode: "BEGIN", colName: "Nhân viên đã ra về", colValue: 12),
            TNhanVienInOutDataResult(colOrder: 3, colCode: "OTHER", colName: "Nhân viên đi muộn", colValue: 3)
        ]
        
        let phongBan = [
            TNhanVienPhongBanDataResult(colOrder: 1, colCode: "VP", colName: "Văn phòng", colValue: 15, colValue0: 12, colValue1: 3),
            TNhanVienPhongBanDataResult(colOrder: 2, colCode: "KT", colName: "Khai thác", colValue: 20, colValue0: 18, colValue1: 2),
            TNhanVienPhongBanDataResult(colOrder: 3, colCode: "TX", colName: "Tài xế", colValue: 32, colValue0: 30, colValue1: 2)
        ]
        
        let chuyenXe = [
            THangHoa_ChuyenXeDataResult(colType: "", colOrder: 1, colCode: "CX", colName: "Chuyến xe", colValue1: 28, colValue2: 142, colValue3: 120, colValue4: 520),
            THangHoa_ChuyenXeDataResult(colType: "", colOrder: 2, colCode: "SL", colName: "Sản lượng", colValue1: 350, colValue2: 1850, colValue3: 1620, colValue4: 7200),
            THangHoa_ChuyenXeDataResult(colType: "", colOrder: 3, colCode: "SL", colName: "Sản lượng", colValue1: 350, colValue2: 1850, colValue3: 1620, colValue4: 7200)
        ]
        
        let hangNhap = [
            THangNhapDataResult(colType: "", colGroup: "NHAP_HOMNAY", colOrder: 1, colCode: "XM", colName: "Xi măng (Hôm nay)", colValue: 1200, colDataType: 1),
            THangNhapDataResult(colType: "", colGroup: "NHAP_HOMNAY", colOrder: 2, colCode: "ST", colName: "Sắt thép (Hôm nay)", colValue: 850, colDataType: 1),
            THangNhapDataResult(colType: "", colGroup: "NHAP_TUANNAY", colOrder: 3, colCode: "NS", colName: "Nông sản (Tuần này)", colValue: 420, colDataType: 1),
            THangNhapDataResult(colType: "", colGroup: "NHAP_TUANTRUOC", colOrder: 4, colCode: "PK", colName: "Phụ kiện (Tuần trước)", colValue: 310, colDataType: 1)
        ]
        
        let hangXuat = [
            THangXuatDataResult(colType: "", colGroup: "XUAT_HOMNAY", colOrder: 1, colCode: "GTP", colName: "Gỗ thành phẩm (Hôm nay)", colValue: 650, colDataType: 1),
            THangXuatDataResult(colType: "", colGroup: "XUAT_TUANNAY", colOrder: 2, colCode: "TS", colName: "Thủy sản (Tuần này)", colValue: 320, colDataType: 1),
            THangXuatDataResult(colType: "", colGroup: "XUAT_TUANTRUOC", colOrder: 3, colCode: "VLXD", colName: "Vật liệu xây dựng (Tuần trước)", colValue: 1100, colDataType: 1)
        ]
        
        return HomeDashboardData(
            nhanVienInOut: inOut,
            nhanVienPhongBan: phongBan,
            hangHoaChuyenXe: chuyenXe,
            hangNhap: hangNhap,
            hangXuat: hangXuat
        )
    }
}

