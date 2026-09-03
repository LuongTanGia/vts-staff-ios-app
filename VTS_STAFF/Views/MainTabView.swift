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
    @State private var selectedTab = 0
    
    private var hasHomePermission: Bool {
        authManager.chucNangPhanQuyens.contains(where: { $0.maChucNang == "VTSSTAFF_DASBOARD_NHANVIEN" && $0.visible && $0.view })
    }
    
    init() {
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
                    Label("Trang chủ", image: "lucide_home")
                }
                .tag(0)
            }
            
            // Tab 2: Dữ liệu
            RouterView { _ in
                DataListView()
            }
            .tabItem {
                Label("Dữ liệu", image: "lucide_layout_grid")
            }
            .tag(1)
            
            // Tab 3: Thông báo
            RouterView { _ in
                ThongBaoView()
            }
            .tabItem {
                Label("Thông báo", image: "lucide_bell")
            }
            .tag(2)
            
            // Tab 4: Thông tin
            RouterView { _ in
                InfoView()
            }
            .tabItem {
                Label("Thông tin", image: "lucide_info")
            }
            .tag(3)
            
            // Tab 5: Cài đặt
            RouterView { _ in
                SettingsView()
            }
            .tabItem {
                Label("Cài đặt", image: "lucide_settings")
            }
            .tag(4)
        }
        .onAppear {
            if !hasHomePermission {
                selectedTab = 1
            } else {
                selectedTab = 0
            }
        }
        .tint(.vtsPrimary)
        .tabViewStyle(.sidebarAdaptable)
        
        
        
    }
}

#Preview {
    MainTabView()
}
