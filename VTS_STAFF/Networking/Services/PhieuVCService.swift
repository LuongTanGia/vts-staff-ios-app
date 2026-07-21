
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
    
    func danhSach(dateFrom: String, dateTo: String) async throws -> APIListResponse<TPhieuvc_Giacong_DanhSach> {
        do {
            let body = Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo)
            return try await net.post(path: "\(base)/DanhSach", body: body)
        } catch {
            print("⚠️ API PhieuGiaCong.danhSach failed, falling back to mock data: \(error.localizedDescription)")
            return getMockGiaCongData()
        }
    }
    
    private func getMockGiaCongData() -> APIListResponse<TPhieuvc_Giacong_DanhSach> {
        let mockList = [
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2607090002", soPhieuInt: 2607090002, ngay: "2026-07-09T00:00:00", xeNgoai: false,
                soXe: "51L-02869", taiXe: "Trần Minh Khánh", khachHang: "KH005", tenKhachHang: "HỘ KINH DOANH TIỆM NƯỚNG THƯƠNG THƯƠNG",
                hangHoa: "HH006", tenHangHoa: "Cơm cục", trongLuongXe: 5000, trongLuongHang: 12, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2607090001", soPhieuInt: 2607090001, ngay: "2026-07-09T00:00:00", xeNgoai: false,
                soXe: "51M-78150", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH005", tenHangHoa: "Nước dừa", trongLuongXe: 5000, trongLuongHang: 15, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606260001", soPhieuInt: 2606260001, ngay: "2026-06-26T00:00:00", xeNgoai: false,
                soXe: "51L-02869", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH002", tenHangHoa: "Dừa ba da", trongLuongXe: 5000, trongLuongHang: 1500, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220001", soPhieuInt: 2606220001, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 2500, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220002", soPhieuInt: 2606220002, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 10000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220003", soPhieuInt: 2606220003, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 15000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220004", soPhieuInt: 2606220004, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 12000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220005", soPhieuInt: 2606220005, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 8000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220006", soPhieuInt: 2606220006, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 7000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220007", soPhieuInt: 2606220007, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 9000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220008", soPhieuInt: 2606220008, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 6000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220009", soPhieuInt: 2606220009, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 5000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220010", soPhieuInt: 2606220010, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 8000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220011", soPhieuInt: 2606220011, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 6000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220012", soPhieuInt: 2606220012, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 5000, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Giacong_DanhSach(
                soPhieu: "2606220013", soPhieuInt: 2606220013, ngay: "2026-06-22T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH006", tenKhachHang: "HỘ KINH DOANH NGUYỄN THỊ MINH THẢO",
                hangHoa: "HH007", tenHangHoa: "Cơm dừa", trongLuongXe: 5000, trongLuongHang: 3340, hangHoaGC: nil, tenHangHoaGC: nil, trongLuongHangGC: 0,
                hangHoaTV: nil, tenHangHoaTV: nil, trongLuongHangTV: 0, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            )
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: mockList)
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
        do {
            return try await net.post(path: "\(base)/DanhSach",
                                      body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
        } catch {
            print("⚠️ API PhieuNhap.danhSach failed, falling back to mock data: \(error.localizedDescription)")
            return getMockNhapData()
        }
    }
    
    private func getMockNhapData() -> APIListResponse<TPhieuvc_Nhap_DanhSach> {
        let mockList = [
            TPhieuvc_Nhap_DanhSach(
                soPhieu: "2607170009", soPhieuInt: 2607170009, ngay: "2026-07-17T00:00:00", xeNgoai: false,
                soXe: "51M-78150", khachHang: "", tenKhachHang: "", taiXe: "Trần Minh Khánh",
                hangHoa: "HH005", tenHangHoa: "Nước dừa", trongLuongXe: 5000, trongLuongHang: 600, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Nhap_DanhSach(
                soPhieu: "2607170008", soPhieuInt: 2607170008, ngay: "2026-07-17T00:00:00", xeNgoai: true,
                soXe: "DSSSSS", khachHang: "", tenKhachHang: "", taiXe: "hhgggg",
                hangHoa: "HH006", tenHangHoa: "Cơm cục", trongLuongXe: 5000, trongLuongHang: 800, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Nhap_DanhSach(
                soPhieu: "2607170007", soPhieuInt: 2607170007, ngay: "2026-07-17T00:00:00", xeNgoai: false,
                soXe: "51L-02869", khachHang: "", tenKhachHang: "", taiXe: "Trần Minh Khánh",
                hangHoa: "HH005", tenHangHoa: "Nước dừa", trongLuongXe: 5000, trongLuongHang: 500, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Nhap_DanhSach(
                soPhieu: "2607170006", soPhieuInt: 2607170006, ngay: "2026-07-17T00:00:00", xeNgoai: false,
                soXe: "51L-02869", khachHang: "", tenKhachHang: "", taiXe: "Trần Minh Khánh",
                hangHoa: "HH005", tenHangHoa: "Nước dừa", trongLuongXe: 5000, trongLuongHang: 500, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Nhap_DanhSach(
                soPhieu: "2607170005", soPhieuInt: 2607170005, ngay: "2026-07-17T00:00:00", xeNgoai: false,
                soXe: "51L-02869", khachHang: "", tenKhachHang: "", taiXe: "Trần Minh Khánh",
                hangHoa: "HH005", tenHangHoa: "Nước dừa", trongLuongXe: 5000, trongLuongHang: 500, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Nhap_DanhSach(
                soPhieu: "2607170004", soPhieuInt: 2607170004, ngay: "2026-07-17T00:00:00", xeNgoai: false,
                soXe: "51L-02869", khachHang: "", tenKhachHang: "", taiXe: "Trần Minh Khánh",
                hangHoa: "HH005", tenHangHoa: "Nước dừa", trongLuongXe: 5000, trongLuongHang: 500, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Nhap_DanhSach(
                soPhieu: "2607170003", soPhieuInt: 2607170003, ngay: "2026-07-17T00:00:00", xeNgoai: false,
                soXe: "51L-02869", khachHang: "", tenKhachHang: "", taiXe: "Trần Minh Khánh",
                hangHoa: "HH005", tenHangHoa: "Nước dừa", trongLuongXe: 5000, trongLuongHang: 500, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            )
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: mockList)
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
        do {
            return try await net.post(path: "\(base)/DanhSach",
                                      body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
        } catch {
            print("⚠️ API PhieuXuat.danhSach failed, falling back to mock data: \(error.localizedDescription)")
            return getMockXuatData()
        }
    }
    
    private func getMockXuatData() -> APIListResponse<TPhieuvc_Xuat_DanhSach> {
        let mockList = [
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2605200001", soPhieuInt: 2605200001, ngay: "2026-04-28T00:00:00", xeNgoai: false,
                soXe: "51M-78150", taiXe: "Trần Minh Khánh", khachHang: "KH001", tenKhachHang: "CÔNG TY TNHH CHẾ BIẾN NÔNG SẢN THUẬN PHONG",
                hangHoa: "HH001", tenHangHoa: "Dừa trọc", trongLuongXe: 5000, trongLuongHang: 400, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2605160001", soPhieuInt: 2605160001, ngay: "2026-05-16T00:00:00", xeNgoai: false,
                soXe: "51M-78150", taiXe: "Đỗ Chí Trung", khachHang: "KH001", tenKhachHang: "CÔNG TY TNHH CHẾ BIẾN NÔNG SẢN THUẬN PHONG",
                hangHoa: "HH002", tenHangHoa: "Dừa ba da", trongLuongXe: 5000, trongLuongHang: 200, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606110001", soPhieuInt: 2606110001, ngay: "2026-06-11T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH002", tenKhachHang: "PT PRIMA SUMBER ANDALAN JAYA",
                hangHoa: "HH003", tenHangHoa: "Than BBQ", trongLuongXe: 5000, trongLuongHang: 9810, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120001", soPhieuInt: 2606120001, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 2312, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120002", soPhieuInt: 2606120002, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 8000, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120003", soPhieuInt: 2606120003, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 10000, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120004", soPhieuInt: 2606120004, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 6000, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120005", soPhieuInt: 2606120005, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 5000, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120006", soPhieuInt: 2606120006, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 4000, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120007", soPhieuInt: 2606120007, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 5000, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            ),
            TPhieuvc_Xuat_DanhSach(
                soPhieu: "2606120008", soPhieuInt: 2606120008, ngay: "2026-06-12T00:00:00", xeNgoai: false,
                soXe: "51M-80326", taiXe: "Trần Minh Khánh", khachHang: "KH003", tenKhachHang: "HỘ KINH DOANH LÊ THỊ ANH THƯ",
                hangHoa: "HH004", tenHangHoa: "Dừa xiêm", trongLuongXe: 5000, trongLuongHang: 2020, ghiChu: "", trangThai: "HT", tenTrangThai: "Hoàn thành"
            )
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: mockList)
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
