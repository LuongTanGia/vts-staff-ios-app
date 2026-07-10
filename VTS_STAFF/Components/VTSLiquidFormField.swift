
//
//  VTSLiquidFormField.swift
//  VTS_STAFF
//
//  Các input field dùng trên form – Liquid Glass / Material Outlined style
//  Xuất hiện trong: Thêm Hàng hoá, Thêm Khách hàng, Thông tin Nhân viên, Form Phiếu
//
//  Components:
//    • VTSLiquidTextField       – text input có floating label
//    • VTSLiquidReadonlyField   – ô readonly (xám) cho mã, ngày tự sinh
//    • VTSLiquidPickerField     – dropdown picker với floating label
//    • VTSLiquidGenderToggle    – chọn Nam / Nữ
//    • VTSLiquidDateTimeField   – ngày giờ (hiện DatePicker dạng sheet)
//    • VTSLiquidSaveButton      – nút Lưu xanh lá góc phải (giống Android)
//    • VTSLiquidFormCard        – wrapper card toàn form
//

import SwiftUI

// MARK: - ============================================================
//              VTSLiquidTextField  (floating label)
// MARK: - ============================================================

struct VTSLiquidTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let isReadOnly: Bool
    
    @FocusState private var focused: Bool
    @State private var didCopy = false
    
    init(
        label: String = "",
        text: Binding<String>,
        placeholder: String = "",
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        isReadOnly: Bool = false
    ) {
        self.label       = label
        self._text       = text
        self.placeholder = placeholder
        self.isSecure    = isSecure
        self.keyboardType = keyboardType
        self.isReadOnly  = isReadOnly
    }
    
    var shouldFloat: Bool { focused || !text.isEmpty }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    isReadOnly
                    ? AnyShapeStyle(Color.primary.opacity(0.07))
                    : AnyShapeStyle(.regularMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            focused ? Color.vtsPrimary.opacity(0.8) : Color.primary.opacity(0.15),
                            lineWidth: focused ? 1.5 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.15), value: focused)
            
            // Floating label
            if !label.isEmpty {
                Text(label)
                    .font(shouldFloat
                          ? .system(size: 11, weight: .medium)
                          : .system(size: 15))
                    .foregroundStyle(shouldFloat
                                     ? (focused ? Color.vtsPrimary : Color.secondary)
                                     : Color.secondary)
                    .offset(y: shouldFloat ? 6 : 16)
                    .padding(.horizontal, 14)
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: shouldFloat)
            }
            
            // Input and Copy Button
            HStack(spacing: 8) {
                Group {
                    if isSecure {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                            .keyboardType(keyboardType)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }
                .font(.system(size: 15))
                .foregroundStyle(isReadOnly ? .secondary : .primary)
                .focused($focused)
                .disabled(isReadOnly)
                
                if isReadOnly && !text.isEmpty {
                    Button {
                        UIPasteboard.general.string = text
                        withAnimation {
                            didCopy = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            didCopy = false
                        }
                    } label: {
                        Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundStyle(didCopy ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, label.isEmpty ? 14 : 24)
            .padding(.bottom, 10)
        }
        .frame(minHeight: label.isEmpty ? 48 : 58)
    }
}

// MARK: - ============================================================
//            VTSLiquidReadonlyField  (ô xám – mã, ngày auto-gen)
// MARK: - ============================================================

struct VTSLiquidReadonlyField: View {
    let value: String
    let caption: String?          // italic label bên dưới (giống Android)
    @State private var didCopy = false
    
    init(_ value: String, caption: String? = nil) {
        self.value   = value
        self.caption = caption
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(value.isEmpty ? "—" : value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if !value.isEmpty {
                    Button {
                        UIPasteboard.general.string = value
                        withAnimation {
                            didCopy = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            didCopy = false
                        }
                    } label: {
                        Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12))
                            .foregroundStyle(didCopy ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
            )
            
            if let caption {
                Text(caption)
                    .font(.system(size: 12))
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - ============================================================
//            VTSLiquidPickerField  (dropdown với floating label)
// MARK: - ============================================================

struct VTSLiquidPickerField<T: Hashable>: View {
    let label: String
    @Binding var selection: T
    let options: [T]
    let displayName: (T) -> String
    let displaySubtitle: ((T) -> String)?
    let searchMatcher: ((T, String) -> Bool)?
    
    @State private var isSheetPresented = false
    @State private var searchText = ""
    
    init(
        label: String,
        selection: Binding<T>,
        options: [T],
        displayName: @escaping (T) -> String,
        displaySubtitle: ((T) -> String)? = nil,
        searchMatcher: ((T, String) -> Bool)? = nil
    ) {
        self.label           = label
        self._selection      = selection
        self.options         = options
        self.displayName     = displayName
        self.displaySubtitle = displaySubtitle
        self.searchMatcher   = searchMatcher
    }
    
    var body: some View {
        Button {
            searchText = ""
            isSheetPresented = true
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    if !label.isEmpty {
                        Text(label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text(displayName(selection))
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minHeight: label.isEmpty ? 48 : 58)
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

// MARK: - ============================================================
//            VTSLiquidGenderToggle  (Nam / Nữ)
// MARK: - ============================================================

struct VTSLiquidGenderToggle: View {
    @Binding var isFemale: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            genderButton("Nam", selected: !isFemale) { isFemale = false }
            genderButton("Nữ",  selected: isFemale)  { isFemale = true  }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                )
        )
    
    }
    
    @ViewBuilder
    private func genderButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selected ? Color.vtsPrimary : Color.clear)
                        .padding(3)
                )
        }
        .buttonStyle(VTSPressButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: selected)
    }
}

// MARK: - ============================================================
//         VTSLiquidDateTimeField  (ngày giờ – mở DatePicker sheet)
// MARK: - ============================================================

struct VTSLiquidDateTimeField: View {
    let label: String
    @Binding var date: Date
    let displayStyle: DisplayStyle
    @State private var showPicker = false
    
    enum DisplayStyle {
        case dateOnly       // "16/06/2026"
        case dateTime       // "16/06/2026 08:22:01"
    }
    
    var body: some View {
        Button { showPicker = true } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    )
                
                if !label.isEmpty {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .offset(y: 6)
                        .padding(.horizontal, 14)
                }
                
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.vtsPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.top, label.isEmpty ? 14 : 24)
                .padding(.bottom, 10)
            }
            .frame(minHeight: label.isEmpty ? 48 : 58)
        }
        .buttonStyle(VTSPressButtonStyle())
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                DatePicker(
                    label,
                    selection: $date,
                    displayedComponents: displayStyle == .dateOnly ? [.date] : [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(.vtsPrimary)
                .padding()
                .navigationTitle(label)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Xong") { showPicker = false }
                            .foregroundStyle(Color.vtsPrimary)
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(24)
        }
    }
    
    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "vi_VN")
        switch displayStyle {
        case .dateOnly: fmt.dateFormat = "dd/MM/yyyy"
        case .dateTime: fmt.dateFormat = "dd/MM/yyyy HH:mm:ss"
        }
        return fmt.string(from: date)
    }
}

// MARK: - ============================================================
//         VTSLiquidSaveButton  (nút Lưu xanh lá – góc phải như Android)
// MARK: - ============================================================

struct VTSLiquidSaveButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    init(_ title: String = "Lưu", isLoading: Bool = false, action: @escaping () -> Void) {
        self.title     = title
        self.isLoading = isLoading
        self.action    = action
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView().progressViewStyle(.circular).tint(.white).scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "2D6A4F"), Color(hex: "40916C")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color(hex: "2D6A4F").opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .disabled(isLoading)
            .buttonStyle(VTSPressButtonStyle())
        }
    }
}

// MARK: - ============================================================
//         VTSLiquidFormCard  (wrapper card toàn bộ form)
// MARK: - ============================================================

struct VTSLiquidFormCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 14) {
            content()
        }
        .padding(16)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview("FormFields") {
    ScrollView {
        VTSLiquidFormCard {
            VTSLiquidReadonlyField("25120002", caption: "Mã nhân viên")
            
            HStack(spacing: 10) {
                VTSLiquidTextField(label: "Họ và tên đệm", text: .constant("Nguyễn Thị Thanh"))
                VTSLiquidTextField(label: "Tên", text: .constant("Vân"))
                    .frame(width: 100)
            }
            
            HStack(spacing: 10) {
                VTSLiquidDateTimeField(label: "Ngày sinh", date: .constant(Date()), displayStyle: .dateOnly)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Giới tính").font(.caption).foregroundStyle(.secondary)
                    VTSLiquidGenderToggle(isFemale: .constant(true))
                }
            }
            
            VTSLiquidTextField(label: "Số, đường", text: .constant("Ấp Long An,Long Hòa"))
            
            VTSLiquidPickerField(
                label: "Phường, Xã",
                selection: .constant("Phường Bến Tre"),
                options: ["Phường Bến Tre", "Phường Vũng Tàu"],
                displayName: { $0 }
            )
            
            VTSLiquidTextField(label: "Email", text: .constant("test@gmail.com"), keyboardType: .emailAddress)
            
            VTSLiquidSaveButton { }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
