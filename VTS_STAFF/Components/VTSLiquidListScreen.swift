
//
//  VTSLiquidListScreen.swift
//  VTS_STAFF
//
//  Các component dùng lại cho màn hình danh sách (Xe, Khách hàng, Hàng hoá, Nhân viên)
//
//  Components:
//    • VTSLiquidSearchBar     – ô tìm kiếm (style Android: border radius + X + 🔍)
//    • VTSLiquidDateFilter    – thanh lọc "Từ ngày … Đến ngày …" (trên màn hình Phiếu)
//    • VTSLiquidTableFooter   – thanh "Tổng cộng N" sticky dưới cùng bảng
//    • VTSLiquidFAB           – Floating Action Button "+" (góc dưới trái như Android)
//    • VTSLiquidMenuCard      – Ô menu lớn (icon + title + subtitle + >) trong Dữ Liệu
//    • VTSCompanyFooter       – Logo + tên công ty dưới cùng (giống Android)
//

import SwiftUI

// MARK: - ============================================================
//              VTSLiquidSearchBar
// MARK: - ============================================================

struct VTSLiquidSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Nhập nội dung để tìm"
    var onSearch: (() -> Void)?
    
    @FocusState private var focused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Text field
            HStack(spacing: 10) {
                TextField("", text: $text,
                          prompt: Text(placeholder).foregroundStyle(Color.vtsPrimary.opacity(0.6)))
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .focused($focused)
                .submitLabel(.search)
                .onSubmit { onSearch?() }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
            )
            .frame(maxWidth: .infinity)
            
            // Clear button
            if !text.isEmpty {
                Button {
                    text = ""
                    focused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.vtsDanger)
                        .padding(.leading, 10)
                }
                .buttonStyle(VTSPressButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
            
            // Search button
            Button {
                focused = false
                onSearch?()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.vtsPrimary)
                    .padding(.leading, 12)
            }
            .buttonStyle(VTSPressButtonStyle())
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: text.isEmpty)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.03))
    }
}

// MARK: - ============================================================
//              VTSLiquidDateFilter
// MARK: - ============================================================
/// Thanh lọc ngày giống Android: "Từ ngày [date] Đến ngày [date]"

struct VTSLiquidDateFilter: View {
    @Binding var from: Date
    @Binding var to: Date
    var onSearch: (() -> Void)?
    
    @State private var showFrom = false
    @State private var showTo   = false
    
    var body: some View {
        HStack(spacing: VTSSpacing.sm) {
            // Từ ngày
            dateChip(label: "Từ ngày", date: from) { showFrom = true }
            
            // Đến ngày
            dateChip(label: "Đến ngày", date: to) { showTo = true }
            
            // Search icon button
            if let onSearch {
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.vtsPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.vtsPrimary.opacity(0.1), in: Circle())
                }
                .buttonStyle(VTSPressButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .sheet(isPresented: $showFrom) { datePicker("Từ ngày", selection: $from, max: to) }
        .sheet(isPresented: $showTo)   { datePicker("Đến ngày", selection: $to, min: from) }
    }
    
    @ViewBuilder
    private func dateChip(label: String, date: Date, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(shortDate(date))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.vtsPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(
                .regularMaterial,
                in: Capsule()
            )
            .overlay(Capsule().stroke(Color.vtsPrimary.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(VTSPressButtonStyle())
    }
    
    @ViewBuilder
    private func datePicker(_ title: String, selection: Binding<Date>, min: Date? = nil, max: Date? = nil) -> some View {
        NavigationStack {
            DatePicker(title, selection: selection,
                       in: (min ?? .distantPast)...(max ?? .distantFuture),
                       displayedComponents: .date)
            .datePickerStyle(.graphical)
            .tint(.vtsPrimary)
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") { showFrom = false; showTo = false }
                        .foregroundStyle(Color.vtsPrimary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(24)
    }
    
    private func shortDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: d)
    }
}

// MARK: - ============================================================
//              VTSLiquidTableFooter
// MARK: - ============================================================
/// Thanh tổng cộng sticky dưới bảng: "Tổng cộng N [phiếu]" + optional amount

struct VTSLiquidTableFooter: View {
    let count: Int
    let unit: String         // "phiếu", "mục", ""
    let totalAmount: String? // optional số tiền/khối lượng
    
    init(count: Int, unit: String = "", totalAmount: String? = nil) {
        self.count       = count
        self.unit        = unit
        self.totalAmount = totalAmount
    }
    
    var body: some View {
        HStack {
            Text("Tổng cộng")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text("\(count)" + (unit.isEmpty ? "" : " \(unit)"))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.vtsPrimary)
            
            if let amount = totalAmount {
                Spacer()
                Text(amount)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.vtsPrimary.opacity(0.08))
        .overlay(
            Rectangle()
                .fill(Color.vtsPrimary.opacity(0.15))
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - ============================================================
//              VTSLiquidFAB  (Floating Action Button "+")
// MARK: - ============================================================

struct VTSLiquidFAB: View {
    let icon: String
    let action: () -> Void
    var label: String? = nil
    
    init(icon: String = "plus", label: String? = nil, action: @escaping () -> Void) {
        self.icon   = icon
        self.label  = label
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: label != nil ? 8 : 0) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                if let label {
                    Text(label).font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .padding(label != nil ? EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
                     : EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.vtsPrimary, Color.vtsSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .if(label != nil) { $0.clipShape(Capsule()) }
            )
            .shadow(color: Color.vtsPrimary.opacity(0.45), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(VTSPressButtonStyle())
    }
}

// MARK: - ============================================================
//              VTSLiquidMenuCard  (mục menu lớn trong Dữ Liệu)
// MARK: - ============================================================

struct VTSLiquidMenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String = "",
        icon: String,
        accentColor: Color = .vtsPrimary,
        action: @escaping () -> Void
    ) {
        self.title       = title
        self.subtitle    = subtitle
        self.icon        = icon
        self.accentColor = accentColor
        self.action      = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon với liquid glass
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accentColor)
                        .frame(width: 54, height: 54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.primary.opacity(0.07), lineWidth: 1)
            )
        }
        .buttonStyle(VTSPressButtonStyle())
    }
}

// MARK: - ============================================================
//              VTSCompanyFooter  (logo + tên công ty dưới cùng)
// MARK: - ============================================================

struct VTSCompanyFooter: View {
    let companyName: String
    let address: String
    
    init(
        companyName: String = "Viettas SaiGon JSC.",
        address: String = "351/9 Nơ Trang Long, P. Bình Lợi Trung, Tp.HCM"
    ) {
        self.companyName = companyName
        self.address     = address
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo placeholder (thay bằng Image("vts_logo") nếu có asset)
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.vtsPrimary)
                    .frame(width: 44, height: 44)
                Text("VTS")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(companyName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
                Text(address)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Preview
#Preview("List Components") {
    ZStack(alignment: .bottomLeading) {
        VStack(spacing: 0) {
            LinearGradient.vtsBackground.ignoresSafeArea().frame(height: 0)
            
            // Search
            VTSLiquidSearchBar(text: .constant("Than BBQ"))
            
            // Date filter
            VTSLiquidDateFilter(
                from: .constant(Calendar.current.date(byAdding: .month, value: -4, to: Date())!),
                to:   .constant(Date())
            )
            
            Spacer()
            
            // Footer
            VTSLiquidTableFooter(count: 12, unit: "phiếu", totalAmount: "95.840")
            
            // Menu cards
            VStack(spacing: 10) {
                VTSLiquidMenuCard(title: "Hàng hóa", subtitle: "Danh sách hàng hóa giao, nhận",
                                  icon: "shippingbox.fill") {}
                VTSLiquidMenuCard(title: "Chuyến hàng gia công", subtitle: "Hàng hóa xuất gia công và nhận về",
                                  icon: "gearshape.2.fill", accentColor: Color(hex: "A0845C")) {}
            }
            .padding()
            
            VTSCompanyFooter()
        }
        .preferredColorScheme(.dark)
        
        // FAB
        VTSLiquidFAB { }
            .padding(24)
    }
}
