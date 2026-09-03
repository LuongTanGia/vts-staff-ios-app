//
//  DateFilterHeader.swift
//  VTS_STAFF
//
//  Created by viettas on 13/5/26.
//

import SwiftUI

enum DateFilterMode {
    case range     // từ ngày -> đến ngày
    case single    // chỉ 1 ngày
}

// MARK: - QUICK DATE PRESETS ENUM
enum QuickDatePreset: String, CaseIterable, Identifiable {
    case homQua = "Hôm qua"
    case homNay = "Hôm nay"
    case tuanTruoc = "Tuần trước"
    case tuanNay = "Tuần này"
    case thangTruoc = "Tháng trước"
    case thangNay = "Tháng này"
    case namTruoc = "Năm trước"
    case namNay = "Năm nay"
    
    var id: String { rawValue }
    
    static var gridRows: [[QuickDatePreset]] {
        [
            [.homQua, .homNay],
            [.tuanTruoc, .tuanNay],
            [.thangTruoc, .thangNay],
            [.namTruoc, .namNay]
        ]
    }
    
    func calculateRange() -> (from: Date, to: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .homQua:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            let start = calendar.startOfDay(for: yesterday)
            return (start, start)
            
        case .homNay:
            let start = calendar.startOfDay(for: now)
            return (start, start)
            
        case .tuanTruoc:
            return Date.getWeekRange(offsetWeeks: -1)
            
        case .tuanNay:
            return Date.getWeekRange(offsetWeeks: 0)
            
        case .thangTruoc:
            if let firstDayThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
               let firstDayLastMonth = calendar.date(byAdding: .month, value: -1, to: firstDayThisMonth),
               let lastDayLastMonth = calendar.date(byAdding: .day, value: -1, to: firstDayThisMonth) {
                return (calendar.startOfDay(for: firstDayLastMonth), calendar.startOfDay(for: lastDayLastMonth))
            }
            return (now, now)
            
        case .thangNay:
            if let firstDayThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
               let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayThisMonth),
               let lastDayThisMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth) {
                return (calendar.startOfDay(for: firstDayThisMonth), calendar.startOfDay(for: lastDayThisMonth))
            }
            return (now, now)
            
        case .namTruoc:
            let year = calendar.component(.year, from: now) - 1
            let compFrom = DateComponents(year: year, month: 1, day: 1)
            let compTo = DateComponents(year: year, month: 12, day: 31)
            let start = calendar.date(from: compFrom) ?? now
            let end = calendar.date(from: compTo) ?? now
            return (calendar.startOfDay(for: start), calendar.startOfDay(for: end))
            
        case .namNay:
            let year = calendar.component(.year, from: now)
            let compFrom = DateComponents(year: year, month: 1, day: 1)
            let compTo = DateComponents(year: year, month: 12, day: 31)
            let start = calendar.date(from: compFrom) ?? now
            let end = calendar.date(from: compTo) ?? now
            return (calendar.startOfDay(for: start), calendar.startOfDay(for: end))
        }
    }
}

// MARK: - SYSTEM DATE FILTER HEADER
struct SystemDateFilterHeader: View {
    @Binding var fromDate: Date
    @Binding var toDate: Date
    
    var mode: DateFilterMode = .range
    var onChanged: (() -> Void)? = nil
    
    @State private var showQuickPresetsSheet: Bool = false
    
    var body: some View {
        HStack(spacing: VTSSpacing.xs) {
            if mode == .range {
                SystemDateField(
                    title: "Từ ngày",
                    date: $fromDate,
                    fromDate: $fromDate,
                    toDate: $toDate,
                    mode: mode,
                    onChanged: onChanged
                )
                .frame(maxWidth: .infinity)
            }
            
            SystemDateField(
                title: mode == .range ? "Đến ngày" : "Ngày",
                date: $toDate,
                fromDate: $fromDate,
                toDate: $toDate,
                mode: mode,
                onChanged: onChanged
            )
            .frame(maxWidth: .infinity)
            
            if mode == .range {
                Button(action: {
                    showQuickPresetsSheet = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: VTSRadius.sm)
                            .fill(Color.vtsSurface)
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.vtsPrimary)
                    }
                }
                .buttonStyle(VTSPressButtonStyle())
            }
        }
        .padding(VTSSpacing.sm)
        .background(Color.vtsPrimary)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .onChange(of: fromDate) { _, newValue in
            validateFromDate(newValue)
        }
        .onChange(of: toDate) { _, newValue in
            validateToDate(newValue)
        }
        .sheet(isPresented: $showQuickPresetsSheet) {
            VTSQuickDatePresetSheet(
                fromDate: $fromDate,
                toDate: $toDate,
                isPresented: $showQuickPresetsSheet,
                onSelected: {
                    onChanged?()
                }
            )
            .presentationDetents([.height(310)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(VTSRadius.xl)
        }
    }
    
    private func validateFromDate(_ newFrom: Date) {
        guard mode == .range else { return }
        if newFrom > toDate {
            fromDate = newFrom
            toDate = newFrom
        }
        onChanged?()
    }
    
    private func validateToDate(_ newTo: Date) {
        guard mode == .range else {
            fromDate = newTo
            onChanged?()
            return
        }
        
        if newTo < fromDate {
            fromDate = newTo
            toDate = newTo
        }
        onChanged?()
    }
}

// MARK: - SYSTEM DATE FIELD CẬP NHẬT
struct SystemDateField: View {
    let title: String
    @Binding var date: Date
    
    var fromDate: Binding<Date>? = nil
    var toDate: Binding<Date>? = nil
    var mode: DateFilterMode = .range
    var onChanged: (() -> Void)? = nil
    
    @State private var showPicker = false
    
    private let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter
    }()
    
    var body: some View {
        Button(action: {
            showPicker = true
        }) {
            HStack(alignment: .center, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.vtsTxtSecondary)
                    .lineLimit(1)
                
                Text(customFormatter.string(from: date))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.vtsPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.vtsPrimary.opacity(0.6))
                            .frame(height: 1)
                            .offset(y: 2)
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.vtsSurface)
            .cornerRadius(VTSRadius.sm)
        }
        .buttonStyle(VTSPressButtonStyle())
        .sheet(isPresented: $showPicker) {
            CenteredDatePickerModal(
                date: $date,
                fromDate: fromDate,
                toDate: toDate,
                isPresented: $showPicker,
                onChanged: onChanged
            )
            .presentationDetents([.height(380)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(VTSRadius.xl)
        }
    }
}

// MARK: - QUICK DATE PRESETS SHEET (MATCHING DESIGN SCREENSHOT)
struct VTSQuickDatePresetSheet: View {
    @Binding var fromDate: Date
    @Binding var toDate: Date
    @Binding var isPresented: Bool
    var onSelected: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.vtsPrimary)
                    .font(.title3.bold())
                
                Text("Chọn nhanh thời gian")
                    .font(.vtsTitle2.bold())
                    .foregroundColor(.vtsTxtPrimary)
                
                Spacer()
            }
            .padding(.horizontal, VTSSpacing.lg)
            .padding(.top, VTSSpacing.lg)
            
            Divider()
                .background(Color.vtsBorder.opacity(0.4))
                .padding(.horizontal, VTSSpacing.lg)
            
            VStack(spacing: 10) {
                ForEach(0..<QuickDatePreset.gridRows.count, id: \.self) { rowIndex in
                    let row = QuickDatePreset.gridRows[rowIndex]
                    HStack(spacing: 12) {
                        ForEach(row) { preset in
                            Button {
                                let range = preset.calculateRange()
                                fromDate = range.from
                                toDate = range.to
                                onSelected?()
                                isPresented = false
                            } label: {
                                HStack(spacing: 10) {
                                    LucideIcon(.calendar, size: 16, color: .vtsPrimary)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                    
                                    Text(preset.rawValue)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(hex: "0F2D59"))
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 11)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "F4F7FB"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "D5E1F0"), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, VTSSpacing.lg)
            .padding(.bottom, VTSSpacing.lg)
        }
        .background(Color.white)
    }
}

// MARK: - POPUP MODAL (WHEEL PICKER + CHỌN NHANH)
struct CenteredDatePickerModal: View {
    @Binding var date: Date
    var fromDate: Binding<Date>? = nil
    var toDate: Binding<Date>? = nil
    @Binding var isPresented: Bool
    var onChanged: (() -> Void)? = nil
    
    @State private var tempDate: Date = Date()
    @State private var activeTab: Int = 0 // 0: Chọn ngày, 1: Chọn nhanh
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Tab Switcher
            HStack(spacing: VTSSpacing.xs) {
                Image(systemName: activeTab == 0 ? "calendar" : "calendar.badge.clock")
                    .foregroundColor(.vtsPrimary)
                    .font(.title3.bold())
                
                Text(activeTab == 0 ? "Chọn ngày" : "Chọn nhanh thời gian")
                    .font(.vtsTitle2.bold())
                    .foregroundColor(.vtsTxtPrimary)
                
                Spacer()
                
                // Toggle Tab Button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        activeTab = (activeTab == 0) ? 1 : 0
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: activeTab == 0 ? "clock.arrow.circlepath" : "calendar")
                        Text(activeTab == 0 ? "Chọn nhanh" : "Lịch chọn")
                    }
                    .font(.caption.bold())
                    .foregroundColor(.vtsPrimary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(Color.vtsPrimary.opacity(0.12))
                    )
                }
            }
            .padding(.horizontal, VTSSpacing.xl)
            .padding(.top, VTSSpacing.lg)
            .padding(.bottom, VTSSpacing.sm)
            
            Divider()
                .background(Color.vtsBorder.opacity(0.4))
                .padding(.horizontal, VTSSpacing.xl)
            
            if activeTab == 0 {
                // Tab 0: Wheel Date Picker
                DatePicker(
                    "",
                    selection: $tempDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "vi_VN"))
                .padding(.horizontal, VTSSpacing.lg)
                .padding(.vertical, VTSSpacing.xs)
                
                // Action Buttons for Wheel Picker
                HStack(spacing: VTSSpacing.md) {
                    VTSButton("Huỷ", style: .secondary, size: .large) {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    
                    VTSButton("Xác nhận", style: .primary, size: .large) {
                        date = tempDate
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, VTSSpacing.xl)
                .padding(.bottom, VTSSpacing.lg)
            } else {
                // Tab 1: Quick Date Preset Grid (2x4)
                VStack(spacing: 10) {
                    ForEach(0..<QuickDatePreset.gridRows.count, id: \.self) { rowIndex in
                        let row = QuickDatePreset.gridRows[rowIndex]
                        HStack(spacing: 12) {
                            ForEach(row) { preset in
                                Button {
                                    let range = preset.calculateRange()
                                    if let fromDate = fromDate, let toDate = toDate {
                                        fromDate.wrappedValue = range.from
                                        toDate.wrappedValue = range.to
                                    } else {
                                        date = range.from
                                    }
                                    onChanged?()
                                    isPresented = false
                                } label: {
                                    HStack(spacing: 10) {
                                        LucideIcon(.calendar, size: 16, color: .vtsPrimary)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        
                                        Text(preset.rawValue)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color(hex: "0F2D59"))
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 11)
                                    .padding(.horizontal, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "F4F7FB"))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(hex: "D5E1F0"), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, VTSSpacing.lg)
                .padding(.top, 12)
                .padding(.bottom, VTSSpacing.lg)
            }
        }
        .background(Color.vtsBg)
        .onAppear {
            tempDate = date
        }
    }
}

#Preview {
    ZStack {
        Color.vtsBg.ignoresSafeArea()
        
        VStack(spacing: 20) {
            SystemDateFilterHeader(
                fromDate: .constant(Date()),
                toDate: .constant(Date()),
                onChanged: { }
            )
            .padding()
            
            SystemDateFilterHeader(
                fromDate: .constant(Date()),
                toDate: .constant(Date()),
                mode: .single,
                onChanged: { }
            )
            .padding()
        }
    }
}
