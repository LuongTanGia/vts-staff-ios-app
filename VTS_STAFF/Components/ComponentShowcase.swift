
//
//  ComponentShowcase.swift
//  VTS_STAFF
//
//  Màn hình demo toàn bộ component library.
//  ⚠️ Chỉ dùng để xem Preview / Debug, không đưa vào production.
//

import SwiftUI
import SwiftfulRouting

struct ComponentShowcaseView: View {
    @Environment(\.router) private var router
    
    @State private var searchText   = ""
    @State private var selectedTag  = "Tất cả"
    @State private var dateFrom     = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    @State private var dateTo       = Date()
    @State private var textInput    = ""
    @State private var textArea     = ""
    @State private var showToast    = false
    @State private var showConfirm  = false
    @State private var selectedCarType = "Xe tải"
    @State private var selectedVehicleGroup: String? = nil
    @State private var selectedSearchCar: String? = nil
    
    private let tags = ["Tất cả", "Hôm nay", "Tuần này", "Tháng này"]
    
    var body: some View {
        VTSPageContainer {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VTSSpacing.xxxl) {
                    
                    header
                    
                    // MARK: Search
                    sectionBlock("🔍 Search Bar") {
                        VTSSearchBar(text: $searchText)
                    }
                    
                    // MARK: Tags
                    sectionBlock("🏷 Tags") {
                        VTSTagGroup(tags: tags, selected: $selectedTag)
                            .padding(.horizontal, -VTSSpacing.xxl)
                    }
                    
                    // MARK: Stats
                    sectionBlock("📊 Stat Cards") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            VTSStatCard(title: "Phiếu Nhập",   value: "142", icon: "arrow.down.circle.fill",
                                        gradient: .vtsPrimary, trend: .up("8%"))
                            VTSStatCard(title: "Phiếu Xuất",   value: "98",  icon: "arrow.up.circle.fill",
                                        gradient: .vtsSuccess, trend: .down("3%"))
                            VTSStatCard(title: "Xe vận hành", value: "24",  icon: "truck.box.fill",
                                        gradient: .vtsWarning)
                            VTSStatCard(title: "Nhân viên",   value: "67",  icon: "person.2.fill",
                                        gradient: .vtsDanger)
                        }
                    }
                    
                    // MARK: Buttons
                    sectionBlock("🔘 Buttons") {
                        VStack(spacing: VTSSpacing.md) {
                            VTSButton("Lưu phiếu",  icon: "checkmark.circle", style: .primary,  size: .large) { showToast = true }
                            VTSButton("Làm mới",     icon: "arrow.clockwise", style: .secondary)  {}
                            VTSButton("Thêm mới",    icon: "plus",            style: .outline)    {}
                            VTSButton("Xoá phiếu",  icon: "trash",           style: .destructive) { showConfirm = true }
                            VTSButton("Thử nghiệm OCR (Quét chữ)", icon: "doc.text.viewfinder", style: .outline, size: .large) {
                                router.showScreen(.push) { _ in
                                    OCRTestView()
                                }
                            }
                            HStack(spacing: 12) {
                                VTSIconButton("plus",     style: .primary)     {}
                                VTSIconButton("pencil")                         {}
                                VTSIconButton("trash",    style: .destructive) {}
                                VTSIconButton("camera",   style: .secondary)   {}
                            }
                        }
                    }
                    
                    // MARK: Badges
                    sectionBlock("🏅 Badges & Status") {
                        VStack(alignment: .leading, spacing: VTSSpacing.md) {
                            HStack(spacing: 8) {
                                VTSBadge("Hoàn thành", color: .vtsSuccess)
                                VTSBadge("Chờ duyệt",  color: .vtsWarning)
                                VTSBadge("Đã huỷ",     color: .vtsDanger, filled: true)
                                VTSBadge("Mới",        color: .vtsPrimary, filled: true)
                            }
                            HStack(spacing: 8) {
                                VTSPhieuStatusChip(trangThai: "Hoàn thành")
                                VTSPhieuStatusChip(trangThai: "Chờ duyệt")
                                VTSPhieuStatusChip(trangThai: "Đang xử lý")
                                VTSPhieuStatusChip(trangThai: nil)
                            }
                        }
                    }
                    
                    // MARK: Inputs
                    sectionBlock("📝 Inputs") {
                        VStack(spacing: VTSSpacing.md) {
                            VTSInputField(label: "Số xe", placeholder: "Nhập biển số...",
                                          text: $textInput, icon: "truck.box")
                            VTSInputField(label: "Email (error)", placeholder: "email@vts.vn",
                                          text: .constant("abc"), icon: "envelope",
                                          errorMessage: "Email không hợp lệ")
                            VTSSelectField(label: "Loại xe (Binding<T>)", placeholder: "Chọn loại xe...",
                                           selection: $selectedCarType, options: ["Xe tải", "Xe bán tải", "Xe container"],
                                           icon: "car")
                            VTSSelectField(label: "Nhóm xe (Binding<T?>)", placeholder: "Chọn nhóm xe...",
                                           selection: $selectedVehicleGroup, options: ["Nhóm A", "Nhóm B", "Nhóm C"],
                                           icon: "tag")
                            VTSSearchDropdown(label: "Tìm kiếm xe (Search Dropdown)", placeholder: "Chọn hoặc nhập tìm kiếm xe...",
                                              selection: $selectedSearchCar,
                                              options: ["Xe tải 5 tấn", "Xe bán tải Ford", "Xe container 40 feet", "Xe đông lạnh 2.5 tấn", "Xe ben Howo", "Xe cẩu Kato"],
                                              icon: "truck.box")
                            VTSDateRangePicker(from: $dateFrom, to: $dateTo)
                            VTSTextArea(label: "Ghi chú", text: $textArea)
                        }
                    }
                    
                    // MARK: List Items
                    sectionBlock("📋 List Items") {
                        VStack(spacing: VTSSpacing.sm) {
                            VTSListItemRow(
                                title: "PN-2024-001", subtitle: "20/06/2024 · Công ty ABC",
                                trailing: "145.5 tấn", leadingIcon: "arrow.down.circle.fill",
                                accentColor: .vtsPrimary, badge: "Hoàn thành"
                            )
                            VTSListItemRow(
                                title: "PX-2024-045", subtitle: "19/06/2024 · Công ty XYZ",
                                trailing: "98.0 tấn", leadingIcon: "arrow.up.circle.fill",
                                accentColor: .vtsSuccess, badge: "Chờ duyệt"
                            )
                            VTSListItemRow(
                                title: "Toyota 51A-12345", subtitle: "Xe nội · Nhóm A",
                                leadingIcon: "truck.box.fill", accentColor: .vtsWarning
                            )
                        }
                    }
                    
                    // MARK: Info Card
                    sectionBlock("📄 Info Card") {
                        VTSGlassCard {
                            VStack(spacing: 0) {
                                VTSSectionHeader("Thông tin phiếu nhập")
                                VTSDivider().padding(.vertical, VTSSpacing.md)
                                VTSInfoRow(label: "Số phiếu",   value: "PN-2024-001", icon: "doc.text")
                                VTSInfoRow(label: "Ngày",       value: "20/06/2024",  icon: "calendar")
                                VTSInfoRow(label: "Khách hàng", value: "Công ty ABC", icon: "building.2")
                                VTSInfoRow(label: "Hàng hoá",   value: "Than đá",     icon: "shippingbox")
                                VTSInfoRow(label: "Khối lượng", value: "145.5 tấn",   icon: "scalemass")
                                VTSInfoRow(label: "Trạng thái", value: "Hoàn thành",  icon: "checkmark.circle",
                                           valueColor: .vtsSuccess)
                            }
                        }
                    }
                    
                    // MARK: Skeleton
                    sectionBlock("💀 Skeleton Loading") {
                        VStack(spacing: VTSSpacing.sm) {
                            ForEach(0..<3, id: \.self) { _ in VTSSkeletonRow() }
                        }
                    }
                    
                    // MARK: Empty & Error
                    sectionBlock("🕳 Empty & Error States") {
                        VTSGlassCard(padding: 0, cornerRadius: VTSRadius.xl) {
                            VTSEmptyState(
                                icon: "doc.text.magnifyingglass",
                                title: "Không có phiếu",
                                subtitle: "Không tìm thấy phiếu nào trong khoảng thời gian này",
                                actionTitle: "Tải lại"
                            ) {}
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(VTSSpacing.xxl)
            }
        }
        .vtsToast(isPresented: $showToast, message: "Lưu thành công!", type: .success)
        .vtsConfirm(
            isPresented: $showConfirm,
            title: "Xoá phiếu",
            message: "Bạn có chắc muốn xoá phiếu này? Hành động không thể hoàn tác.",
            confirmLabel: "Xoá"
        ) { print("Confirmed delete") }
    }
    
    // MARK: - Helpers
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Component Library")
                .font(.vtsLargeTitle)
                .foregroundColor(.vtsTxtPrimary)
            Text("VTS Staff Design System")
                .font(.vtsCallout)
                .foregroundColor(.vtsTxtSecondary)
        }
    }
    
    @ViewBuilder
    private func sectionBlock<Content: View>(_ title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: VTSSpacing.md) {
            Text(title)
                .font(.vtsCaption.bold())
                .foregroundColor(.vtsTxtTertiary)
                .textCase(.uppercase)
                .tracking(1)
            content()
        }
    }
}

#Preview {
    RouterView { _ in
        ComponentShowcaseView()
    }
}
