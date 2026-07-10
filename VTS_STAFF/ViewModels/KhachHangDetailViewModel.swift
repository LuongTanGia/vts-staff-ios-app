//
//  KhachHangDetailViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import Foundation
import Combine

@MainActor
final class KhachHangDetailViewModel: ObservableObject {
    @Published var state: VTSViewState<TKhachhang_ThongTin?> = .idle
    @Published var loaiKHs: [TDanhSachMaTen] = []
    @Published var nhomKHs: [TDanhSachMaTen] = []
    
    let maKH: String?
    
    var isNew: Bool {
        maKH == nil || maKH?.isEmpty == true
    }
    
    init(maKH: String?) {
        self.maKH = maKH
    }
    
    func loadDetails() async {
        if case .loading = state { return }
        state = .loading
        
        do {
            async let loaiKHResponse = ListHelpersService.shared.danhSachLoaiKhachHang()
            async let nhomKHResponse = ListHelpersService.shared.danhSachNhomKhachHang()
            
            let (loaiKHRes, nhomKHRes) = try await (loaiKHResponse, nhomKHResponse)
            
            self.loaiKHs = loaiKHRes.DataResults ?? []
            self.nhomKHs = nhomKHRes.DataResults ?? []
            
            if let ma = maKH, !ma.isEmpty {
                let response = try await KhachHangService.shared.thongTin(ma: ma)
                if let details = response.DataResult {
                    state = .success(details)
                } else {
                    state = .failure(response.DataErrorDescription ?? "Không tìm thấy thông tin đối tác")
                }
            } else {
                state = .success(nil)
            }
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
