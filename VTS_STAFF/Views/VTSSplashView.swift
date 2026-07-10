//
//  VTSSplashView.swift
//  VTS_STAFF
//
//  Created by viettas on 22/06/2026.
//

import SwiftUI

struct VTSSplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 20
    @State private var isRotationActive = false
    
    var body: some View {
        VTSPageContainer(hasGradient: false) {
            VStack(spacing: VTSSpacing.xxxl) {
                Spacer()
                
                // Logo trung tâm với vòng tròn xoay phát sáng
                ZStack {
                    // Vòng tròn phát sáng ngoài xoay liên tục
                    Circle()
                        .trim(from: 0.0, to: 0.75)
                        .stroke(
                            AngularGradient(
                                colors: [.vtsPrimary, .vtsSecondary, .vtsPrimary.opacity(0.1)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                        )
                        .frame(width: 170, height: 170)
                        .rotationEffect(.degrees(isRotationActive ? 360 : 0))
                        .animation(.linear(duration: 1.8).repeatForever(autoreverses: false), value: isRotationActive)
                    
                    // Logo chính của ứng dụng
                    Image("VTSLogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.vtsBg.opacity(0.5), lineWidth: 1.5)
                        )
                        .shadow(color: .vtsBg.opacity(0.6), radius: 25)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
                
                // Khu vực tiêu đề ứng dụng
                VStack(spacing: VTSSpacing.md) {
                    Text("VTS STAFF")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.vtsBg)
                        .tracking(3)
                    
                    Text("HỆ THỐNG QUẢN LÝ VẬN CHUYỂN NỘI BỘ")
                        .font(.vtsCaption.bold())
                        .foregroundColor(.vtsBg)
                        .tracking(2)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
                
                Spacer()
                
                // Trạng thái tải dữ liệu ở dưới cùng
                VStack(spacing: VTSSpacing.sm) {
                    ProgressView()
                        .tint(.vtsBg)
                        .scaleEffect(1.2)
                    
                    Text("Đang khởi động hệ thống...")
                        .font(.vtsCaption)
                        .foregroundColor(.vtsTxtTertiary)
                        .tracking(1)
                }
                .padding(.bottom, 40)
                .opacity(textOpacity)
            }
            .padding(VTSSpacing.xxl)
        }
        .onAppear {
            // Hiệu ứng Zoom & Mờ dần cho Logo
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Hiệu ứng xuất hiện cho văn bản trễ hơn 0.3 giây
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
                textOffset = 0
            }
            
            // Kích hoạt vòng xoay vô tận
            isRotationActive = true
        }
    }
}

#Preview {
    VTSSplashView()
}
