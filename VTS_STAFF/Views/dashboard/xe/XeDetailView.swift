//
//  XeDetailView.swift
//  VTS_STAFF
//
//  Created by viettas on 26/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct XeDetailView: View {
    @Environment(\.router) private var router
    @StateObject private var viewModel: XeDetailViewModel
    
    @State private var isEditMode: Bool = false
    private let initialEditMode: Bool
    
    @State private var ma: String = ""
    @State private var ten: String = ""
    @State private var selectedLoai: String = ""
    @State private var selectedNhom: String = ""
    @State private var selectedTaiXe: String = ""
    @State private var ghiChu: String = ""
    @State private var isSaving: Bool = false
    
    @State private var maError: String? = nil
    @State private var tenError: String? = nil
    @State private var loaiError: String? = nil
    @State private var nhomError: String? = nil
    @State private var taiXeError: String? = nil
    
    private var hasEditPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_XE")?.edit == true
    }
    
    private var hasAddPermission: Bool {
        AuthManager.shared.getPermission(for: "VTSSTAFF_DANHMUC_XE")?.add == true
    }
    
    init(maXe: String?, isEditMode: Bool = false) {
        self.initialEditMode = isEditMode
        self._isEditMode = State(initialValue: isEditMode || maXe == nil || maXe?.isEmpty == true)
        _viewModel = StateObject(wrappedValue: XeDetailViewModel(maXe: maXe))
    }
    
    var body: some View {
        VTSPageContainer(hasGradient: true) {
            VTSAsyncContent(
                state: viewModel.state,
                emptyTitle: "Không thể tải dữ liệu",
                emptySubtitle: "Vui lòng kiểm tra kết nối mạng và thử lại.",
                emptyIcon: "exclamationmark.triangle.fill",
                retry: {
                    Task {
                        await viewModel.loadData()
                    }
                }
            ) { details in
                VStack(spacing: 0) {
                    // MARK: - Static Pinned Header Card
                    profileHeaderCard()
                        .background(Color.vtsPrimary)
                    
                    // MARK: - Scrollable Details Area
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            vehicleInfoCard(details: details)
                        }
                        .padding(.horizontal, VTSSpacing.sm)
                        .padding(.vertical, 16)
                    }
                    
                    VTSCompanyFooter()
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    if let details = details {
                        populateFields(with: details)
                    }
                }
                .onChange(of: details?.ma) { _, _ in
                    if let details = details {
                        populateFields(with: details)
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: viewModel.isNew ? "Thêm xe mới" : (isEditMode ? "Chỉnh sửa xe nhà" : "Thông tin xe nhà"),
            isWhiteText: true,
            leading: {},
            trailing: {
                if isEditMode {
                    HStack(spacing: 16) {
                        if !viewModel.isNew {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isEditMode = false
                                }
                                if case .success(let details) = viewModel.state, let details = details {
                                    populateFields(with: details)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    LucideIcon(.x, size: 18)
                                    Text("Huỷ")
                                        .font(.vtsHeadline)
                                }
                                .foregroundColor(.red)
                            }
                            .disabled(isSaving)
                        }
                        
                        Button {
                            Task {
                                await saveVehicle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.primary)
                                } else {
                                    LucideIcon(.check, size: 18)
                                    Text("Lưu")
                                        .font(.vtsHeadline)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                        .disabled(isSaving)
                    }
                } else {
                    if hasEditPermission {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isEditMode = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                LucideIcon(.pencil, size: 18)
                                Text("Sửa")
                                    .font(.vtsHeadline)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            },
            primaryAction: { EmptyView() }
        )
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: ma) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                maError = nil
            }
        }
        .onChange(of: ten) { _, newValue in
            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                tenError = nil
            }
        }
        .onChange(of: selectedLoai) { _, newValue in
            if !newValue.isEmpty {
                loaiError = nil
            }
        }
        .onChange(of: selectedNhom) { _, newValue in
            if !newValue.isEmpty {
                nhomError = nil
            }
        }
        .onChange(of: selectedTaiXe) { _, newValue in
            if !newValue.isEmpty {
                taiXeError = nil
            }
        }
        .onAppear {
            if viewModel.isNew {
                if !hasAddPermission {
                    isEditMode = false
                }
            } else {
                if isEditMode && !hasEditPermission {
                    isEditMode = false
                }
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func profileHeaderCard() -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                
                LucideIcon(.truck, size: 24, color: Color(hex: "00497C"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ma.isEmpty ? (viewModel.isNew ? "Tạo mới phương tiện" : "Phương tiện") : ma)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(ten.isEmpty ? "—" : ten)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                let txTen = selectedTaiXe.isEmpty ? (selectedLoai.isEmpty ? "—" : (viewModel.loaiXes.first(where: { $0.ma == selectedLoai })?.ten ?? selectedLoai)) : (viewModel.taiXes.first(where: { $0.ma == selectedTaiXe })?.ten ?? selectedTaiXe)
                Text(txTen)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private func vehicleInfoCard(details: TXe_ThongTin?) -> some View {
        VTSLiquidFormCard {
            VStack(alignment: .leading, spacing: 14) {
                VTSLiquidTextField(
                    label: "Biển số",
                    text: $ma,
                    isReadOnly: !viewModel.isNew || !isEditMode,
                    errorMessage: maError
                )
                
                VTSLiquidTextField(
                    label: "Tên gợi nhớ của xe",
                    text: $ten,
                    isReadOnly: !isEditMode,
                    errorMessage: tenError
                )
                
                VTSLiquidPickerField(
                    label: "Loại xe",
                    selection: $selectedLoai,
                    options: [""] + viewModel.loaiXes.map { $0.ma },
                    displayName: { code in
                        if code.isEmpty { return "Không chọn" }
                        return viewModel.loaiXes.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: loaiError
                )
                .disabled(!isEditMode)
                
                VTSLiquidPickerField(
                    label: "Nhóm xe",
                    selection: $selectedNhom,
                    options: [""] + viewModel.nhomXes.map { $0.ma },
                    displayName: { code in
                        if code.isEmpty { return "Không chọn" }
                        return viewModel.nhomXes.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: nhomError
                )
                .disabled(!isEditMode)
                
                VTSLiquidPickerField(
                    label: "Tài xế cố định",
                    selection: $selectedTaiXe,
                    options: [""] + viewModel.taiXes.map { $0.ma },
                    displayName: { code in
                        if code.isEmpty { return "Không chọn" }
                        return viewModel.taiXes.first(where: { $0.ma == code })?.ten ?? code
                    },
                    errorMessage: taiXeError
                )
                .disabled(!isEditMode)
                
                VTSLiquidTextField(
                    label: "Ghi chú",
                    text: $ghiChu,
                    placeholder: "",
                    isReadOnly: !isEditMode
                )
            }
        }
    }
    
    @ViewBuilder
    private func infoRow(label: String, value: String, icon: String) -> some View {
        Button {
            if !value.isEmpty {
                UIPasteboard.general.string = value
                ErrorManager.shared.showSuccess("Đã sao chép \(label.lowercased())")
            }
        } label: {
            HStack(spacing: 12) {
                LucideIcon(icon, size: 20, color: .vtsPrimary)
                    .foregroundColor(Color.vtsPrimary)
                    .frame(width: 28, height: 28)
                    .background(Color.vtsPrimary.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.vtsCaption)
                        .foregroundColor(.vtsTxtSecondary)
                    
                    Text(value.isEmpty ? "Chưa thiết lập" : value)
                        .font(.vtsBody.bold())
                        .foregroundColor(value.isEmpty ? .vtsTxtTertiary : .vtsTxtPrimary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if !value.isEmpty {
                    LucideIcon(.copy, size: 14, color: .vtsTxtTertiary)
                        .font(.system(size: 11))
                        .foregroundColor(.vtsTxtTertiary)
                        .padding(4)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func getInitials(name: String) -> String {
        let components = name.components(separatedBy: " ")
        let filtered = components.filter { !$0.isEmpty }
        if filtered.count >= 2 {
            let first = String(filtered[filtered.count - 2].prefix(1))
            let last = String(filtered[filtered.count - 1].prefix(1))
            return (first + last).uppercased()
        } else if let single = filtered.first {
            return String(single.prefix(2)).uppercased()
        }
        return "XE"
    }
    
    private func populateFields(with details: TXe_ThongTin) {
        self.ma = details.ma
        self.ten = details.ten
        self.selectedLoai = details.loai
        self.selectedNhom = details.nhom ?? ""
        self.selectedTaiXe = details.taiXe
        self.ghiChu = details.ghiChu ?? ""
    }
    
    private func saveVehicle() async {
        var hasError = false
        
        if ma.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            maError = "Vui lòng nhập biển số xe"
            hasError = true
        } else {
            maError = nil
        }
        
        if ten.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tenError = "Vui lòng nhập tên xe"
            hasError = true
        } else {
            tenError = nil
        }
        
        if selectedLoai.isEmpty {
            loaiError = "Vui lòng chọn loại xe"
            hasError = true
        } else {
            loaiError = nil
        }
        
        if selectedNhom.isEmpty {
            nhomError = "Vui lòng chọn nhóm xe"
            hasError = true
        } else {
            nhomError = nil
        }
        
        if selectedTaiXe.isEmpty {
            taiXeError = "Vui lòng chọn tài xế"
            hasError = true
        } else {
            taiXeError = nil
        }
        
        if hasError {
            router.showAlert(.alert, title: "Lỗi nhập liệu", subtitle: "Vui lòng hoàn thiện các trường thông tin bắt buộc.") {
                Button("OK") {}
            }
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        let data = DataIn_List_Xe(
            ma: ma,
            ten: ten.isEmpty ? nil : ten,
            loai: selectedLoai.isEmpty ? nil : selectedLoai,
            nhom: selectedNhom.isEmpty ? nil : selectedNhom,
            taiXe: selectedTaiXe.isEmpty ? nil : selectedTaiXe,
            ghiChu: ghiChu.isEmpty ? nil : ghiChu
        )
        
        do {
            if viewModel.isNew {
                let _ = try await XeService.shared.them(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Thêm phương tiện mới thành công.") {
                    Button("OK") {
                        router.dismissScreen()
                    }
                }
            } else {
                let _ = try await XeService.shared.sua(data)
                router.showAlert(.alert, title: "Thành công", subtitle: "Cập nhật thông tin phương tiện thành công.") {
                    Button("OK") {
                        isEditMode = false
                        Task {
                            await viewModel.loadData()
                        }
                    }
                }
            }
        } catch {
            router.showAlert(.alert, title: "Lỗi", subtitle: error.localizedDescription) {
                Button("OK") {}
            }
        }
    }
}

#Preview {
    let _ = AuthManager.shared.saveTokens(access: "mock_jwt_token_for_vts_staff_bypass", refresh: "mock_refresh")
    return RouterView { _ in
        XeDetailView(maXe: nil)
    }
}
