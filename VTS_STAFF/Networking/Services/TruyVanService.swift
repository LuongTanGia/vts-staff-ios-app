
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
            THangNhap_ByCus(colGroupCode: "ST", colGroupName: "SẮT THÉP XÂY DỰNG", colCode: "", colName: "SẮT THÉP XÂY DỰNG", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "ST", colGroupName: "SẮT THÉP XÂY DỰNG", colCode: "ST01", colName: "Thép cuộn phi 6", colValue: 450, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "ST", colGroupName: "SẮT THÉP XÂY DỰNG", colCode: "ST02", colName: "Thép thanh vằn D10", colValue: 380, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "NS", colGroupName: "NÔNG SẢN XUẤT KHẨU", colCode: "", colName: "NÔNG SẢN XUẤT KHẨU", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "NS", colGroupName: "NÔNG SẢN XUẤT KHẨU", colCode: "NS01", colName: "Gạo thơm Jasmine", colValue: 620, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "NS", colGroupName: "NÔNG SẢN XUẤT KHẨU", colCode: "NS02", colName: "Cà phê hạt Robusta", colValue: 450, colDataType: 0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
    
    private func getMockHangNhap_ByCus() -> APIListResponse<THangNhap_ByCus> {
        let results = [
            THangNhap_ByCus(colGroupCode: "MN", colGroupName: "KHU VỰC MIỀN NAM", colCode: "", colName: "KHU VỰC MIỀN NAM", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "MN", colGroupName: "KHU VỰC MIỀN NAM", colCode: "KH001", colName: "Công ty Cổ phần Tép Việt", colValue: 720, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "MN", colGroupName: "KHU VỰC MIỀN NAM", colCode: "KH002", colName: "Tổng kho logistics Sóng Thần", colValue: 480, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "MB", colGroupName: "KHU VỰC MIỀN BẮC", colCode: "", colName: "KHU VỰC MIỀN BẮC", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "MB", colGroupName: "KHU VỰC MIỀN BẮC", colCode: "KH003", colName: "Nhà máy bê tông Hải Phòng", colValue: 510, colDataType: 0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
    
    private func getMockHangXuat_ByItem() -> APIListResponse<THangNhap_ByCus> {
        let results = [
            THangNhap_ByCus(colGroupCode: "VLXD", colGroupName: "VẬT LIỆU XÂY DỰNG", colCode: "", colName: "VẬT LIỆU XÂY DỰNG", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "VLXD", colGroupName: "VẬT LIỆU XÂY DỰNG", colCode: "XM01", colName: "Xi măng Hà Tiên PCB40", colValue: 950, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "VLXD", colGroupName: "VẬT LIỆU XÂY DỰNG", colCode: "XM02", colName: "Cát xây dựng tô", colValue: 1200, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "BH", colGroupName: "HÀNG TIÊU DÙNG", colCode: "", colName: "HÀNG TIÊU DÙNG", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "BH", colGroupName: "HÀNG TIÊU DÙNG", colCode: "BH01", colName: "Nước khoáng đóng chai", colValue: 350, colDataType: 0)
        ]
        return APIListResponse(DataError: 0, DataErrorDescription: nil, DataResults: results)
    }
    
    private func getMockHangXuat_ByCus() -> APIListResponse<THangNhap_ByCus> {
        let results = [
            THangNhap_ByCus(colGroupCode: "VIP", colGroupName: "ĐỐI TÁC CHIẾN LƯỢC", colCode: "", colName: "ĐỐI TÁC CHIẾN LƯỢC", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "VIP", colGroupName: "ĐỐI TÁC CHIẾN LƯỢC", colCode: "KH004", colName: "Tập đoàn Hòa Phát", colValue: 1150, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "VIP", colGroupName: "ĐỐI TÁC CHIẾN LƯỢC", colCode: "KH005", colName: "Tổng công ty Xây dựng Coteccons", colValue: 820, colDataType: 0),
            THangNhap_ByCus(colGroupCode: "NORMAL", colGroupName: "ĐỐI TÁC VỪA VÀ NHỎ", colCode: "", colName: "ĐỐI TÁC VỪA VÀ NHỎ", colValue: 0, colDataType: 1),
            THangNhap_ByCus(colGroupCode: "NORMAL", colGroupName: "ĐỐI TÁC VỪA VÀ NHỎ", colCode: "KH006", colName: "Cửa hàng VLXD Thanh Xuân", colValue: 140, colDataType: 0)
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
    
    let colGroupCode, colGroupName, colCode, colName: String?
    let colValue, colDataType: Int
    
    var id: String { "\(colGroupCode ?? "")-\(colGroupName ?? "")-\(colCode ?? "")-\(colName ?? "")-\(colDataType)-\(colValue)" }
    
    enum CodingKeys: String, CodingKey {
        case colGroupCode = "ColGroupCode"
        case colGroupName = "ColGroupName"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue = "ColValue"
        case colDataType = "ColDataType"
    }
}

// MARK: - THangNhap_ByCus Grouping Extension
extension Array where Element == THangNhap_ByCus {
    /// Nhóm các phần tử `THangNhap_ByCus` theo nhóm (ColGroupCode/ColGroupName):
    /// Đặt dòng tiêu đề nhóm (`colDataType == 1`) lên đầu nhóm,
    /// theo sau là các chi tiết (`colDataType == 0`) của nhóm đó.
    func organizedByGroup() -> [THangNhap_ByCus] {
        var groupOrderKeys: [String] = []
        var groupHeaders: [String: THangNhap_ByCus] = [:]
        var groupChildren: [String: [THangNhap_ByCus]] = [:]
        
        for item in self {
            let codeKey = item.colGroupCode?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let nameKey = item.colGroupName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let key = "\(codeKey)__\(nameKey)"
            
            if !groupOrderKeys.contains(key) {
                groupOrderKeys.append(key)
            }
            
            if item.colDataType == 1 {
                groupHeaders[key] = item
            } else {
                groupChildren[key, default: []].append(item)
            }
        }
        
        var result: [THangNhap_ByCus] = []
        for key in groupOrderKeys {
            let children = groupChildren[key] ?? []
            
            if let header = groupHeaders[key] {
                result.append(header)
            } else if !children.isEmpty {
                let first = children[0]
                let nameText = (first.colGroupName?.isEmpty == false) ? first.colGroupName : first.colGroupCode
                let groupTitle = (nameText?.isEmpty == false) ? nameText! : "Chưa phân nhóm"
                let sumValue = children.reduce(0) { $0 + $1.colValue }
                let syntheticHeader = THangNhap_ByCus(
                    colGroupCode: first.colGroupCode,
                    colGroupName: first.colGroupName,
                    colCode: first.colGroupCode,
                    colName: groupTitle,
                    colValue: sumValue,
                    colDataType: 1
                )
                result.append(syntheticHeader)
            }
            
            result.append(contentsOf: children)
        }
        
        return result
    }
}

