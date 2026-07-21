//
//  InfoView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct InfoView: View {
    @Environment(\.router) private var router
    
    var body: some View {
        VTSPageContainer{
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: Top Parallax Banner
                    GeometryReader { geo in
                        let minY = geo.frame(in: .global).minY
                        ZStack(alignment: .bottom) {
                            Image("TechBanner")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.height + (minY > 0 ? minY : 0))
                                .clipped()
                            
                            // Bottom dark fade
                            LinearGradient(
                                colors: [Color.black.opacity(0.4), Color.black.opacity(0.1), Color.black.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            VStack(spacing: 0) {
                                Text("Công Ty Cổ Phần Giải Pháp Thương Mại\nViệt Nam Sài Gòn")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, VTSSpacing.lg)
                                    .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                            }
                            .padding(.bottom, 24)
                            .frame(maxWidth: .infinity)
                        }
                        .frame(width: geo.size.width, height: geo.size.height + (minY > 0 ? minY : 0))
                        .offset(y: minY > 0 ? -minY : -minY * 0.4) // Parallax offset!
                    }
                    .frame(height: 240)
                    
                    // MARK: Scrollable Content
                    VStack(spacing: 20) {
                        
                        // MARK: Company Details Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.vtsPrimary)
                                    .font(.title3)
                                Text("Thông tin doanh nghiệp")
                                    .font(.vtsHeadline.bold())
                                    .foregroundColor(.vtsTxtPrimary)
                            }
                            .padding(.bottom, 4)
                            
                            infoItem(icon: "mappin.and.ellipse", iconColor: .blue, label: "Địa chỉ", value: "351/9 Nơ Trang Long, Phường Bình Lợi Trung, Tp.Hồ Chí Minh")
                            
                            VTSDivider()
                            
                            infoItem(icon: "doc.text.fill", iconColor: .teal, label: "Mã số thuế", value: "0312055823", isBoldValue: true)
                            
                            VTSDivider()
                            
                            infoItemWithLinks(icon: "phone.fill", iconColor: .green, label: "Điện thoại", values: ["02822412141", "02822412142"], isPhone: true)
                            
                            VTSDivider()
                            
                            infoItemWithLinks(icon: "globe", iconColor: .indigo, label: "Website", values: ["https://www.viettassaigon.vn"], isWeb: true)
                            
                            VTSDivider()
                            
                            infoItemWithLinks(icon: "envelope.fill", iconColor: .purple, label: "Email", values: ["hotro@viettassaigon.vn"], isEmail: true)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: App Card
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
                                Image("VTSLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("VTS-Staff")
                                        .font(.vtsTitle.bold())
                                        .foregroundColor(.vtsPrimary)
                                    
                                    HStack(spacing: 4) {
                                        Text("Phiên bản:")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                        Text("1.26.06.1603")
                                            .font(.vtsCaption.bold())
                                            .foregroundColor(.vtsTxtPrimary)
                                    }
                                }
                                Spacer()
                            }
                            
                            VTSDivider()
                            
                            Text("Công cụ Kiểm soát nội bộ dành riêng cho công nhân viên đang làm việc tại doanh nghiệp, bản quyền thuộc về Công Ty Cổ Phần Giải Pháp Thương Mại Việt Nam Sài Gòn")
                                .font(.vtsCallout)
                                .foregroundColor(.vtsTxtSecondary)
                                .lineSpacing(5)
                                .multilineTextAlignment(.leading)
                            
                            VTSDivider()
                            
                            Text("Công Ty Cổ Phần Giải Pháp Thương Mại Việt Nam Sài Gòn bảo lưu mọi quyền.")
                                .font(.vtsCaption.bold().italic())
                                .foregroundColor(.vtsPrimary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                        )
                        
                        // MARK: Policies & Actions Card
                        VStack(spacing: 0) {
                            policyRow(title: "Điều khoản sử dụng:", action: {
                                router.showScreen(.push) { _ in
                                    PolicyDocumentView(documentName: "terms", title: "Điều khoản sử dụng")
                                }
                            })
                            
                            VTSDivider()
                            
                            policyRow(title: "Chính sách bảo mật:", action: {
                                router.showScreen(.push) { _ in
                                    PolicyDocumentView(documentName: "privacy", title: "Chính sách bảo mật")
                                }
                            })
                            
                            VTSDivider()
                            
                            policyRow(title: "Thành phần & Thử nghiệm OCR:", action: {
                                router.showScreen(.push) { _ in
                                    ComponentShowcaseView()
                                }
                            })
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                        )
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, VTSSpacing.xl)
                    .padding(.top, VTSSpacing.lg)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Thông tin",
            
            leading: {},
            trailing: {},
            primaryAction: {
                EmptyView()
            }
        )
        
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func infoItem(icon: String, iconColor: Color, label: String, value: String, isBoldValue: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.vtsCaption)
                    .foregroundColor(.vtsTxtTertiary)
                Text(value)
                    .font(isBoldValue ? .vtsCallout.bold() : .vtsCallout)
                    .foregroundColor(.vtsTxtPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    @ViewBuilder
    private func infoItemWithLinks(icon: String, iconColor: Color, label: String, values: [String], isPhone: Bool = false, isWeb: Bool = false, isEmail: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.vtsCaption)
                    .foregroundColor(.vtsTxtTertiary)
                
                ForEach(values, id: \.self) { val in
                    Button {
                        handleLinkTap(val, isPhone: isPhone, isWeb: isWeb, isEmail: isEmail)
                    } label: {
                        Text(val)
                            .font(.vtsCallout.bold())
                            .foregroundColor(.vtsPrimary)
                            .underline()
                            .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    @ViewBuilder
    private func policyRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.vtsCallout)
                    .foregroundColor(.vtsTxtPrimary)
                Spacer()
                Text("Xem nội dung")
                    .font(.vtsCallout.bold())
                    .foregroundColor(.vtsPrimary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.vtsPrimary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleLinkTap(_ value: String, isPhone: Bool, isWeb: Bool, isEmail: Bool) {
        if isPhone {
            let cleanPhone = value.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: "tel://\(cleanPhone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else if isWeb {
            if let url = URL(string: value) {
                UIApplication.shared.open(url)
            }
        } else if isEmail {
            if let url = URL(string: "mailto:\(value)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    RouterView { _ in
        InfoView()
    }
}
