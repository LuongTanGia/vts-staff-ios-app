//
//  VTSSearchDropdown.swift
//  VTS_STAFF
//
//  Component Search Dropdown: Cho phép chọn giá trị từ danh sách lớn, hỗ trợ tìm kiếm.
//

import SwiftUI

struct VTSSearchDropdown<T: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var selection: T?
    let options: [T]
    let displayName: (T) -> String
    let displaySubtitle: ((T) -> String)?
    let icon: String?
    let errorMessage: String?
    let searchMatcher: ((T, String) -> Bool)?
    
    @State private var isSheetPresented = false
    @State private var searchText = ""
    
    init(
        label: String = "",
        placeholder: String,
        selection: Binding<T?>,
        options: [T],
        displayName: @escaping (T) -> String = { "\($0)" },
        displaySubtitle: ((T) -> String)? = nil,
        icon: String? = nil,
        errorMessage: String? = nil,
        searchMatcher: ((T, String) -> Bool)? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._selection = selection
        self.options = options
        self.displayName = displayName
        self.displaySubtitle = displaySubtitle
        self.icon = icon
        self.errorMessage = errorMessage
        self.searchMatcher = searchMatcher
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: VTSSpacing.sm) {
            // Label
            if !label.isEmpty {
                Text(label)
                    .font(.vtsCaption.bold())
                    .foregroundColor(.vtsTxtSecondary)
            }
            
            // Trigger Button
            Button {
                searchText = "" // Reset search text when opening
                isSheetPresented = true
            } label: {
                HStack(spacing: VTSSpacing.md) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.vtsTxtTertiary)
                            .frame(width: 18)
                    }
                    
                    Group {
                        if let selection = selection {
                            Text(displayName(selection))
                                .foregroundColor(.vtsTxtPrimary)
                        } else {
                            Text(placeholder)
                                .foregroundColor(.vtsTxtTertiary)
                        }
                    }
                    .font(.vtsBody)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.vtsTxtTertiary)
                }
                .padding(.horizontal, VTSSpacing.xl)
                .padding(.vertical, VTSSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: VTSRadius.md, style: .continuous)
                        .fill(Color.vtsSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: VTSRadius.md, style: .continuous)
                                .stroke(
                                    isSheetPresented ? Color.vtsBorderFocus
                                    : (errorMessage != nil ? Color.vtsDanger.opacity(0.6) : Color.vtsBorder),
                                    lineWidth: 1.5
                                )
                        )
                )
            }
            .buttonStyle(VTSPressButtonStyle())
            
            // Error Message
            if let err = errorMessage {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .font(.vtsCaption)
                    .foregroundColor(.vtsDanger)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
        .sheet(isPresented: $isSheetPresented) {
            searchSheetView
        }
    }
    
    // MARK: - Search Sheet View
    private var searchSheetView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(label.isEmpty ? "Chọn giá trị" : label)
                    .font(.vtsTitle2)
                    .foregroundColor(.vtsTxtPrimary)
                
                Spacer()
                
                Button {
                    isSheetPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.vtsTxtTertiary)
                }
            }
            .padding(.horizontal, VTSSpacing.xl)
            .padding(.top, VTSSpacing.xl)
            .padding(.bottom, VTSSpacing.md)
            
            // Search Input
            VTSSearchBar(text: $searchText, placeholder: "Tìm kiếm...")
                .padding(.horizontal, VTSSpacing.xl)
                .padding(.bottom, VTSSpacing.md)
            
            Divider()
            
            // Filter options
            let activeMatcher = searchMatcher ?? { option, query in
                displayName(option).localizedCaseInsensitiveContains(query)
            }
            
            let filteredOptions = options.filter { option in
                searchText.isEmpty || activeMatcher(option, searchText)
            }
            
            if filteredOptions.isEmpty {
                Spacer()
                VTSEmptyState(
                    icon: "magnifyingglass",
                    title: "Không tìm thấy kết quả",
                    subtitle: "Vui lòng thử tìm kiếm bằng từ khoá khác"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredOptions, id: \.self) { option in
                            Button {
                                selection = option
                                isSheetPresented = false
                            } label: {
                                HStack(spacing: VTSSpacing.md) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(displayName(option))
                                            .font(.vtsBody)
                                            .foregroundColor(selection == option ? .vtsPrimary : .vtsTxtPrimary)
                                            .bold(selection == option)
                                            .multilineTextAlignment(.leading)
                                        
                                        if let displaySubtitle {
                                            let subtitle = displaySubtitle(option)
                                            if !subtitle.isEmpty {
                                                Text(subtitle)
                                                    .font(.vtsCaption)
                                                    .foregroundColor(.vtsTxtSecondary)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if selection == option {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.vtsPrimary)
                                    }
                                }
                                .padding(.horizontal, VTSSpacing.xl)
                                .padding(.vertical, VTSSpacing.md)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.horizontal, VTSSpacing.xl)
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Extension for Non-Optional Selection
extension VTSSearchDropdown {
    init(
        label: String = "",
        placeholder: String,
        selection: Binding<T>,
        options: [T],
        displayName: @escaping (T) -> String = { "\($0)" },
        displaySubtitle: ((T) -> String)? = nil,
        icon: String? = nil,
        errorMessage: String? = nil,
        searchMatcher: ((T, String) -> Bool)? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._selection = Binding<T?>(
            get: { selection.wrappedValue },
            set: { newValue in
                if let newValue {
                    selection.wrappedValue = newValue
                }
            }
        )
        self.options = options
        self.displayName = displayName
        self.displaySubtitle = displaySubtitle
        self.icon = icon
        self.errorMessage = errorMessage
        self.searchMatcher = searchMatcher
    }
}

// MARK: - Extension for String Options
extension VTSSearchDropdown where T == String {
    init(
        label: String = "",
        placeholder: String,
        selection: Binding<String?>,
        options: [String],
        icon: String? = nil,
        errorMessage: String? = nil
    ) {
        self.init(
            label: label,
            placeholder: placeholder,
            selection: selection,
            options: options,
            displayName: { $0 },
            displaySubtitle: nil,
            icon: icon,
            errorMessage: errorMessage,
            searchMatcher: nil
        )
    }
    
    init(
        label: String = "",
        placeholder: String = "",
        selection: Binding<String>,
        options: [String],
        icon: String? = nil,
        errorMessage: String? = nil
    ) {
        self.init(
            label: label,
            placeholder: placeholder,
            selection: selection,
            options: options,
            displayName: { $0 },
            displaySubtitle: nil,
            icon: icon,
            errorMessage: errorMessage,
            searchMatcher: nil
        )
    }
}

// MARK: - Preview
#Preview("Search Dropdown") {
    struct PreviewWrapper: View {
        @State private var selectedName: String? = nil
        @State private var selectedCity = "Hồ Chí Minh"
        
        let names = ["Nguyễn Văn A", "Trần Thị B", "Lê Hoàng C", "Phạm Minh D", "Vũ Tiến E", "Đặng Quang F"]
        let cities = ["Hà Nội", "Hồ Chí Minh", "Đà Nẵng", "Hải Phòng", "Cần Thơ", "Nha Trang"]
        
        var body: some View {
            ZStack {
                LinearGradient.vtsBackground.ignoresSafeArea()
                VStack(spacing: 20) {
                    VTSSearchDropdown(
                        label: "Nhân viên (Optional)",
                        placeholder: "Chọn nhân viên...",
                        selection: $selectedName,
                        options: names
                    )
                    
                    VTSSearchDropdown(
                        label: "Thành phố (Non-Optional)",
                        placeholder: "Chọn thành phố...",
                        selection: $selectedCity,
                        options: cities
                    )
                    
                    VTSSearchDropdown(
                        label: "Nhân viên (Có lỗi)",
                        placeholder: "Chọn nhân viên...",
                        selection: .constant(nil as String?),
                        options: names,
                        errorMessage: "Vui lòng chọn một nhân viên từ danh sách"
                    )
                }
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
