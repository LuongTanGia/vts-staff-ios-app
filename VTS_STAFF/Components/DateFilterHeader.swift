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

struct SystemDateFilterHeader: View {
    @Binding var fromDate: Date
    @Binding var toDate: Date
    
    var mode: DateFilterMode = .range
    var onChanged: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: VTSSpacing.sm) {
            if mode == .range {
                SystemDateField(title: "Từ ngày", date: $fromDate)
                    .frame(maxWidth: .infinity)
            }
            
            SystemDateField(
                title: mode == .range ? "Đến ngày" : "Ngày",
                date: $toDate
            )
            .frame(maxWidth: .infinity)
        }
        .padding(VTSSpacing.sm)
        .background(Color.vtsPrimary)
        .foregroundColor(.white)
//        .cornerRadius(VTSRadius.md)
        .frame(maxWidth: .infinity)
        .onChange(of: fromDate) { _, newValue in
            validateFromDate(newValue)
        }
        .onChange(of: toDate) { _, newValue in
            validateToDate(newValue)
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
            HStack(alignment: .center, spacing: VTSSpacing.xs) {
                Text(title)
                    .font(.vtsCallout.bold())
                    .foregroundColor(.vtsTxtSecondary)
                
                Text(customFormatter.string(from: date))
                    .font(.vtsCallout.bold())
                    .foregroundColor(.vtsPrimary)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.vtsPrimary.opacity(0.6))
                            .frame(height: 1)
                            .offset(y: 2)
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, VTSSpacing.sm)
            .padding(.horizontal, VTSSpacing.md)
            .background(Color.vtsSurface)
            .cornerRadius(VTSRadius.sm)
        }
        
        .buttonStyle(VTSPressButtonStyle())
        .sheet(isPresented: $showPicker) {
            CenteredDatePickerModal(
                date: $date,
                isPresented: $showPicker
            )
            .presentationDetents([
                .height(340)
            ])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(VTSRadius.xl)
        }
    }
}

// MARK: - POPUP MODAL (HIỂN THỊ WHEEL PICKER Ở GIỮA)
struct CenteredDatePickerModal: View {
    @Binding var date: Date
    @Binding var isPresented: Bool
    
    @State private var tempDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: VTSSpacing.xs) {
                Image(systemName: "calendar")
                    .foregroundColor(.vtsPrimary)
                    .font(.title3.bold())
                
                Text("Chọn ngày")
                    .font(.vtsTitle2.bold())
                    .foregroundColor(.vtsTxtPrimary)
                
                Spacer()
            }
            .padding(.horizontal, VTSSpacing.xl)
            .padding(.top, VTSSpacing.lg)
            .padding(.bottom, VTSSpacing.sm)
            
            Divider()
                .background(Color.vtsBorder.opacity(0.4))
                .padding(.horizontal, VTSSpacing.xl)
            
            // Date Picker
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
            
            // Action Buttons
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
