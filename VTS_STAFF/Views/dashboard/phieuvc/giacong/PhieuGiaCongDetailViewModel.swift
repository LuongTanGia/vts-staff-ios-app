//
//  PhieuGiaCongDetailViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import Foundation
import Combine

@MainActor
final class PhieuGiaCongDetailViewModel: ObservableObject {
    @Published var state: VTSViewState<TPhieuvc_Giacong_DanhSach?> = .idle
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
    
    func loadDetails(existing: TPhieuvc_Giacong_DanhSach? = nil) async {
        if case .loading = state { return }
        state = .loading
        
        do {
            // Load dropdown options in parallel safely
            async let xeRes = try? ListHelpersService.shared.danhSachXe()
            async let taiXeRes = try? ListHelpersService.shared.danhSachTaiXe()
            async let khachHangRes = try? ListHelpersService.shared.danhSachKhachHang_KH()
            async let hangHoaDuaRes = try? ListHelpersService.shared.danhSachHangHoa_DUA()
            async let hangHoaThanRes = try? ListHelpersService.shared.danhSachHangHoa_THAN()
            
            let (xe, taiXe, khachHang, hhDua, hhThan) = await (xeRes, taiXeRes, khachHangRes, hangHoaDuaRes, hangHoaThanRes)
            
            self.xeOptions = xe?.DataResults ?? []
            self.taiXeOptions = taiXe?.DataResults ?? []
            self.khachHangOptions = khachHang?.DataResults ?? []
            
            var combinedHH: [TDanhSachMaTenNhom] = []
            combinedHH.append(contentsOf: hhDua?.DataResults ?? [])
            combinedHH.append(contentsOf: hhThan?.DataResults ?? [])
            self.hangHoaOptions = combinedHH
            
            if let existing = existing {
                state = .success(existing)
            } else if let soPhieu = soPhieu, !soPhieu.isEmpty {
                let infoRes = try await PhieuGiaCongService.shared.thongTin(soPhieu: soPhieu)
                if let found = infoRes.DataResult {
                    state = .success(found)
                } else {
                    state = .empty
                }
            } else {
                state = .success(nil)
            }
        } catch {
            if error.isNoDataError {
                state = .empty
            } else {
                state = .failure(error.localizedDescription)
            }
        }
    }
}
