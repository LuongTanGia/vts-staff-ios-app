//
//  LucideIconName.swift
//  VTS_STAFF
//
//  Created by Antigravity on 03/09/2026.
//  Bộ định danh Lucide Icons (https://lucide.dev/icons/) dùng chung cho iOS & Android.
//

import Foundation

public enum LucideIconName: String, CaseIterable, Identifiable, Sendable {
    // MARK: - ERP & Business
    case package            = "package"               // Hàng hoá
    case building2          = "building_2"            // Khách hàng / Doanh nghiệp
    case users              = "users"                 // Nhân viên / Đội ngũ
    case user               = "user"                  // Người dùng / Cá nhân
    case truck              = "truck"                 // Xe nhà / Phương tiện
    case cog                = "cog"                   // Chuyến hàng gia công / Bánh răng
    case wrench             = "wrench"                // Dụng cụ sửa chữa
    case arrowDownToDot     = "arrow_down_to_dot"     // Chuyến hàng nhận / Nhập
    case arrowUpFromDot     = "arrow_up_from_dot"     // Chuyến hàng giao / Xuất
    case arrowDownLeft      = "arrow_down_left"       // Mũi tên nhập
    case arrowUpRight       = "arrow_up_right"         // Mũi tên xuất
    case barChart3          = "bar_chart_3"           // Thống kê / Truy vấn
    case layoutDashboard    = "layout_dashboard"      // Bảng điều khiển
    case layoutGrid         = "layout_grid"           // Menu dữ liệu
    case home               = "home"                  // Trang chủ
    case bell               = "bell"                  // Thông báo
    case bellDot            = "bell_dot"              // Thông báo mới
    case info               = "info"                  // Thông tin
    case settings           = "settings"              // Cài đặt
    case logOut             = "log_out"               // Đăng xuất
    
    // MARK: - Actions
    case search             = "search"                // Tìm kiếm
    case plus               = "plus"                  // Thêm mới
    case pencil             = "pencil"                // Chỉnh sửa
    case trash2             = "trash_2"               // Xoá
    case eye                = "eye"                   // Xem chi tiết
    case eyeOff             = "eye_off"               // Ẩn chi tiết
    case x                  = "x"                     // Đóng / Huỷ
    case xCircle            = "x_circle"              // Huỷ tròn
    case check              = "check"                 // Chọn / Lưu
    case checkCircle2       = "check_circle_2"        // Hoàn tất tròn
    case copy               = "copy"                  // Sao chép
    case refreshCw          = "refresh_cw"            // Làm mới
    case moreHorizontal     = "more_horizontal"       // Tuỳ chọn ngang
    case moreVertical       = "more_vertical"         // Tuỳ chọn dọc
    case chevronRight       = "chevron_right"         // Mũi tên phải
    case chevronLeft        = "chevron_left"          // Mũi tên trái
    case chevronDown        = "chevron_down"          // Mũi tên xuống
    case chevronUp          = "chevron_up"            // Mũi tên lên
    case arrowUp            = "arrow_up"              // Sắp xếp tăng
    case arrowDown          = "arrow_down"            // Sắp xếp giảm
    case filter             = "filter"                // Bộ lọc
    
    // MARK: - Media & Device
    case camera             = "camera"                // Máy ảnh
    case image              = "image"                 // Thư viện ảnh
    case calendar           = "calendar"              // Lịch
    case clock              = "clock"                 // Giờ
    case scanFace           = "scan_face"             // Face ID
    case qrCode             = "qr_code"               // QR Code
    case scanBarcode        = "scan_barcode"          // Mã vạch
    case lock               = "lock"                  // Khoá
    case unlock             = "unlock"                // Mở khoá
    case phone              = "phone"                 // Điện thoại
    case mail               = "mail"                  // Email
    case mapPin             = "map_pin"               // Địa chỉ
    case alertTriangle      = "alert_triangle"        // Cảnh báo
    case alertCircle        = "alert_circle"          // Lỗi
    case crop               = "crop"                  // Cắt ảnh
    
    public var id: String { self.rawValue }
    
    /// Tên asset catalog trong Assets.xcassets (VD: "lucide_package")
    public var assetName: String {
        return "lucide_\(self.rawValue)"
    }
    
    /// Ánh xạ thông minh từ chuỗi SF Symbol hoặc tên chức năng sang LucideIconName
    public static func from(string: String) -> LucideIconName {
        let clean = string.lowercased().replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: "lucide_", with: "")
        
        if let exact = LucideIconName(rawValue: clean) { return exact }
        
        let lower = string.lowercased()
        
        // Modules & Menu
        if lower.contains("shippingbox") || lower.contains("cube") || lower.contains("package") || lower.contains("hanghoa") || lower.contains("hang_hoa") {
            return .package
        }
        if lower.contains("building") || lower.contains("briefcase") || lower.contains("khachhang") || lower.contains("khach_hang") {
            return .building2
        }
        if lower.contains("person.2") || lower.contains("users") || lower.contains("nhanvien") || lower.contains("nhan_vien") {
            return .users
        }
        if lower.contains("person") || lower.contains("user") {
            return .user
        }
        if lower.contains("truck") || lower.contains("car") || lower.contains("xe") {
            return .truck
        }
        if lower.contains("gearshape.2") || lower.contains("gearshape") || lower.contains("cog") || lower.contains("wrench") || lower.contains("giacong") || lower.contains("gia_cong") {
            return .cog
        }
        if lower.contains("arrow.down") || lower.contains("arrow_down") || lower.contains("nhap") {
            return .arrowDownToDot
        }
        if lower.contains("arrow.up") || lower.contains("arrow_up") || lower.contains("xuat") {
            return .arrowUpFromDot
        }
        if lower.contains("chart") || lower.contains("truyvan") || lower.contains("truy_van") {
            return .barChart3
        }
        if lower.contains("house") || lower.contains("home") || lower.contains("trangchu") {
            return .home
        }
        if lower.contains("grid") || lower.contains("dashboard") || lower.contains("dulieu") {
            return .layoutGrid
        }
        if lower.contains("bell") || lower.contains("thongbao") {
            return lower.contains("dot") || lower.contains("badge") ? .bellDot : .bell
        }
        if lower.contains("info") || lower.contains("thongtin") {
            return .info
        }
        if lower.contains("gear") || lower.contains("settings") || lower.contains("caidat") {
            return .settings
        }
        if lower.contains("logout") || lower.contains("dangxuat") || lower.contains("arrow.right.square") {
            return .logOut
        }
        
        // Actions
        if lower.contains("magnifyingglass") || lower.contains("search") || lower.contains("tim") {
            return .search
        }
        if lower.contains("plus") || lower.contains("add") || lower.contains("them") {
            return .plus
        }
        if lower.contains("pencil") || lower.contains("edit") || lower.contains("sua") {
            return .pencil
        }
        if lower.contains("trash") || lower.contains("delete") || lower.contains("xoa") {
            return .trash2
        }
        if lower.contains("eye.slash") || lower.contains("eye_off") {
            return .eyeOff
        }
        if lower.contains("eye") || lower.contains("xem") {
            return .eye
        }
        if lower.contains("checkmark") || lower.contains("check") || lower.contains("duyet") || lower.contains("luu") {
            return lower.contains("circle") ? .checkCircle2 : .check
        }
        if lower.contains("xmark") || lower.contains("close") || lower.contains("cancel") || lower.contains("huy") {
            return lower.contains("circle") ? .xCircle : .x
        }
        if lower.contains("doc.on.doc") || lower.contains("copy") || lower.contains("saochep") {
            return .copy
        }
        if lower.contains("chevron.right") || lower.contains("chevron_right") {
            return .chevronRight
        }
        if lower.contains("chevron.left") || lower.contains("chevron_left") {
            return .chevronLeft
        }
        if lower.contains("chevron.down") || lower.contains("chevron_down") {
            return .chevronDown
        }
        if lower.contains("chevron.up") || lower.contains("chevron_up") {
            return .chevronUp
        }
        if lower.contains("camera") {
            return .camera
        }
        if lower.contains("photo") || lower.contains("image") || lower.contains("gallery") {
            return .image
        }
        if lower.contains("calendar") || lower.contains("ngay") {
            return .calendar
        }
        if lower.contains("clock") || lower.contains("time") || lower.contains("gio") {
            return .clock
        }
        if lower.contains("faceid") || lower.contains("face") {
            return .scanFace
        }
        if lower.contains("qr") {
            return .qrCode
        }
        if lower.contains("barcode") {
            return .scanBarcode
        }
        if lower.contains("lock.open") || lower.contains("unlock") {
            return .unlock
        }
        if lower.contains("lock") {
            return .lock
        }
        if lower.contains("phone") {
            return .phone
        }
        if lower.contains("envelope") || lower.contains("mail") {
            return .mail
        }
        if lower.contains("pin") || lower.contains("map") || lower.contains("location") {
            return .mapPin
        }
        if lower.contains("triangle") || lower.contains("warn") {
            return .alertTriangle
        }
        if lower.contains("circle") && (lower.contains("alert") || lower.contains("exclamation")) {
            return .alertCircle
        }
        if lower.contains("crop") {
            return .crop
        }
        if lower.contains("rotate") || lower.contains("refresh") || lower.contains("circlepath") || lower.contains("backward") {
            return .refreshCw
        }
        
        return .info
    }
}
