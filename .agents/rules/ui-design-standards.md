# Quy Chuẩn Giao Diện & Mã Nguồn (VTS iSaleSta)

Bộ quy ước này áp dụng cho toàn bộ dự án iOS VTS_iSaleSta và được kiểm tra tự động qua **SwiftLint** (`.swiftlint.yml`) tích hợp trong Xcode Build Phase.

---

## 1. Tổ Chức `Content` Trên Cùng Của Mỗi View
- Mọi chuỗi ký tự hiển thị (tiêu đề, nhãn metric, nút bấm, placeholder, thông báo lỗi, tên icon...) **bắt buộc** gom vào một `enum Content` (hoặc `private enum Content`) đặt **ngay trên đầu** struct View.
- Tuyệt đối không hardcode text rải rác bên trong `body` của View.

```swift
struct MyFeatureView: View {
    // MARK: - View Content
    private enum Content {
        static let title = "Quản lý Bán hàng"
        static let totalLabel = "Tổng doanh thu"
        static let emptyMessage = "Chưa có dữ liệu giao dịch"
        static let iconCalendar = "calendar"
        static let btnExport = "Xuất báo cáo"
    }

    var body: some View {
        Text(Content.title)
    }
}
```

---

## 2. Màu Sắc (Color Tokens)
- **Cấm**: Dùng mã màu hex tùy ý `Color(hex: ...)`, `Color(red: ...)`, hoặc màu mặc định SwiftUI `Color.blue`, `Color.red`...
- **Quy chuẩn**: Sử dụng token từ [VTSDesignSystem.swift](file:///Users/viettas/VTS_APP_IOS/VTS_iSaleSta/VTS_iSaleSta/Shared/DesignSystem/VTSDesignSystem.swift):
  - `.vtsPrimary`: Màu chủ đạo / thương hiệu
  - `.vtsSecondary`: Màu phụ trợ
  - `.vtsSuccess`: Trạng thái thành công / đã hoàn tất
  - `.vtsWarning`: Cảnh báo / đang xử lý
  - `.vtsDanger`: Thất bại / hủy bỏ / nợ xấu
  - `.vtsInfo`: Thông tin bổ sung
  - `.vtsAccent`: Điểm nhấn nổi bật
  - `.vtsBg`, `.vtsSurface`: Nền ứng dụng & thẻ
  - `.vtsTxtPrimary`, `.vtsTxtSecondary`, `.vtsTxtMuted`: Màu chữ theo cấp bậc
  - `.vtsBorder`: Viền chuẩn

---

## 3. Typography & Font Sizes
- **Cấm**: Dùng `.font(.system(size: 16, weight: ...))` với số cỡ cứng.
- **Quy chuẩn**: Dùng Typography tokens `Font.vts...`:
  - `Font.vtsLargeTitle` (28pt bold)
  - `Font.vtsTitle` (22pt bold)
  - `Font.vtsTitle2` (18pt semibold)
  - `Font.vtsHeadline` (16pt semibold)
  - `Font.vtsBody` (14pt regular)
  - `Font.vtsCallout` (13pt medium)
  - `Font.vtsCaption` (12pt regular)
  - `Font.vtsTableHeader` (13pt bold)
  - `Font.vtsTableContent` (13pt regular)
  - `Font.vtsTableFooter` (13pt bold)

---

## 4. Spacing & Corner Radius
- **Cấm**: Dùng số cứng tùy tiện như `.cornerRadius(10)` hoặc padding số lẻ.
- **Quy chuẩn**:
  - **Spacing**: `VTSSpacing.xxs (2)`, `xs (4)`, `sm (8)`, `md (12)`, `lg (16)`, `xl (20)`, `xxl (24)`, `hero (32)`.
  - **Corner Radius**: `VTSRadius.sm (8)`, `md (12)`, `lg (16)`, `xl (20)`, `xxl (24)`.

---

## 5. Định Dạng Số & Tiền Tệ
- **Cấm**: Ghép chuỗi `+ " đ"` hoặc `+ "₫"` thủ công.
- **Cấm**: Khởi tạo `NumberFormatter()` lặp lại trong View.
- **Quy chuẩn**: Sử dụng `VTSFormatter`:
  - `VTSFormatter.currency(1500000)` -> `1.500.000 đ`
  - `VTSFormatter.number(1250)` -> `1.250`
  - `VTSFormatter.count(8)` -> `08`

---

## 6. Thành Phần Metric Box Đồng Bộ
- Khi hiển thị các ô chỉ số KPI / thống kê, sử dụng `VTSMetricBox`:
```swift
VTSMetricBox(
    title: Content.metricTitle,
    value: VTSFormatter.currency(totalAmount),
    color: .vtsPrimary
)
```

---

## 7. Kiểm Tra Tự Động (SwiftLint Linter)
Bộ kiểm tra chạy tự động trong:
1. **Xcode Build Phase**: Hiển thị cảnh báo trực tiếp trên từng dòng code vi phạm.
2. **Terminal**: Chạy lệnh:
   ```bash
   swiftlint lint --config .swiftlint.yml
   ```
