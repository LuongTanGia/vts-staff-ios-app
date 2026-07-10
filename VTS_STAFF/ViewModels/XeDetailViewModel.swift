//
//  XeDetailViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import Foundation
import Combine

@MainActor
final class XeDetailViewModel: ObservableObject {
    @Published var state: VTSViewState<TXe_ThongTin?> = .idle
    @Published var loaiXes: [TDanhSachMaTen] = []
    @Published var taiXes: [TDanhSachMaTen] = []
    @Published var nhomXes: [TDanhSachMaTen] = []
    
    let maXe: String?
    
    var isNew: Bool {
        maXe == nil || maXe?.isEmpty == true
    }
    
    init(maXe: String?) {
        self.maXe = maXe
    }
    
    func loadData() async {
        if case .loading = state { return }
        state = .loading
        
        do {
            async let loaiXeResponse = ListHelpersService.shared.danhSachLoaiXe()
            async let taiXeResponse = ListHelpersService.shared.danhSachTaiXe()
            async let nhomXeResponse = ListHelpersService.shared.danhSachNhomXe()
            
            let (loaiXeRes, taiXeRes, nhomXeRes) = try await (loaiXeResponse, taiXeResponse, nhomXeResponse)
            
            self.loaiXes = loaiXeRes.DataResults ?? []
            self.taiXes = taiXeRes.DataResults ?? []
            self.nhomXes = nhomXeRes.DataResults ?? []
            
            if let ma = maXe, !ma.isEmpty {
                let detailsResponse = try await XeService.shared.thongTin(ma: ma)
                if let details = detailsResponse.DataResult {
                    state = .success(details)
                } else {
                    state = .failure(detailsResponse.DataErrorDescription ?? "Không tìm thấy thông tin phương tiện")
                }
            } else {
                state = .success(nil)
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
