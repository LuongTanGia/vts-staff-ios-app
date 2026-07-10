//
//  CustomToolbar.swift
//  ThongKe_iSale
//
//  Created by viettas on 9/5/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func customToolbar<Leading: View, Trailing: View, PrimaryAction: View>(
        isPrimaryActionVisible: Bool,
        title: String?,
        subtitle: String?,
        showLogout: Bool = false,
        isWhiteText: Bool = false,
        
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing,
        @ViewBuilder primaryAction: @escaping () -> PrimaryAction
    ) -> some View {
        self
            .modifier(
                CustomToolbarModifier(
                    isPrimaryActionVisible: isPrimaryActionVisible,
                    title: title,
                    subtitle: subtitle,
                    showLogout: showLogout,
                    isWhiteText: isWhiteText,
                    leading: leading,
                    trailing: trailing,
                    primaryAction: primaryAction
                )
            )
    }
}

// Helper view modifier
fileprivate struct CustomToolbarModifier<Leading: View, Trailing: View, PrimaryAction: View>: ViewModifier {
    var isPrimaryActionVisible: Bool
    var title: String?
    var subtitle: String?
    var showLogout: Bool
    var isWhiteText: Bool = false
    @ViewBuilder var leading:  Leading
    @ViewBuilder var trailing:  Trailing
    @ViewBuilder var primaryAction:  PrimaryAction
    
    func body (content: Content) -> some View {
        content
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    leading
                }
                ToolbarItem(placement: .title) {
                    Text(emptyLargeString)
                        .overlay(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(
                                    title?.isEmpty == false
                                    ? "\(title!)"
                                    : "VTS-Staff"
                                )
                                .font(.vtsScreenTitle)
                                .foregroundColor(
                                    isWhiteText ? Color.vtsBg : nil
                                )
                                .id(title ?? "")
                                .transition(.offset(y: 10).combined(with: AnyTransition(.blurReplace)))
                                
                                if let subtitle, !subtitle.isEmpty {
                                    Text(subtitle)
                                        .font(.vtsScreenSubtitle)
                                        .foregroundColor(
                                            isWhiteText ? Color.vtsBg : nil
                                        )
                                        .id(subtitle)
                                        .transition(.blurReplace)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.easeInOut(duration: 0.35), value: title)
                            .animation(.easeInOut(duration: 0.35), value: subtitle)
                        }
                        .lineLimit(1)
                    
                }
                
                if isPrimaryActionVisible {
                    ToolbarItem(placement: .topBarTrailing) {
                        primaryAction
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    trailing
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    if showLogout {
                        Button {
                            Task {
                                await AuthService.shared.dangXuat()
                            }
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.vtsPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        
            .animation(.bouncy(duration: 0.3, extraBounce: 0), value: isPrimaryActionVisible)
    }
    
    private var emptyLargeString: String {
        String(repeating: " ", count: 150)
    }
}
