
//
//  VTSInput.swift
//  VTS_STAFF
//
//  Input fields: TextField, SearchBar, DateRangePicker, Picker, TextArea
//

import SwiftUI

// MARK: - ============================================================
//               VTSInputField (generic text input)
// MARK: - ============================================================

struct VTSInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let errorMessage: String?
    
    @FocusState private var isFocused: Bool
    
    init(
        label: String = "",
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        errorMessage: String? = nil
    ) {
        self.label        = label
        self.placeholder  = placeholder
        self._text        = text
        self.icon         = icon
        self.isSecure     = isSecure
        self.keyboardType = keyboardType
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: VTSSpacing.sm) {
            // Label
            if !label.isEmpty {
                Text(label)
                    .font(.vtsCaption.bold())
                    .foregroundColor(.vtsTxtSecondary)
            }
            
            // Input
            HStack(spacing: VTSSpacing.md) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isFocused ? .vtsPrimary : .vtsTxtTertiary)
                        .frame(width: 18)
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }
                
                Group {
                    if isSecure {
                        SecureField("", text: $text,
                                    prompt: Text(placeholder).foregroundColor(.vtsTxtTertiary))
                    } else {
                        TextField("", text: $text,
                                  prompt: Text(placeholder).foregroundColor(.vtsTxtTertiary))
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    }
                }
                .font(.vtsBody)
                .foregroundColor(.vtsTxtPrimary)
                .focused($isFocused)
                
                // Clear button
                if !text.isEmpty && isFocused {
                    Button { text = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.vtsTxtTertiary)
                    }
                }
            }
            .padding(.horizontal, VTSSpacing.xl)
            .padding(.vertical, VTSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: VTSRadius.md, style: .continuous)
                    .fill(Color.vtsSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: VTSRadius.md, style: .continuous)
                            .stroke(
                                isFocused ? Color.vtsBorderFocus
                                : (errorMessage != nil ? Color.vtsDanger.opacity(0.6) : Color.vtsBorder),
                                lineWidth: 1.5
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            // Error
            if let err = errorMessage {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .font(.vtsCaption)
                    .foregroundColor(.vtsDanger)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}

// MARK: - ============================================================
//                     VTSSearchBar
// MARK: - ============================================================

struct VTSSearchBar: View {
    @Binding var text: String
    let placeholder: String
    var onSubmit: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    init(text: Binding<String>, placeholder: String = "Tìm kiếm...", onSubmit: (() -> Void)? = nil) {
        self._text       = text
        self.placeholder = placeholder
        self.onSubmit    = onSubmit
    }
    
    var body: some View {
        HStack(spacing: VTSSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isFocused ? .vtsPrimary : .vtsTxtTertiary)
            
            TextField("", text: $text,
                      prompt: Text(placeholder).foregroundColor(.vtsTxtTertiary))
            .font(.vtsBody)
            .foregroundColor(.vtsTxtPrimary)
            .focused($isFocused)
            .onSubmit { onSubmit?() }
            
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.vtsTxtTertiary)
                }
            }
        }
        .padding(.horizontal, VTSSpacing.xl)
        .padding(.vertical, VTSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: VTSRadius.xxl, style: .continuous)
                .fill(Color.vtsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: VTSRadius.xxl, style: .continuous)
                        .stroke(isFocused ? Color.vtsBorderFocus : Color.vtsBorder, lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - ============================================================
//                   VTSDateRangePicker
// MARK: - ============================================================

struct VTSDateRangePicker: View {
    @Binding var from: Date
    @Binding var to: Date
    
    @State private var showFromPicker = false
    @State private var showToPicker   = false
    
    var body: some View {
        HStack(spacing: VTSSpacing.sm) {
            // From
            dateButton(label: "Từ ngày", date: from) {
                showFromPicker.toggle()
                showToPicker = false
            }
            
            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.vtsTxtTertiary)
            
            // To
            dateButton(label: "Đến ngày", date: to) {
                showToPicker.toggle()
                showFromPicker = false
            }
        }
        .sheet(isPresented: $showFromPicker) {
            datePicker(title: "Từ ngày", selection: $from, maxDate: to)
        }
        .sheet(isPresented: $showToPicker) {
            datePicker(title: "Đến ngày", selection: $to, minDate: from)
        }
    }
    
    @ViewBuilder
    private func dateButton(label: String, date: Date, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.vtsCaption)
                    .foregroundColor(.vtsTxtTertiary)
                Text(date.toDisplayString)
                    .font(.vtsCallout.bold())
                    .foregroundColor(.vtsTxtPrimary)
            }
            .padding(.horizontal, VTSSpacing.md)
            .padding(.vertical, VTSSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vtsSurface)
            .cornerRadius(VTSRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: VTSRadius.md)
                    .stroke(Color.vtsBorder, lineWidth: 1)
            )
        }
        .buttonStyle(VTSPressButtonStyle())
    }
    
    @ViewBuilder
    private func datePicker(title: String, selection: Binding<Date>, minDate: Date? = nil, maxDate: Date? = nil) -> some View {
        NavigationStack {
            DatePicker(
                title,
                selection: selection,
                in: (minDate ?? Date.distantPast)...(maxDate ?? Date.distantFuture),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(.vtsPrimary)
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        showFromPicker = false
                        showToPicker   = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(VTSRadius.xxl)
    }
}

// MARK: - ============================================================
//                     VTSTextArea
// MARK: - ============================================================

struct VTSTextArea: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat
    
    @FocusState private var isFocused: Bool
    
    init(label: String = "", placeholder: String = "Nhập ghi chú...",
         text: Binding<String>, minHeight: CGFloat = 100) {
        self.label       = label
        self.placeholder = placeholder
        self._text       = text
        self.minHeight   = minHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: VTSSpacing.sm) {
            if !label.isEmpty {
                Text(label)
                    .font(.vtsCaption.bold())
                    .foregroundColor(.vtsTxtSecondary)
            }
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.vtsBody)
                        .foregroundColor(.vtsTxtTertiary)
                        .padding(.top, 12)
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .font(.vtsBody)
                    .foregroundColor(.vtsTxtPrimary)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .frame(minHeight: minHeight)
                    .padding(.horizontal, VTSSpacing.md)
                    .padding(.vertical, VTSSpacing.sm)
            }
            .background(
                RoundedRectangle(cornerRadius: VTSRadius.md)
                    .fill(Color.vtsSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: VTSRadius.md)
                            .stroke(isFocused ? Color.vtsBorderFocus : Color.vtsBorder, lineWidth: 1.5)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            // Char count
            Text("\(text.count) ký tự")
                .font(.vtsCaption)
                .foregroundColor(.vtsTxtTertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - ============================================================
//                     VTSSelectField
// MARK: - ============================================================

struct VTSSelectField<T: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var selection: T?
    let options: [T]
    let displayName: (T) -> String
    let displaySubtitle: ((T) -> String)?
    let searchMatcher: ((T, String) -> Bool)?
    let icon: String?
    let errorMessage: String?
    
    @State private var isSheetPresented = false
    @State private var searchText = ""
    
    init(
        label: String = "",
        placeholder: String,
        selection: Binding<T?>,
        options: [T],
        displayName: @escaping (T) -> String = { "\($0)" },
        displaySubtitle: ((T) -> String)? = nil,
        searchMatcher: ((T, String) -> Bool)? = nil,
        icon: String? = nil,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._selection = selection
        self.options = options
        self.displayName = displayName
        self.displaySubtitle = displaySubtitle
        self.searchMatcher = searchMatcher
        self.icon = icon
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: VTSSpacing.sm) {
            // Label
            if !label.isEmpty {
                Text(label)
                    .font(.vtsCaption.bold())
                    .foregroundColor(.vtsTxtSecondary)
            }
            
            // Selector Button
            Button {
                searchText = ""
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
            
            // Error
            if let err = errorMessage {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .font(.vtsCaption)
                    .foregroundColor(.vtsDanger)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
        .sheet(isPresented: $isSheetPresented) {
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
                    let nameMatch = displayName(option).localizedCaseInsensitiveContains(query)
                    let subtitleMatch = displaySubtitle?(option).localizedCaseInsensitiveContains(query) ?? false
                    return nameMatch || subtitleMatch
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
}

extension VTSSelectField {
    // Initializer with Binding<T> (non-optional)
    init(
        label: String = "",
        placeholder: String = "",
        selection: Binding<T>,
        options: [T],
        displayName: @escaping (T) -> String = { "\($0)" },
        displaySubtitle: ((T) -> String)? = nil,
        searchMatcher: ((T, String) -> Bool)? = nil,
        icon: String? = nil,
        errorMessage: String? = nil
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
        self.searchMatcher = searchMatcher
        self.icon = icon
        self.errorMessage = errorMessage
    }
}

extension VTSSelectField where T == String {
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
            searchMatcher: nil,
            icon: icon,
            errorMessage: errorMessage
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
            searchMatcher: nil,
            icon: icon,
            errorMessage: errorMessage
        )
    }
}

// MARK: - Preview
#Preview("Inputs") {
    ZStack {
        LinearGradient.vtsBackground.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 16) {
                VTSSearchBar(text: .constant(""))
                VTSInputField(label: "Số xe", placeholder: "Nhập biển số xe...",
                              text: .constant(""), icon: "truck.box")
                VTSInputField(label: "Email", placeholder: "example@vts.vn",
                              text: .constant("test@vts.vn"), icon: "envelope",
                              errorMessage: "Email không hợp lệ")
                VTSSelectField(label: "Loại xe", placeholder: "Chọn loại xe...",
                               selection: .constant("Xe tải"), options: ["Xe tải", "Xe bán tải", "Xe container"],
                               icon: "car")
                VTSSelectField(label: "Nhóm xe", placeholder: "Chọn nhóm xe...",
                               selection: .constant(nil as String?), options: ["Nhóm A", "Nhóm B", "Nhóm C"],
                               icon: "tag", errorMessage: "Vui lòng chọn nhóm xe")
                VTSDateRangePicker(from: .constant(Date()), to: .constant(Date()))
                VTSTextArea(label: "Ghi chú", text: .constant(""))
            }
            .padding()
        }
    }
    .preferredColorScheme(.light)
}
