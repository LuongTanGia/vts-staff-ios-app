//
//  NhanVienDetailViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 25/06/2026.
//

import Foundation
import Combine

@MainActor
final class NhanVienDetailViewModel: ObservableObject {
    @Published var state: VTSViewState<TNhanVien_ThongTin> = .idle
    @Published var phuongXas: [TDanhSachPhuongXa] = []
    @Published var tinhThanhs: [TDanhSachTinhThanh] = []
    let maNV: String
    
    init(maNV: String) {
        self.maNV = maNV
    }
    
    func loadDetails() async {
        if case .loading = state { return }
        state = .loading
        
        do {
            async let detailsResponse = NhanVienService.shared.thongTin(ma: maNV)
            async let phuongXaResponse = ListHelpersService.shared.danhSachPhuongXa()
            async let tinhThanhResponse = ListHelpersService.shared.danhSachTinhThanh()
            
            let (detailsRes, phuongXaRes, tinhThanhRes) = try await (detailsResponse, phuongXaResponse, tinhThanhResponse)
            
            self.phuongXas = phuongXaRes.DataResults ?? []
            self.tinhThanhs = tinhThanhRes.DataResults ?? []
            
            if let details = detailsRes.DataResult {
                state = .success(details)
            } else {
                state = .failure(detailsRes.DataErrorDescription ?? "Không tìm thấy thông tin nhân viên")
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
