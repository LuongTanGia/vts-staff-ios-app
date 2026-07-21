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
        let query = searchText.normalized
        return allHangHoa.filter { hh in
            let maMatch = hh.ma.normalized.contains(query)
            let tenMatch = hh.ten.normalized.contains(query)
            let loaiMatch = hh.loai?.normalized.contains(query) ?? false
            let nhomMatch = (hh.nhom ?? "").normalized.contains(query)
            let dvtMatch = hh.dvt?.normalized.contains(query) ?? false
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
