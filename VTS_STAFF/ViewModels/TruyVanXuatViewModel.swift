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
    
    @Published var stateByItem: VTSViewState<[THangNhap_ByCus]> = .idle
    @Published var stateByCus: VTSViewState<[THangNhap_ByCus]> = .idle
    
    private var allDataByItem: [THangNhap_ByCus] = []
    private var allDataByCus: [THangNhap_ByCus] = []
    
    init(fromDate: Date = Date(), toDate: Date = Date()) {
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
    var filteredDataByItem: [THangNhap_ByCus] {
        allDataByItem
    }
    
    var filteredDataByCus: [THangNhap_ByCus] {
        allDataByCus
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
                let list = (response.DataResults ?? []).organizedByGroup()
                allDataByItem = list
                stateByItem = list.isEmpty ? .empty : .success(list)
            } else {
                response = try await TruyVanService.shared.hangXuat_ByCus(
                    dateFrom: fromDate.toDateOnlyString,
                    dateTo: toDate.toDateOnlyString
                )
                let list = (response.DataResults ?? []).organizedByGroup()
                allDataByCus = list
                stateByCus = list.isEmpty ? .empty : .success(list)
            }
        } catch {
            if isItem {
                stateByItem = .failure(error.localizedDescription)
            } else {
                stateByCus = .failure(error.localizedDescription)
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
