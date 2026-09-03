//
//  TruyVanXuatViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 08/07/2026.
//

import Foundation
import Combine

@MainActor
final class TruyVanXuatViewModel: ObservableObject {
    @Published var fromDate: Date
    @Published var toDate: Date
    @Published var queryType: QueryType = .byItem
    @Published var searchText: String = ""
    
    @Published var stateByItem: VTSViewState<[THangNhap_ByCus]> = .idle
    @Published var stateByCus: VTSViewState<[THangNhap_ByCus]> = .idle
    
    private var allRawDataByItem: [THangNhap_ByCus] = []
    private var allRawDataByCus: [THangNhap_ByCus] = []
    
    init(fromDate: Date = Date(), toDate: Date = Date()) {
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
    var filteredDataByItem: [THangNhap_ByCus] {
        return buildGroupedList(from: allRawDataByItem)
    }
    
    var filteredDataByCus: [THangNhap_ByCus] {
        return buildGroupedList(from: allRawDataByCus)
    }
    
    private func buildGroupedList(from rawList: [THangNhap_ByCus]) -> [THangNhap_ByCus] {
        // Tách lấy mapping tên nhóm từ các dòng datatype == 1 từ API
        var groupNameMap: [String: String] = [:]
        for item in rawList where item.colDataType == 1 {
            let key = item.colGroup ?? item.colCode ?? ""
            if !key.isEmpty, let name = item.colName, !name.isEmpty {
                groupNameMap[key] = name
            }
        }
        
        // Lấy danh sách các dòng chi tiết (datatype == 0)
        let detailItems = rawList.filter { $0.colDataType == 0 }
        
        // Lọc theo từ khoá tìm kiếm
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).normalized
        let filteredDetails: [THangNhap_ByCus]
        if query.isEmpty {
            filteredDetails = detailItems
        } else {
            filteredDetails = detailItems.filter { item in
                let key = item.colGroup ?? item.colCode ?? ""
                let groupName = groupNameMap[key] ?? ""
                return (item.colCode?.normalized.contains(query) ?? false) ||
                       (item.colName?.normalized.contains(query) ?? false) ||
                       (item.colGroup?.normalized.contains(query) ?? false) ||
                       groupName.normalized.contains(query)
            }
        }
        
        if filteredDetails.isEmpty {
            return []
        }
        
        // Gom nhóm theo colGroup bảo toàn thứ tự xuất hiện
        var orderedGroupKeys: [String] = []
        var groupDict: [String: [THangNhap_ByCus]] = [:]
        
        for item in filteredDetails {
            let key = item.colGroup ?? item.colCode ?? "DEFAULT"
            if groupDict[key] == nil {
                orderedGroupKeys.append(key)
                groupDict[key] = []
            }
            groupDict[key]?.append(item)
        }
        
        // Tạo danh sách kết quả: chi tiết các dòng (datatype = 0) + dòng tổng nhóm (datatype = 1)
        var result: [THangNhap_ByCus] = []
        for key in orderedGroupKeys {
            guard let itemsInGroup = groupDict[key], !itemsInGroup.isEmpty else { continue }
            
            // Thêm các dòng chi tiết datatype = 0
            result.append(contentsOf: itemsInGroup)
            
            // Tính tổng nhóm và tạo dòng tổng hợp datatype = 1
            let groupSum = itemsInGroup.reduce(0.0) { $0 + $1.colValue }
            let groupName = groupNameMap[key] ?? itemsInGroup.first?.colGroup ?? "Tổng"
            let subtotalRow = THangNhap_ByCus(
                colGroup: key,
                colOrder: (itemsInGroup.last?.colOrder ?? 0) + 1,
                colCode: key,
                colName: groupName,
                colValue: groupSum,
                colDataType: 1
            )
            result.append(subtotalRow)
        }
        
        return result
    }
    
    func loadData(for type: QueryType) async {
        let isItem = (type == .byItem)
        
        if isItem {
            if case .loading = stateByItem { return }
            stateByItem = .loading
        } else {
            if case .loading = stateByCus { return }
            stateByCus = .loading
        }
        
        do {
            let response: APIListResponse<THangNhap_ByCus>
            if isItem {
                response = try await TruyVanService.shared.hangXuat_ByItem(
                    dateFrom: fromDate.toDateOnlyString,
                    dateTo: toDate.toDateOnlyString
                )
                let rawList = response.DataResults ?? []
                allRawDataByItem = rawList
                let filtered = buildGroupedList(from: rawList)
                stateByItem = filtered.isEmpty ? .empty : .success(filtered)
            } else {
                response = try await TruyVanService.shared.hangXuat_ByCus(
                    dateFrom: fromDate.toDateOnlyString,
                    dateTo: toDate.toDateOnlyString
                )
                let rawList = response.DataResults ?? []
                allRawDataByCus = rawList
                let filtered = buildGroupedList(from: rawList)
                stateByCus = filtered.isEmpty ? .empty : .success(filtered)
            }
        } catch {
            if isItem {
                if error.isNoDataError {
                    allRawDataByItem = []
                    stateByItem = .empty
                } else {
                    stateByItem = .failure(error.localizedDescription)
                }
            } else {
                if error.isNoDataError {
                    allRawDataByCus = []
                    stateByCus = .empty
                } else {
                    stateByCus = .failure(error.localizedDescription)
                }
            }
        }
    }
    
    func loadAllData() async {
        let active = queryType
        let inactive = (active == .byItem) ? QueryType.byCus : QueryType.byItem
        
        await loadData(for: active)
        
        Task {
            await loadData(for: inactive)
        }
    }
    
    func loadDataIfNeeded() async {
        let active = queryType
        if active == .byItem {
            if case .success = stateByItem { return }
        } else {
            if case .success = stateByCus { return }
        }
        await loadData(for: active)
    }
}
