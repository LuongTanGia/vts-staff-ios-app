//
//  KhachHangListViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import Foundation
import Combine

@MainActor
final class KhachHangListViewModel: ObservableObject {
    @Published var state: VTSViewState<[TKhachhang_TDanhSach]> = .idle
    @Published var searchText: String = ""
    
    private var allKhachHang: [TKhachhang_TDanhSach] = []
    
    var filteredKhachHang: [TKhachhang_TDanhSach] {
        if searchText.isEmpty {
            return allKhachHang
        }
        let query = searchText.normalized
        return allKhachHang.filter { kh in
            let maMatch = kh.ma.normalized.contains(query)
            let tenMatch = kh.ten.normalized.contains(query)
            let diaChiMatch = (kh.diaChi ?? "").normalized.contains(query)
            let mstMatch = (kh.mst ?? "").normalized.contains(query)
            let dienThoaiMatch = (kh.dienThoai ?? "").normalized.contains(query)
            let emailMatch = (kh.email ?? "").normalized.contains(query)
            let nhomMatch = (kh.nhom ?? "").normalized.contains(query)
            let loaiMatch = kh.loai.rawValue.normalized.contains(query)
            return maMatch || tenMatch || diaChiMatch || mstMatch || dienThoaiMatch || emailMatch || nhomMatch || loaiMatch
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
            let response = try await KhachHangService.shared.danhSach()
            let list = response.DataResults ?? []
            allKhachHang = list
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
