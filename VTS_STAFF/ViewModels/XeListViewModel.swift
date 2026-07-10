//
//  XeListViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import Foundation
import Combine

@MainActor
final class XeListViewModel: ObservableObject {
    @Published var state: VTSViewState<[TXe_DanhSach]> = .idle
    @Published var searchText: String = ""
    
    private var allXe: [TXe_DanhSach] = []
    
    var filteredXe: [TXe_DanhSach] {
        if searchText.isEmpty {
            return allXe
        }
        let query = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        return allXe.filter { xe in
            let maMatch = xe.ma.lowercased().contains(query)
            let tenMatch = xe.ten.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            let loaiMatch = xe.loai.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            let nhomMatch = (xe.nhom ?? "").lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            let taiXeMatch = xe.taiXe.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query)
            return maMatch || tenMatch || loaiMatch || nhomMatch || taiXeMatch
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
            let response = try await XeService.shared.danhSach()
            let list = response.DataResults ?? []
            allXe = list
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
