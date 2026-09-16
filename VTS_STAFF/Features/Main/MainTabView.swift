//
//  MainTabView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct MainTabView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedTab: Int
    
    private var hasHomePermission: Bool {
        authManager.chucNangPhanQuyens.contains(where: { $0.maChucNang == "VTSSTAFF_DASBOARD_NHANVIEN" && $0.visible && $0.view })
    }
    
    init() {
        let hasHome = AuthManager.shared.chucNangPhanQuyens.contains(where: { $0.maChucNang == "VTSSTAFF_DASBOARD_NHANVIEN" && $0.visible && $0.view })
        self._selectedTab = State(initialValue: hasHome ? 0 : 1)
        
        // Cấu hình giao diện UITabBar chuyên nghiệp, hòa hợp với nền tối màu của app
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(Color.vtsBg.opacity(0.95)) // Màu nền khớp với vtsBg
        
        // Cấu hình màu cho tab active và inactive
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.vtsPrimary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.vtsPrimary),
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.vtsSecondary.opacity(0.6))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.vtsSecondary.opacity(0.6)),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Trang chủ (Conditionally rendered)
            if hasHomePermission {
                RouterView { _ in
                    HomeView()
                }
                .tabItem {
                    Label(Strings.tabHome, image: "lucide_home")
                }
                .tag(0)
            }
            
            // Tab 2: Dữ liệu
            RouterView { _ in
                DataListView()
            }
            .tabItem {
                Label(Strings.tabData, image: "lucide_layout_grid")
            }
            .tag(1)
            
            // Tab 3: Thông báo
            RouterView { _ in
                ThongBaoView()
            }
            .tabItem {
                Label(Strings.tabNotifications, image: "lucide_bell")
            }
            .tag(2)
            
            // Tab 4: Thông tin
            RouterView { _ in
                InfoView()
            }
            .tabItem {
                Label(Strings.tabInfo, image: "lucide_info")
            }
            .tag(3)
            
            // Tab 5: Cài đặt
            RouterView { _ in
                SettingsView()
            }
            .tabItem {
                Label(Strings.tabSettings, image: "lucide_settings")
            }
            .tag(4)
        }
        .onChange(of: hasHomePermission) { _, hasHome in
            if !hasHome && selectedTab == 0 {
                selectedTab = 1
            }
        }
        .tint(.vtsPrimary)
    }
}

// MARK: - UI Text Strings
private enum Strings {
    static let tabHome = "Trang chủ"
    static let tabData = "Dữ liệu"
    static let tabNotifications = "Thông báo"
    static let tabInfo = "Thông tin"
    static let tabSettings = "Cài đặt"
}

#Preview {
    MainTabView()
}
