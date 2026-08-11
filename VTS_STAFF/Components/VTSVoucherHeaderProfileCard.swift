//
//  VTSVoucherHeaderProfileCard.swift
//  VTS_STAFF
//
//  Profile header card component for detail/add/edit screens.
//

import SwiftUI

struct VTSVoucherHeaderProfileCard: View {
    let iconName: String
    let soXe: String?
    let tenNhanVien: String?
    let tenHangHoa: String?
    let trongLuongHang: String?
    let tenKhachHang: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left Icon (White circle with dark factory/truck icon)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "0F2D59"))
            }
            
            // Middle Info Column
            VStack(alignment: .leading, spacing: 3) {
                // Line 1: [SoXe] - [TenNhanVien]
                let line1Parts = [(soXe ?? "").trimmingCharacters(in: .whitespaces), (tenNhanVien ?? "").trimmingCharacters(in: .whitespaces)]
                    .filter { !$0.isEmpty }
                let line1 = line1Parts.isEmpty ? "---" : line1Parts.joined(separator: " - ")
                
                Text(line1)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Line 2: [TenHangHoa] - [TrongLuongHang]
                let hh = (tenHangHoa ?? "").trimmingCharacters(in: .whitespaces)
                let tl = (trongLuongHang ?? "").trimmingCharacters(in: .whitespaces)
                let line2Parts = [hh.isEmpty ? nil : hh, tl.isEmpty ? nil : tl].compactMap { $0 }
                let line2 = line2Parts.isEmpty ? "---" : line2Parts.joined(separator: " - ")
                
                Text(line2)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                
                // Line 3: [TenKhachHang]
                let kh = (tenKhachHang ?? "").trimmingCharacters(in: .whitespaces)
                Text(kh.isEmpty ? "---" : kh)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
        .background(Color.vtsPrimary)
    }
}
