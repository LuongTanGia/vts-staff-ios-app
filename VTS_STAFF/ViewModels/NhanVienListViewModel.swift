//
//  NhanVienListViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 25/06/2026.
//

import Foundation
import Combine

@MainActor
final class NhanVienListViewModel: ObservableObject {
    @Published var state: VTSViewState<[TNhanVien_DanhSach]> = .idle
    @Published var searchText: String = ""
    
    private var allNhanVien: [TNhanVien_DanhSach] = []
    
    var filteredNhanVien: [TNhanVien_DanhSach] {
        if searchText.isEmpty {
            return allNhanVien
        }
        let query = searchText.normalized
        return allNhanVien.filter { nv in
            let nameMatch = nv.emHoTen.normalized.contains(query)
            let codeMatch = nv.emid.normalized.contains(query)
            let phoneMatch = nv.emDienThoai.normalized.contains(query)
            let deptMatch = nv.emTenPhongBanHH.normalized.contains(query)
            return nameMatch || codeMatch || phoneMatch || deptMatch
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
            let response = try await NhanVienService.shared.danhSach()
            
            
            let list = response.DataResults ?? []
            allNhanVien = list
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
