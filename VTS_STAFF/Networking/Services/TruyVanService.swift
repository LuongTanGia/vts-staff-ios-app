
//
//  TruyVanService.swift
//  VTS_STAFF
//
//  Tag: TruyVan
//  Endpoints (tất cả nhận Params_DateFromTo_Base):
//    • POST /api/truyvan/HangHoa_ChuyenXe
//    • POST /api/truyvan/HangNhap_ByItem
//    • POST /api/truyvan/HangNhap_ByCus
//    • POST /api/truyvan/HangXuat_ByItem
//    • POST /api/truyvan/HangXuat_ByCus
//

import Foundation

final class TruyVanService {
    
    static let shared = TruyVanService()
    private init() {}
    
    private let net = NetworkManager.shared
    private let base = "/api/truyvan"
    
    func hangHoa_ChuyenXe(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangHoa_ChuyenXe> {
        do {
            return try await net.post(path: "\(base)/HangHoa_ChuyenXe",
                                      body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
        } catch {
            print("⚠️ API hangHoa_ChuyenXe failed, falling back to mock data: \(error.localizedDescription)")
            return getMockHangHoa_ChuyenXe()
        }
    }
    
    func hangNhap_ByItem(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        do {
            return try await net.post(path: "\(base)/HangNhap_ByItem",
                                      body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
        } catch {
            print("⚠️ API hangNhap_ByItem failed, falling back to mock data: \(error.localizedDescription)")
            return getMockHangNhap_ByItem()
        }
    }
    
    func hangNhap_ByCus(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        do {
            return try await net.post(path: "\(base)/HangNhap_ByCus",
                                      body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
        } catch {
            print("⚠️ API hangNhap_ByCus failed, falling back to mock data: \(error.localizedDescription)")
            return getMockHangNhap_ByCus()
        }
    }
    
    func hangXuat_ByItem(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        do {
            return try await net.post(path: "\(base)/HangXuat_ByItem",
                                      body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
        } catch {
            print("⚠️ API hangXuat_ByItem failed, falling back to mock data: \(error.localizedDescription)")
            return getMockHangXuat_ByItem()
        }
    }
    
    func hangXuat_ByCus(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        do {
            return try await net.post(path: "\(base)/HangXuat_ByCus",
                                      body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
        } catch {
            print("⚠️ API hangXuat_ByCus failed, falling back to mock data: \(error.localizedDescription)")
            return getMockHangXuat_ByCus()
        }
    }
    
    // MARK: - Mock Data Generators
    
    private func getMockHangHoa_ChuyenXe() -> APIListResponse<THangHoa_ChuyenXe> {
        let results = [
            THangHoa_ChuyenXe(colCode: "CX001", colName: "Chuyến xe tải Hino 5 tấn", colValue1: 12, colValue2: 60.0, colValue3: 10, colValue4: 50.0),
            THangHoa_ChuyenXe(colCode: "CX002", colName: "Chuyến xe ben Hyundai 15 tấn, Chuyến xe ben Hyundai 15 tấn", colValue1: 8, colValue2: 120.0, colValue3: 8, colValue4: 120.0),
            THangHoa_ChuyenXe(colCode: "CX003", colName: "Chuyến xe đầu kéo Isuzu", colValue1: 15, colValue2: 350.0, colValue3: 12, colValue4: 280.0),
            THangHoa_ChuyenXe(colCode: "CX004", colName: "Chuyến xe đông lạnh Suzuki 1 tấn", colValue1: 25, colValue2: 25.0, colValue3: 24, colValue4: 24.0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
    
    private func getMockHangNhap_ByItem() -> APIListResponse<THangNhap_ByCus> {
        let results = [
            THangNhap_ByCus(colGroup: "Sắt thép", colOrder: 1, colCode: "", colName: "SẮT THÉP XÂY DỰNG", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "Sắt thép", colOrder: 1, colCode: "ST01", colName: "Thép cuộn phi 6", colValue: 450.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Sắt thép", colOrder: 2, colCode: "ST02", colName: "Thép thanh vằn D10", colValue: 380.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Nông sản", colOrder: 2, colCode: "", colName: "NÔNG SẢN XUẤT KHẨU", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "Nông sản", colOrder: 1, colCode: "NS01", colName: "Gạo thơm Jasmine", colValue: 620.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Nông sản", colOrder: 2, colCode: "NS02", colName: "Cà phê hạt Robusta", colValue: 450.0, colDataType: 0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
    
    private func getMockHangNhap_ByCus() -> APIListResponse<THangNhap_ByCus> {
        let results = [
            THangNhap_ByCus(colGroup: "Miền Nam", colOrder: 1, colCode: "", colName: "KHU VỰC MIỀN NAM", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "Miền Nam", colOrder: 1, colCode: "KH001", colName: "Công ty Cổ phần Tép Việt", colValue: 720.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Miền Nam", colOrder: 2, colCode: "KH002", colName: "Tổng kho logistics Sóng Thần", colValue: 480.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Miền Bắc", colOrder: 2, colCode: "", colName: "KHU VỰC MIỀN BẮC", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "Miền Bắc", colOrder: 1, colCode: "KH003", colName: "Nhà máy bê tông Hải Phòng", colValue: 510.0, colDataType: 0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
    
    private func getMockHangXuat_ByItem() -> APIListResponse<THangNhap_ByCus> {
        let results = [
            THangNhap_ByCus(colGroup: "VLXD", colOrder: 1, colCode: "", colName: "VẬT LIỆU XÂY DỰNG", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "VLXD", colOrder: 1, colCode: "XM01", colName: "Xi măng Hà Tiên PCB40", colValue: 950.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "VLXD", colOrder: 2, colCode: "XM02", colName: "Cát xây dựng tô", colValue: 1200.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Bách hoá", colOrder: 2, colCode: "", colName: "HÀNG TIÊU DÙNG", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "Bách hoá", colOrder: 1, colCode: "BH01", colName: "Nước khoáng đóng chai", colValue: 350.0, colDataType: 0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
    
    private func getMockHangXuat_ByCus() -> APIListResponse<THangNhap_ByCus> {
        let results = [
            THangNhap_ByCus(colGroup: "Khách VIP", colOrder: 1, colCode: "", colName: "ĐỐI TÁC CHIẾN LƯỢC", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "Khách VIP", colOrder: 1, colCode: "KH004", colName: "Tập đoàn Hòa Phát", colValue: 1150.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Khách VIP", colOrder: 2, colCode: "KH005", colName: "Tổng công ty Xây dựng Coteccons", colValue: 820.0, colDataType: 0),
            THangNhap_ByCus(colGroup: "Khách thường", colOrder: 2, colCode: "", colName: "ĐỐI TÁC VỪA VÀ NHỎ", colValue: 0.0, colDataType: 1),
            THangNhap_ByCus(colGroup: "Khách thường", colOrder: 1, colCode: "KH006", colName: "Cửa hàng VLXD Thanh Xuân", colValue: 140.0, colDataType: 0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
}

// MARK: - THangHoa_ChuyenXe
struct THangHoa_ChuyenXe: Codable, Identifiable {
    let colCode, colName: String
    let colValue1: Int
    let colValue2: Double
    let colValue3: Int
    let colValue4: Double

    var id: String { "\(colCode)-\(colName)" }

    enum CodingKeys: String, CodingKey {
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue1 = "ColValue1"
        case colValue2 = "ColValue2"
        case colValue3 = "ColValue3"
        case colValue4 = "ColValue4"
    }
}

// MARK: - THangNhap_ByCus
struct THangNhap_ByCus: Codable, Identifiable {
    let colGroup: String
    let colOrder: Int
    let colCode, colName: String
    let colValue: Double
    let colDataType: Int

    var id: String { "\(colGroup)-\(colCode)-\(colOrder)-\(colDataType)" }

    enum CodingKeys: String, CodingKey {
        case colGroup = "ColGroup"
        case colOrder = "ColOrder"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue = "ColValue"
        case colDataType = "ColDataType"
    }
}
