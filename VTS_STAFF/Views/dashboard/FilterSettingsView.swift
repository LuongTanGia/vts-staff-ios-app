//
//  FilterSettingsView.swift
//  VTS_STAFF
//
//  Created by viettas on 08/07/2026.
//

import SwiftUI

struct FilterSettingsView: View {
    // Hàng Nhận (Nhập)
    @AppStorage("vts_show_nhap_homnay") private var showNhapHomNay = true
    @AppStorage("vts_show_nhap_tuannay") private var showNhapTuanNay = false
    @AppStorage("vts_show_nhap_tuantruoc") private var showNhapTuanTruoc = false
    
    // Hàng Giao (Xuất)
    @AppStorage("vts_show_xuat_homnay") private var showXuatHomNay = true
    @AppStorage("vts_show_xuat_tuannay") private var showXuatTuanNay = false
    @AppStorage("vts_show_xuat_tuantruoc") private var showXuatTuanTruoc = false
    
    var body: some View {
        VTSPageContainer {
            ScrollView(showsIndicators: false) {
                VStack(spacing: VTSSpacing.xl) {
                    
                    // SECTION 1: Hàng Nhận (Nhập)
                    VTSGlassCard {
                        VStack(alignment: .leading, spacing: VTSSpacing.xl) {
                            Text("Dữ liệu Hàng nhận (Nhập)")
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                Toggle(isOn: $showNhapHomNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu hôm nay")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng nhận hôm nay")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showNhapTuanNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần này")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng nhận tuần này")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showNhapTuanTruoc) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần trước")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng nhận tuần trước")
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
                            Text("Dữ liệu Hàng giao (Xuất)")
                                .font(.vtsTitle2.bold())
                                .foregroundColor(.vtsTxtPrimary)
                            
                            VStack(spacing: VTSSpacing.lg) {
                                Toggle(isOn: $showXuatHomNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu hôm nay")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng giao hôm nay")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showXuatTuanNay) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần này")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng giao tuần này")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                    }
                                }
                                .tint(.vtsPrimary)
                                
                                VTSDivider()
                                
                                Toggle(isOn: $showXuatTuanTruoc) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dữ liệu tuần trước")
                                            .font(.vtsCallout.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                        Text("Hiển thị hàng giao tuần trước")
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
            subtitle: "Chọn định dạng xem dữ liệu"
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
