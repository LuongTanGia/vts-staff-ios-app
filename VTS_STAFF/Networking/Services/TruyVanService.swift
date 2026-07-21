
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
        return try await net.post(path: "\(base)/HangHoa_ChuyenXe",
                                  body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
    }
    
    func hangNhap_ByItem(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        return try await net.post(path: "\(base)/HangNhap_ByItem",
                                  body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
    }
    
    func hangNhap_ByCus(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        return try await net.post(path: "\(base)/HangNhap_ByCus",
                                  body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
    }
    
    func hangXuat_ByItem(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        return try await net.post(path: "\(base)/HangXuat_ByItem",
                                  body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
    }
    
    func hangXuat_ByCus(dateFrom: String, dateTo: String) async throws -> APIListResponse<THangNhap_ByCus> {
        return try await net.post(path: "\(base)/HangXuat_ByCus",
                                  body: Params_DateFromTo_Base(dateFrom: dateFrom, dateTo: dateTo))
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
    let colGroup: String?
    let colOrder: Int
    let colCode, colName: String?
    let colValue: Double
    let colDataType: Int

    var id: String { "\(colGroup ?? "")-\(colCode ?? "")-\(colOrder)-\(colDataType)" }

    enum CodingKeys: String, CodingKey {
        case colGroup = "ColGroup"
        case colOrder = "ColOrder"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue = "ColValue"
        case colDataType = "ColDataType"
    }
}
