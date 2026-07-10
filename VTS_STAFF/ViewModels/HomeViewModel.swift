//
//  HomeViewModel.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showLogoutConfirm = false
    @Published var hoTen: String? = nil
    @Published var maNV: String? = nil
    @Published var avatar: String? = nil
    @Published var dashboardState: VTSViewState<HomeDashboardData> = .idle
    
    private let authService: AuthService
    private let dashboardService: DashboardService
    
    init(authService: AuthService? = nil, dashboardService: DashboardService? = nil) {
        self.authService = authService ?? .shared
        self.dashboardService = dashboardService ?? .shared
        
        // Synchronize profile details dynamically from the AuthManager singleton
        AuthManager.shared.$hoTen
            .assign(to: &$hoTen)
        AuthManager.shared.$maNV
            .assign(to: &$maNV)
        AuthManager.shared.$avatar
            .assign(to: &$avatar)
    }
    
    func loadDashboardData() async {
        // Only set loading if it's not already loading
        if case .loading = dashboardState { return }
        
        // Only show fullscreen loading spinner if we don't have success data yet
        if case .success = dashboardState {
            // Keep current data visible to avoid breaking pull-to-refresh scroll layout
        } else {
            dashboardState = .loading
        }
        
        do {
            let data = try await dashboardService.getHomeData()
            
            // Check if all data is empty
            if data.nhanVienInOut.isEmpty &&
                data.nhanVienPhongBan.isEmpty &&
                data.hangHoaChuyenXe.isEmpty &&
                data.hangNhap.isEmpty &&
                data.hangXuat.isEmpty {
                dashboardState = .empty
            } else {
                dashboardState = .success(data)
            }
        } catch {
            dashboardState = .failure(error.localizedDescription)
        }
    }
    
    func logout() async {
        await authService.dangXuat()
    }
}
