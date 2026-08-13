# TÀI LIỆU HƯỚNG DẪN KIẾN TRÚC & MÃ NGUỒN VTS STAFF (IOS)

Tài liệu này cung cấp cái nhìn tổng quan toàn diện và chi tiết về cấu trúc mã nguồn, kiến trúc phần mềm, hệ thống giao diện (Design System), các thành phần tái sử dụng (Components), xử lý nghiệp vụ (Logic) và quy trình mở rộng cho dự án **VTS Staff iOS App**.

---

## 1. TỔNG QUAN DỰ ÁN (PROJECT OVERVIEW)

- **Tên dự án**: VTS Staff (SwiftUI iOS Application)
- **Mục đích**: Hệ thống ứng dụng di động dành cho nhân viên vận hành, hỗ trợ quản lý phiếu vận chuyển (Phiếu Nhập, Phiếu Xuất, Phiếu Gia Công), truy vấn chuyến xe, kiểm tra danh mục dữ liệu (Hàng hoá, Khách hàng, Nhân viên, Xe), và nhận dạng tài liệu OCR.
- **Nền tảng & Yêu cầu**:
  - **Ngôn ngữ**: Swift 5.9+
  - **Frameworks chính**: SwiftUI, Combine, Vision (Apple OCR Framework), PhotosUI, AVFoundation (Camera API), LocalAuthentication (FaceID / TouchID).
  - **Kiến trúc**: **MVVM (Model-View-ViewModel)** kết hợp Service-Oriented Architecture (SOA), Singleton State Managers (`AuthManager`, `ErrorManager`), và Custom Navigation Router.

---

## 2. CẤU TRÚC THƯ MỤC VÀ TỔ CHỨC MÃ NGUỒN

Dự án được phân chia thành các thư mục rõ ràng theo đúng trách nhiệm (Separation of Concerns):

```text
VTS_STAFF/
├── VTS_STAFFApp.swift            # App Entry Point (Khởi chạy ứng dụng & Root View)
├── ContentView.swift             # Root Container (Điều hướng giữa Login / TabView / Splash)
│
├── Networking/                   # TẦNG KẾT NỐI MẠNG VÀ QUẢN LÝ DỮ LIỆU TỪ SERVER
│   ├── AppConfig.swift           # Cấu hình URL Base, API Endpoints, Timeouts
│   ├── NetworkManager.swift      # Async/Await HTTP Client gửi và nhận request JSON
│   ├── NetworkError.swift        # Mã lỗi API và Enum định nghĩa các lỗi kết nối
│   ├── AuthManager.swift         # Quản lý phiên đăng nhập, Token Bearer & Keychain
│   ├── ErrorManager.swift        # Quản lý thông báo lỗi/Toast/Alert toàn app
│   ├── KeychainHelper.swift      # Mã hoá lưu thông tin bảo mật vào iOS Keychain
│   ├── Models/                   # CÁC STRUCT DỮ LIỆU (RESPONSE / REQUEST MODELS)
│   │   ├── ResponseModels.swift  # Model phản hồi DTO từ các API server
│   │   └── HomeDashboardData.swift # Model dữ liệu cho màn hình Home Dashboard
│   ├── Services/                 # CÁC DỊCH VỤ GỌI API THEO PHÂN HỆ
│   │   ├── AuthService.swift     # API Đăng nhập / Đổi mật khẩu
│   │   ├── DashboardService.swift# API Thống kê tổng quan Home
│   │   ├── PhieuVCService.swift  # API Phiếu VC (Thêm/Sửa/Xoá/Chi tiết Nhập, Xuất, Gia Công)
│   │   ├── TruyVanService.swift  # API Truy vấn Chuyến xe / Nhập / Xuất
│   │   ├── ListHelpersService.swift # API danh sách bổ trợ (Dropdown options)
│   │   ├── HangHoaService.swift  # API Danh mục Hàng hoá
│   │   ├── KhachHangService.swift# API Danh mục Khách hàng
│   │   ├── NhanVienService.swift # API Danh mục Nhân viên
│   │   └── XeService.swift       # API Danh mục Xe
│   └── Extensions/               # Tiện ích mở rộng Date, String, Image Base64
│
├── Components/                   # THƯ VIỆN CÁC THÀNH PHẦN GIAO DIỆN TÁI SỬ DỤNG
│   ├── VTSDesignSystem.swift     # Bảng màu (Tokens), Spacing, Radius, Typography
│   ├── VTSScreen.swift           # Container khung màn hình chung + Gradient
│   ├── CustomToolbar.swift       # Thanh Navigation bar tuỳ biến trên cùng
│   ├── VTSLiquidFormField.swift  # Hệ thống ô nhập liệu (Text, Picker, Date, FormCard)
│   ├── ERPTable.swift            # Bảng dữ liệu ERP thông minh (Sticky, Scroll, Sum)
│   ├── VTSLiquidListScreen.swift # Màn hình danh sách chuẩn (Lọc date, Search, Pull-refresh)
│   ├── VTSVoucherHeaderProfileCard.swift # Banner profile đầu trang chi tiết phiếu
│   ├── VTSPhotoSourceSheet.swift # Modal Sheet chọn Nguồn ảnh (Máy ảnh / Thư viện)
│   ├── VTSImageEditorView.swift  # Trình chỉnh sửa ảnh (Crop, Rotate, Adjust)
│   ├── VTSImageOCRHelper.swift   # Trích xuất văn bản tự động từ ảnh (Vision OCR)
│   ├── VTSButton.swift           # Nút bấm chuẩn thiết kế VTS Button
│   ├── VTSCard.swift             # Khung thẻ Glass Card & Stat Card
│   └── VTSFeedback.swift         # Thông báo Toast, Badge, Empty State
│
├── ViewModels/                   # QUẢN LÝ QUY TRÌNH NGHIỆP VỤ & TRẠNG THÁI (STATE)
│   ├── LoginViewModel.swift      # Logic Đăng nhập & FaceID
│   ├── HomeViewModel.swift       # Logic màn hình chính & Dashboard
│   ├── PhieuNhapDetailViewModel.swift  # Logic Phiếu Nhập
│   ├── PhieuXuatDetailViewModel.swift  # Logic Phiếu Xuất
│   ├── PhieuGiaCongDetailViewModel.swift # Logic Phiếu Gia Công
│   └── ...                       # ViewModels cho Truy vấn & Danh mục
│
└── Views/                        # GIAO DIỆN MÀN HÌNH (SWIFTUI VIEWS)
    ├── LoginView.swift           # Màn hình Đăng nhập
    ├── VTSSplashView.swift       # Màn hình chờ Splash
    ├── BiometricUnlockView.swift # Màn hình khoá FaceID
    ├── MainTabView.swift         # Màn hình chính chứa Bottom Navigation TabBar
    └── dashboard/                # Các phân hệ chức năng chính
        ├── HomeView.swift        # Trang chủ Dashboard
        ├── phieuvc/              # Phân hệ Phiếu vận chuyển (nhap, xuat, giacong)
        ├── truyvan/              # Phân hệ Truy vấn dữ liệu (chuyenxe, nhap, xuat)
        ├── hanghoa/ khachhang/ nhanvien/ xe/ # Các phân hệ danh mục
        ├── FilterSettingsView.swift # Bộ lọc nâng cao
        └── SettingsView.swift    # Màn hình Cài đặt tài khoản
```

---

## 3. KIẾN TRÚC PHẦN MỀM & LUỒNG DỮ LIỆU (ARCHITECTURE & DATA FLOW)

Dự án áp dụng mô hình **MVVM**:

1. **View (SwiftUI)**: Chỉ đảm nhận vai trò hiển thị UI và lắng nghe sự thay đổi trạng thái từ ViewModel thông qua các thuộc tính `@StateObject` hoặc `@ObservedObject`.
2. **ViewModel (`ObservableObject`)**: Quản lý trạng thái form, validation nhập liệu, gọi các hàm `async/await` từ Service, và phát tín hiệu update cho View qua thuộc tính `@Published`.
3. **Service Layer**: Đóng gói các hàm thực thi API cụ thể (vd: `them()`, `sua()`, `xoa()`, `layChiTiet()`), chuyển đổi tham số từ ViewModel sang Request Params DTO.
4. **NetworkManager**: Thực hiện HTTP Request thông qua `URLSession` async/await, tự động serialize/deserialize dữ liệu JSON với `JSONDecoder` (SnakeCase/PascalCase), và đính kèm `Bearer Token`.
5. **AuthManager & ErrorManager (Singletons)**:
   - `AuthManager`: Quản lý Token đăng nhập, lưu vào Keychain an toàn, hỗ trợ đăng xuất tự động khi API trả về mã lỗi `401 Unauthorized`.
   - `ErrorManager`: Quản lý thông báo lỗi tập trung, phát Toast/Alert trên giao diện toàn app.

---

## 4. QUẢN LÝ GIAO DIỆN & LIGHT MODE SCOPING

### 4.1. Design Tokens (`VTSDesignSystem.swift`)
- **Màu sắc (Colors)**:
  - `Color.vtsPrimary` (`#004B87`): Màu xanh chủ đạo thương hiệu.
  - `Color.vtsSecondary` (`#2D6A4F`): Màu xanh lá nhấn mạnh các thao tác thành công / nút Lưu.
  - `Color.vtsBg`: Màu nền ứng dụng.
  - `Color.vtsSurface` (`#FCF8F9`): Màu nền các ô thẻ.
- **Khoảng cách (Spacing)**: `VTSSpacing.xs` (4pt), `sm` (8pt), `md` (12pt), `lg` (16pt), `xl` (20pt).
- **Bo góc (Radius)**: `VTSRadius.sm` (8pt), `md` (12pt), `lg` (16pt), `xl` (20pt).

### 4.2. Ép Buộc Chế Độ Sáng (Light Mode Scoping)
- **Màn hình Đăng nhập (`LoginView`)**: Ép chế độ Light Mode giúp ô nhập liệu và các thẻ hiển thị sáng đẹp.
- **Card Form (`VTSLiquidFormCard`)**: Luôn hiển thị nền trắng (`Color.white`) với viền xám nhạt `#C5D2E0` và bóng đổ mượt.
- **Các thành phần Form trong Card**:
  - `VTSLiquidTextField`: Thấu kính trắng tươi, nhãn xám `#475569`, chữ nhập xanh đen đậm `#0F2D59`.
  - `VTSLiquidPickerField` & `VTSLiquidDateTimeField`: Nền trắng với biểu tượng sắc nét.
  - `VTSPhotoSourceSheet`, `DatePicker Sheet`, `Select Search Sheet`: Ép buộc Light Mode khi nạp modally.

---

## 5. CÁC THÀNH PHẦN GIAO DIỆN CHÍNH (KEY UI COMPONENTS)

### 5.1. Bộ Thành Phần Form Nhập Liệu (`VTSLiquidFormField.swift`)
- **`VTSLiquidFormCard`**: Khung bao bọc Form tổng thể.
- **`VTSLiquidTextField`**: Ô nhập văn bản hỗ trợ Floating Label, chế độ chỉ đọc (Readonly), hiển thị nút Copy nhanh, và báo lỗi validation.
- **`VTSLiquidPickerField`**: Ô chọn Dropdown thông minh. Khi bấm vào sẽ mở một Modal Sheet tìm kiếm có tích hợp thanh `VTSSearchBar` giúp lọc dữ liệu cực nhanh.
- **`VTSLiquidDateTimeField`**: Ô chọn ngày/giờ tích hợp `DatePicker` dạng đồ hoạ (`.graphical`).

### 5.2. Bảng Dữ Liệu ERP Cao Cấp (`ERPTable.swift`)
- **Tính năng nổi bật**:
  - Hỗ trợ cuộn 2 chiều (Ngang & Dọc) mượt mà.
  - Cột đầu tiên (Sticky First Column) cố định khi cuộn ngang.
  - Tự động tính tổng cho các cột định dạng số.
  - Tự động định dạng số tiền, số lượng (xử lý bỏ các phần thập phân thừa `,000000`) và ngày tháng chuẩn tiếng Việt.
  - Mặc định màu chữ tối rõ ràng (`Color.black` / `#0F2D59`) trên nền trắng tươi.

### 5.3. Xử Lý Ảnh & OCR (`VTSPhotoSourceSheet`, `VTSImageEditorView`, `VTSImageOCRHelper`)
- **`VTSPhotoSourceSheet`**: Modal Sheet cho phép người dùng chọn nguồn ảnh: "Chụp ảnh" (mở Camera) hoặc "Chọn từ thư viện" (mở PhotosPicker).
- **`VTSImageEditorView`**: Màn hình cho phép xoay ảnh, cắt ảnh (Crop) trước khi đính kèm vào phiếu.
- **`VTSImageOCRHelper`**: Tự động trích xuất văn bản từ hình ảnh phiếu cân/hoá đơn thông qua Apple **Vision Framework** (`VNRecognizeTextRequest`).

---

## 6. LOGIC TRỌNG YẾU TRONG CÁC PHÂN HỆ PHIẾU VẬN CHUYỂN

### 6.1. Quy Tắc Thêm Ảnh Tuần Tự (Sequential Photo Requirement)
- **Phiếu Nhập & Phiếu Xuất** (2 ô ảnh):
  - Ô **Ảnh 1**: Luôn cho phép mở.
  - Ô **Ảnh 2**: Chỉ cho phép thêm ảnh khi Ô **Ảnh 1** đã có ảnh (`hinh01 != nil`).
- **Phiếu Gia Công** (6 ô ảnh):
  - Mở tuần tự **1 ➔ 2 ➔ 3 ➔ 4 ➔ 5 ➔ 6**.
  - Nếu ô phía trước chưa có ảnh, ô tiếp theo sẽ hiển thị trạng thái làm mờ (`opacity 0.5`) kèm dòng chữ nhãn hướng dẫn *"Thêm ảnh (n-1) trước"*.

### 6.2. Chuẩn Hoá Biển Số Xe & Tự Động Gợi Ý
Trong các form phiếu, hàm `normalizePlate(_ input: String)` tự động xoá các ký tự khoảng trắng, dấu gạch ngang, dấu chấm và viết hoa toàn bộ biển số xe (vd: `51C-123.45` ➔ `51C12345`). Qua đó tự động đối soát với danh sách `xeOptions` để tự động chọn đúng loại **Xe nhà / Xe ngoài** và điền tên tài xế/nhân viên tương ứng.

---

## 7. HƯỚNG DẪN DÀNH CHO DEVELOPER MỚI (DEVELOPER ONBOARDING)

### 7.1. Cách Thêm Một API Service Mới
1. Thêm Struct Request/Response DTO trong file `Networking/Models/ResponseModels.swift`.
2. Tạo file Service mới trong `Networking/Services/` (ví dụ: `BaoCaoService.swift`):
```swift
struct BaoCaoService {
    static let shared = BaoCaoService()
    private init() {}
    
    func layBaoCao(tuNgay: String, denNgay: String) async throws -> [TBaoCaoResult] {
        let params = ["TuNgay": tuNgay, "DenNgay": denNgay]
        return try await NetworkManager.shared.request(
            endpoint: AppConfig.Endpoints.baoCao,
            method: .post,
            body: params
        )
    }
}
```

### 7.2. Cách Tạo Một Màn Hình Danh Sách Mới Dùng `VTSLiquidListScreen`
```swift
struct BaoCaoListView: View {
    @StateObject private var viewModel = BaoCaoViewModel()
    
    var body: some View {
        VTSLiquidListScreen(
            title: "Báo cáo vận chuyển",
            searchPlaceholder: "Tìm kiếm...",
            searchText: $viewModel.searchText,
            tuNgay: $viewModel.tuNgay,
            denNgay: $viewModel.denNgay,
            onFilterChange: { viewModel.loadData() },
            onRefresh: { await viewModel.loadData() }
        ) {
            ERPTable(
                headers: ["Số phiếu", "Ngày", "Số xe", "Trọng lượng"],
                data: viewModel.filteredItems,
                cellValue: { item, colIndex in
                    switch colIndex {
                    case 0: return item.soPhieu
                    case 1: return item.ngay
                    case 2: return item.soXe
                    case 3: return "\(item.trongLuong) kg"
                    default: return ""
                    }
                }
            )
        }
    }
}
```
