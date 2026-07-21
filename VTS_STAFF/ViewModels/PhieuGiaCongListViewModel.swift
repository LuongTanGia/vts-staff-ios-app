//
//  PhieuGiaCongListViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 02/07/2026.
//

import Foundation
import Combine

@MainActor
final class PhieuGiaCongListViewModel: ObservableObject {
    @Published var state: VTSViewState<[TPhieuvc_Giacong_DanhSach]> = .idle
    @Published var searchText: String = ""
    @Published var fromDate: Date = Date().addingTimeInterval(-7*24*60*60)
    @Published var toDate: Date = Date()
    
    private var allPhieu: [TPhieuvc_Giacong_DanhSach] = []
    
    var filteredPhieu: [TPhieuvc_Giacong_DanhSach] {
        if searchText.isEmpty {
            return allPhieu
        }
        let query = searchText.normalized
        return allPhieu.filter { item in
            let soPhieuMatch = item.soPhieu.normalized.contains(query)
            let soXeMatch = item.soXe?.normalized.contains(query) ?? false
            let taiXeMatch = item.taiXe?.normalized.contains(query) ?? false
            let khachHangMatch = item.tenKhachHang?.normalized.contains(query) ?? false
            let hangHoaMatch = item.tenHangHoa.normalized.contains(query)
            let ghiChuMatch = (item.ghiChu ?? "").normalized.contains(query)
            let trangThaiMatch = item.tenTrangThai?.normalized.contains(query) ?? false
            
            return soPhieuMatch || soXeMatch || taiXeMatch || khachHangMatch || hangHoaMatch || ghiChuMatch || trangThaiMatch
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
            let response = try await PhieuGiaCongService.shared.danhSach(
                dateFrom: fromDate.toDateOnlyString,
                dateTo: toDate.toDateOnlyString
            )
            let list = response.DataResults ?? []
            allPhieu = list
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
