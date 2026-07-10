//
//  HangHoaDetailViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import Foundation
import Combine

@MainActor
final class HangHoaDetailViewModel: ObservableObject {
    @Published var state: VTSViewState<THangHoa_ThongTin?> = .idle
    @Published var loaiHHs: [TDanhSachMaTen] = []
    @Published var nhomHHs: [TDanhSachMaTen] = []
    
    let maHH: String?
    
    var isNew: Bool {
        maHH == nil || maHH?.isEmpty == true
    }
    
    init(maHH: String?) {
        self.maHH = maHH
    }
    
    func loadDetails() async {
        if case .loading = state { return }
        state = .loading
        
        do {
            async let loaiHHResponse = ListHelpersService.shared.danhSachLoaiHang()
            async let nhomHHResponse = ListHelpersService.shared.danhSachNhomHang()
            
            let (loaiHHRes, nhomHHRes) = try await (loaiHHResponse, nhomHHResponse)
            
            self.loaiHHs = loaiHHRes.DataResults ?? []
            self.nhomHHs = nhomHHRes.DataResults ?? []
            
            if let ma = maHH, !ma.isEmpty {
                let response = try await HangHoaService.shared.thongTin(ma: ma)
                if let details = response.DataResult {
                    state = .success(details)
                } else {
                    state = .failure(response.DataErrorDescription ?? "Không tìm thấy thông tin hàng hoá")
                }
            } else {
                state = .success(nil)
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
