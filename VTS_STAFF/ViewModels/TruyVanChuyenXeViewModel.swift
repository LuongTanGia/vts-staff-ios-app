//
//  TruyVanChuyenXeViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 08/07/2026.
//

import Foundation
import Combine

@MainActor
final class TruyVanChuyenXeViewModel: ObservableObject {
    @Published var state: VTSViewState<[THangHoa_ChuyenXe]> = .idle
    @Published var searchText: String = ""
    @Published var fromDate: Date
    @Published var toDate: Date
    
    private var allData: [THangHoa_ChuyenXe] = []
    
    init(fromDate: Date = Date(), toDate: Date = Date()) {
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
    var filteredData: [THangHoa_ChuyenXe] {
        if searchText.isEmpty {
            return allData
        }
        let query = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        return allData.filter { item in
            let codeMatch = item.colCode.lowercased().contains(query)
            let nameMatch = item.colName.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            return codeMatch || nameMatch
        }
    }
    
    func loadData() async {
        if case .loading = state { return }
        
        if case .success = state {
            // Keep current data visible during background refresh
        } else {
            state = .loading
        }
        
        do {
            let response = try await TruyVanService.shared.hangHoa_ChuyenXe(
                dateFrom: fromDate.toDateOnlyString,
                dateTo: toDate.toDateOnlyString
            )
            let list = response.DataResults ?? []
            allData = list
            if list.isEmpty {
                state = .empty
            } else {
                state = .success(list)
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
    
    func loadDataIfNeeded() async {
        if case .success = state { return }
        await loadData()
    }
}
