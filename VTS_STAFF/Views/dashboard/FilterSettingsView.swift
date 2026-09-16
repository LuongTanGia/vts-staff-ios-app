//
//  FilterSettingsView.swift
//  VTS_STAFF
//
//  Created by viettas on 08/07/2026.
//

import SwiftUI

struct FilterSettingsView: View {
    // MARK: - UI Text Strings
    private enum Strings {
        static let toolbarTitle = "Chọn định dạng xem dữ liệu"
        static let sectionNhap = "Dữ liệu Hàng nhận (Nhập)"
        static let sectionXuat = "Dữ liệu Hàng giao (Xuất)"
        static let toggleHomNayLabel = "Dữ liệu hôm nay"
        static let toggleTuanNayLabel = "Dữ liệu tuần này"
        static let descNhapHomNay = "Hiển thị hàng nhận hôm nay"
        static let descNhapTuanNay = "Hiển thị hàng nhận tuần này"
        static let descXuatHomNay = "Hiển thị hàng giao hôm nay"
        static let descXuatTuanNay = "Hiển thị hàng giao tuần này"
    }

    // Hàng Nhận (Nhập)
    @AppStorage("vts_show_nhap_homnay") private var showNhapHomNay = true
    @AppStorage("vts_show_nhap_tuannay") private var showNhapTuanNay = false
    
    // Hàng Giao (Xuất)
    @AppStorage("vts_show_xuat_homnay") private var showXuatHomNay = true
    @AppStorage("vts_show_xuat_tuannay") private var showXuatTuanNay = false
    
    var body: some View {
        VTSPageContainer {
            ScrollView(showsIndicators: false) {
                VStack(spacing: VTSSpacing.xl) {
                    
                    // SECTION 1: Hàng Nhận (Nhập)
                    VTSGlassCard {
                        VStack(alignment: .leading, spacing: VTSSpacing.xl) {
                            Text(Strings.sectionNhap)
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                Toggle(isOn: $showNhapHomNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(Strings.toggleHomNayLabel)
                                        Text(Strings.descNhapHomNay)
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showNhapTuanNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(Strings.toggleTuanNayLabel)
                                        Text(Strings.descNhapTuanNay)
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                            }
                        }
                    }
                    
                    // SECTION 2: Hàng Giao (Xuất)
                    VTSGlassCard {
                        VStack(alignment: .leading, spacing: VTSSpacing.xl) {
                            Text(Strings.sectionXuat)
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                Toggle(isOn: $showXuatHomNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(Strings.toggleHomNayLabel)
                                        Text(Strings.descXuatHomNay)
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showXuatTuanNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(Strings.toggleTuanNayLabel)
                                        Text(Strings.descXuatTuanNay)
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                            }
                        }
                    }
                }
                .padding(.horizontal, VTSSpacing.xl)
                .padding(.top, VTSSpacing.lg)
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: Strings.toolbarTitle
        ) {
            EmptyView()
        } trailing: {
            EmptyView()
        } primaryAction: {
            EmptyView()
        }
    }
}

#Preview {
    FilterSettingsView()
}
