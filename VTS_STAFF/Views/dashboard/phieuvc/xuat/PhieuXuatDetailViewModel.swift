//
//  PhieuXuatDetailViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 18/07/2026.
//

import Foundation
import Combine
import UIKit

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
                let infoRes = try? await PhieuXuatService.shared.thongTin(soPhieu: targetSoPhieu)
                if let found = infoRes?.DataResult {
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
    
    func fetchOriginalImage(slotIndex: Int) async -> UIImage? {
        guard let targetSoPhieu = soPhieu, !targetSoPhieu.isEmpty else { return nil }
        let maHinh = "Hinh0\(slotIndex)"
        do {
            let res = try await PhieuXuatService.shared.thongTinHinhAnh(
                soPhieu: targetSoPhieu,
                danhSachHinh: [Params_MaHinh(maHinh: maHinh)]
            )
            if let list = res.DataResults,
               let item = list.first(where: { $0.maHinh == maHinh }) ?? list.first,
               let str = item.noiDungHinh, !str.isEmpty,
               let img = UIImage.fromBase64(str) {
                return img
            }
        } catch {
            print("Error fetching original image \(maHinh): \(error)")
        }
        return nil
    }
}
