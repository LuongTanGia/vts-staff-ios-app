//
//  PhieuXuatDetailViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import Foundation
import Combine

@MainActor
final class PhieuXuatDetailViewModel: ObservableObject {
    @Published var state: VTSViewState<TPhieuvc_Xuat_DanhSach?> = .idle
    @Published var xeOptions: [TDanhSachXe] = []
    @Published var taiXeOptions: [TDanhSachMaTen] = []
    @Published var khachHangOptions: [TDanhSachMaTenNhom] = []
    @Published var hangHoaOptions: [TDanhSachMaTenNhom] = []
    
    let statusOptions = [
        TDanhSachMaTen(ma: "HT", ten: "Hoàn thành"),
        TDanhSachMaTen(ma: "MO", ten: "Mới"),
        TDanhSachMaTen(ma: "HU", ten: "Huỷ")
    ]
    
    let soPhieu: String?
    
    var isNew: Bool {
        soPhieu == nil || soPhieu?.isEmpty == true
    }
    
    init(soPhieu: String?) {
        self.soPhieu = soPhieu
    }
    
    func loadDetails(existing: TPhieuvc_Xuat_DanhSach? = nil) async {
        if case .loading = state { return }
        state = .loading
        
        do {
            // Load dropdown options in parallel
            async let xeRes = ListHelpersService.shared.danhSachXe()
            async let taiXeRes = ListHelpersService.shared.danhSachTaiXe()
            async let khachHangRes = ListHelpersService.shared.danhSachKhachHang_KH()
            async let hangHoaDuaRes = ListHelpersService.shared.danhSachHangHoa_DUA()
            async let hangHoaThanRes = ListHelpersService.shared.danhSachHangHoa_THAN()
            
            let (xe, taiXe, khachHang, hhDua, hhThan) = try await (xeRes, taiXeRes, khachHangRes, hangHoaDuaRes, hangHoaThanRes)
            
            self.xeOptions = xe.DataResults ?? []
            self.taiXeOptions = taiXe.DataResults ?? []
            self.khachHangOptions = khachHang.DataResults ?? []
            
            var combinedHH: [TDanhSachMaTenNhom] = []
            combinedHH.append(contentsOf: hhDua.DataResults ?? [])
            combinedHH.append(contentsOf: hhThan.DataResults ?? [])
            self.hangHoaOptions = combinedHH
            
            if let existing = existing {
                state = .success(existing)
            } else if let soPhieu = soPhieu, !soPhieu.isEmpty {
                let dateFrom = Date().addingTimeInterval(-30 * 24 * 3600).toAPIString
                let dateTo = Date().toAPIString
                let listResponse = try await PhieuXuatService.shared.danhSach(dateFrom: dateFrom, dateTo: dateTo)
                
                if let found = listResponse.DataResults?.first(where: { $0.soPhieu == soPhieu }) {
                    state = .success(found)
                } else {
                    state = .empty
                }
            } else {
                state = .success(nil)
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
