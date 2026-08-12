//
//  PhieuNhapDetailViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import Foundation
import Combine

@MainActor
final class PhieuNhapDetailViewModel: ObservableObject {
    @Published var state: VTSViewState<TPhieuvc_Nhap_DanhSach?> = .idle
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
    
    func loadDetails(existing: TPhieuvc_Nhap_DanhSach? = nil) async {
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
            
            if let targetSoPhieu = soPhieu ?? existing?.soPhieu, !targetSoPhieu.isEmpty {
                async let infoTask = PhieuNhapService.shared.thongTin(soPhieu: targetSoPhieu)
                async let hinhTask = PhieuNhapService.shared.thongTinHinhAnh(
                    soPhieu: targetSoPhieu,
                    danhSachHinh: [
                        Params_MaHinh(maHinh: "Hinh01"),
                        Params_MaHinh(maHinh: "Hinh02")
                    ]
                )
                
                let (infoRes, hinhRes) = await (try? infoTask, try? hinhTask)
                if var found = infoRes?.DataResult {
                    if let list = hinhRes?.DataResults, !list.isEmpty {
                        if let item0 = list.first(where: { $0.maHinh == "Hinh01" }) ?? (list.indices.contains(0) ? list[0] : nil), let str = item0.noiDungHinh, !str.isEmpty {
                            found.hinh01NoiDung = str
                        }
                        if let item1 = list.first(where: { $0.maHinh == "Hinh02" }) ?? (list.indices.contains(1) ? list[1] : nil), let str = item1.noiDungHinh, !str.isEmpty {
                            found.hinh02NoiDung = str
                        }
                    }
                    state = .success(found)
                } else if let existing = existing {
                    state = .success(existing)
                } else {
                    state = .empty
                }
            } else if let existing = existing {
                state = .success(existing)
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
