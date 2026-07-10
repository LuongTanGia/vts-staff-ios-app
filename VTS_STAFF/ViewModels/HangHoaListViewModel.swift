//
//  HangHoaListViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import Foundation
import Combine

@MainActor
final class HangHoaListViewModel: ObservableObject {
    @Published var state: VTSViewState<[THangHoa_DanhSach]> = .idle
    @Published var searchText: String = ""
    
    private var allHangHoa: [THangHoa_DanhSach] = []
    
    var filteredHangHoa: [THangHoa_DanhSach] {
        if searchText.isEmpty {
            return allHangHoa
        }
        let query = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        return allHangHoa.filter { hh in
            let maMatch = hh.ma.lowercased().contains(query)
            let tenMatch = hh.ten.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            let loaiMatch = hh.loai.rawValue.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            let nhomMatch = (hh.nhom ?? "").lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            let dvtMatch = hh.dvt.rawValue.lowercased().contains(query)
            return maMatch || tenMatch || loaiMatch || nhomMatch || dvtMatch
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
            let response = try await HangHoaService.shared.danhSach()
            let list = response.DataResults ?? []
            allHangHoa = list
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
