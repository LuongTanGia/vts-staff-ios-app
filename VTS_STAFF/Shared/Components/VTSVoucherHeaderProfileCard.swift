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
        HStack(alignment: .center, spacing: 14) {
            // Left Icon (White circle with dark icon matching Android)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                
                LucideIcon(iconName, size: 24, color: Color(hex: "00497C"))
            }
            
            // Middle Info Column (Bold uniform typography like Android)
            VStack(alignment: .leading, spacing: 2) {
                // Line 1: [SoXe] - [TenNhanVien]
                let line1Parts = [(soXe ?? "").trimmingCharacters(in: .whitespaces), (tenNhanVien ?? "").trimmingCharacters(in: .whitespaces)]
                    .filter { !$0.isEmpty }
                let line1 = line1Parts.isEmpty ? "---" : line1Parts.joined(separator: " - ")
                
                Text(line1)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Line 2: [TenHangHoa] - [TrongLuongHang]
                let hh = (tenHangHoa ?? "").trimmingCharacters(in: .whitespaces)
                let tl = (trongLuongHang ?? "").trimmingCharacters(in: .whitespaces)
                let line2Parts = [hh.isEmpty ? nil : hh, tl.isEmpty ? nil : tl].compactMap { $0 }
                let line2 = line2Parts.isEmpty ? "---" : line2Parts.joined(separator: " - ")
                
                Text(line2)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Line 3: [TenKhachHang]
                let kh = (tenKhachHang ?? "").trimmingCharacters(in: .whitespaces)
                Text(kh.isEmpty ? "---" : kh)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
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
