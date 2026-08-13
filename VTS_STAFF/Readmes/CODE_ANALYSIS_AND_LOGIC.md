# BÁO CÁO PHÂN TÍCH KỸ THUẬT: CÁC HÀM TRỌNG YẾU VÀ LOGIC DỰ ÁN VTS STAFF (IOS)

Tài liệu này phân tích chuyên sâu về các hàm xử lý quan trọng (Core Functions), thuật toán logic nghiệp vụ, quy trình xử lý dữ liệu và luồng thực thi trong mã nguồn ứng dụng **VTS Staff iOS**.

---

## 1. QUẢN LÝ XÁC THỰC VÀ BẢO MẬT (AUTH & SECURITY LOGIC)

### 1.1. `AuthManager` & `KeychainHelper`
- **File**: `Networking/AuthManager.swift` & `Networking/KeychainHelper.swift`
- **Chức năng**: Quản lý vòng đời phiên làm việc của người dùng, mã hoá thông tin đăng nhập vào Keychain của hệ điều hành iOS.

#### Các hàm trọng yếu:
```swift
/// Đăng nhập hệ thống và lưu trữ Token bảo mật
func login(username: String, password: String) async throws -> UserProfile
```
- **Logic xử lý**:
  1. Gửi request tới `AuthService.shared.login(username, password)`.
  2. Khi nhận phản hồi thành công, trích xuất `token`, `refreshToken`, và danh sách quyền hạn `permissions`.
  3. Gọi `KeychainHelper.shared.save(token, service: "vts_token")` để lưu token mã hoá vào iOS Keychain.
  4. Cập nhật thuộc tính `@Published var isAuthenticated = true` để chuyển đổi giao diện root trên `ContentView`.

```swift
/// Kiểm tra phân quyền truy cập theo mã chức năng
func getPermission(for moduleKey: String) -> ModulePermission?
```
- **Logic xử lý**:
  - Tra cứu trong mảng `userPermissions` theo `moduleKey` (ví dụ: `"VTSSTAFF_DANHMUC_NHANVIEN"` hoặc `"VTSSTAFF_PHIEU_NHAP"`).
  - Trả về đối tượng chứa các quyền: `view` (Xem), `add` (Thêm), `edit` (Sửa), `delete` (Xoá).
  - Được sử dụng trực tiếp trên các giao diện Toolbar để ẩn/hiện nút **Sửa**, **Xoá** hoặc nút **Tạo mới**.

```swift
/// Đăng xuất và dọn dẹp bộ nhớ an toàn
func logout()
```
- **Logic xử lý**: Xoá Token khỏi Keychain, xoá dữ liệu người dùng tạm thời, và kích hoạt chuyển View về màn hình `LoginView`.

---

## 2. TẦNG KẾT NỐI MẠNG TOÀN CỤC (NETWORK CLIENT & ERROR HANDLING)

### 2.1. `NetworkManager.request(...)`
- **File**: `Networking/NetworkManager.swift`
- **Chức năng**: Hàm Generic HTTP Request trung tâm cho toàn bộ ứng dụng.

```swift
func request<T: Decodable>(
    endpoint: String,
    method: HTTPMethod = .get,
    body: Any? = nil,
    headers: [String: String]? = nil
) async throws -> T
```
- **Logic thực thi**:
  1. **Tạo URLRequest**: Ghép `AppConfig.baseURL` với `endpoint`.
  2. **Đính kèm Auth Header**: Tự động lấy `Bearer Token` từ `AuthManager` và thêm vào Header `Authorization`.
  3. **Serialize Body**: Nếu có `body`, chuyển đổi sang JSON Data bằng `JSONSerialization` hoặc `JSONEncoder`.
  4. **Thực thi HTTP Call**: Sử dụng `URLSession.shared.data(for: request)` dạng `async/await`.
  5. **Xử lý HTTP Code & 401 Handling**:
     - Nếu HTTP Status Code là `401 Unauthorized`: Tự động gọi `AuthManager.shared.logout()` để đưa người dùng về màn hình đăng nhập.
     - Nếu HTTP Status Code >= 400: Ném lỗi `NetworkError.serverError(code, message)`.
  6. **Decode JSON Phản hồi**: Giải mã JSON với `JSONDecoder` (tự động khớp định dạng ngày ISO8601 / Custom Date Format).

### 2.2. `ErrorManager`
- **File**: `Networking/ErrorManager.swift`
- **Chức năng**: Singleton phát thông báo lỗi (Toast/Alert) trên giao diện ứng dụng.
- **Hàm quan trọng**:
  - `showError(_ message: String)`: Hiển thị Toast thông báo lỗi đỏ.
  - `showSuccess(_ message: String)`: Hiển thị Toast thông báo thành công xanh.
  - `handleAlert(_ error: Error)`: Phân tích lỗi ném ra từ API và tạo Alert buộc người dùng bấm xác nhận.

---

## 3. LOGIC NGHIỆP VỤ PHIẾU VẬN CHUYỂN (VOUCHER BUSINESS LOGIC)

### 3.1. Quy Tắc Thêm Ảnh Tuần Tự (`isSlotEnabled`)
- **File**: `Views/dashboard/phieuvc/giacong/PhieuGiaCongDetailView.swift` & các màn hình phiếu.
- **Chức năng**: Ép buộc người dùng đính kèm ảnh theo đúng thứ tự (không được nhảy cóc).

```swift
private func isSlotEnabled(_ slotIndex: Int) -> Bool {
    switch slotIndex {
    case 1: return true
    case 2: return hinh01 != nil
    case 3: return hinh02 != nil
    case 4: return hinh03 != nil
    case 5: return hinh04 != nil
    case 6: return hinh05 != nil
    default: return false
    }
}
```
- **Logic kiểm tra**:
  - Ô $n$ chỉ bật trạng thái cho phép chọn ảnh (`enabled = true`) khi thuộc tính lưu trữ ảnh `hinh0(n-1)` của ô trước đó khác `nil`.
  - Nếu người dùng bấm vào ô bị khoá, hệ thống gọi `ErrorManager.shared.showError("Vui lòng thêm ảnh \(slotIndex - 1) trước.")`.

### 3.2. Chuẩn Hoá Biển Số Xe (`normalizePlate`)
- **Chức năng**: Tự động khớp biển số xe nhập tay hoặc quét từ OCR với danh sách xe trong cơ sở dữ liệu.

```swift
private func normalizePlate(_ input: String) -> String {
    input.uppercased()
        .replacingOccurrences(of: "-", with: "")
        .replacingOccurrences(of: ".", with: "")
        .replacingOccurrences(of: " ", with: "")
}
```
- **Logic tự động gợi ý**:
  - Khi người dùng nhập số xe vào ô `soXe`, hàm so sánh biển số đã chuẩn hoá với `xeOptions`.
  - Nếu tìm thấy xe nhà tương ứng: Tự động đổi trạng thái `xeNgoai = false`, chọn mã xe nhà, và tự động điền mã tài xế cố định (`nhanVien = found.maTaiXe`).

### 3.3. Đổ Dữ Liệu Lên Form (`populateFields`)
- **Chức năng**: Chuyển đổi dữ liệu DTO từ API server sang `@State` của View.

```swift
private func populateFields(with details: TPhieuvc_Giacong_DanhSach) {
    ngay = Date.fromAPIString(details.ngay) ?? Date()
    soThamChieu = details.soThamChieu ?? ""
    nhanVien = details.nhanVien ?? ""
    khachHang = details.khachHang ?? ""
    // ... Khôi phục ảnh Base64
    if let img1 = UIImage.fromBase64(details.image1Base64) { hinh01 = img1 }
}
```

---

## 4. QUAN SÁT VÀ XỬ LÝ ẢNH THÔNG MINH (VISION OCR & IMAGE PROCESSING)

### 4.1. `VTSImageOCRHelper` (Apple Vision Framework)
- **File**: `Components/VTSImageOCRHelper.swift`
- **Chức năng**: Trích xuất chữ tự động từ ảnh chụp phiếu cân / phiếu hàng.

```swift
static func performOCR(on image: UIImage) async -> String? {
    guard let cgImage = image.cgImage else { return nil }
    
    return await withCheckedContinuation { continuation in
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                continuation.resume(returning: nil)
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let resultText = recognizedStrings.joined(separator: "\n")
            continuation.resume(returning: resultText.isEmpty ? nil : resultText)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
```
- **Điểm sáng kỹ thuật**:
  - Chuyển đổi API Callback của Apple Vision thành `async/await` bằng `withCheckedContinuation`.
  - Thiết lập `recognitionLevel = .accurate` giúp đọc chính xác số liệu và chuỗi trên hoá đơn/phiếu cân.

### 4.2. `VTSImageEditorView`
- **File**: `Components/VTSImageEditorView.swift`
- **Chức năng**: Cắt ảnh (Crop), xoay ảnh (Rotate 90 độ), điều chỉnh góc chiếu trước khi upload giúp giảm dung lượng và tối ưu chữ OCR.

---

## 5. BẢNG DỮ LIỆU ERP THÔNG MINH (`ERPTable.swift`)

### 5.1. Thuật Toán Xử Lý Dữ Liệu Bảng ERP
- **File**: `Components/ERPTable.swift`
- **Các tính năng logic chính**:
  1. **Sticky First Column**: Sử dụng `HStack(spacing: 0)` tách biệt cột đầu tiên (được ghim cố định bên trái) và các cột còn lại nằm trong `ScrollView(.horizontal)`.
  2. **Tự động làm sạch số dư thập phân (Trim Trailing Zeros)**:
     ```swift
     private func formatValue(_ value: String) -> String {
         // Chuyển đổi các chuỗi dạng "120.000000" thành "120"
         if let doubleVal = Double(value.replacingOccurrences(of: ",", with: ".")) {
             let formatter = NumberFormatter()
             formatter.minimumFractionDigits = 0
             formatter.maximumFractionDigits = 3
             return formatter.string(from: NSNumber(value: doubleVal)) ?? value
         }
         return value
     }
     ```
  3. **Tự động tính tổng hàng Footer**: Tự động quét dữ liệu của các cột số để hiển thị hàng Tổng cộng bên dưới bảng.

---

## 6. THIẾT KẾ ĐỒNG BỘ GIAO DIỆN & TẬP TRUNG LIGHT MODE

### 6.1. Logic Khóa Chỉnh Sửa Dạng Form Input
- **Màn hình áp dụng**: `NhanVienDetailView`, `KhachHangDetailView`, `HangHoaDetailView`, `XeDetailView`.
- **Cơ chế**:
  - Không phân chia giao diện thành 2 dạng khác nhau (View Mode dùng Text Row, Edit Mode dùng TextField).
  - Toàn bộ giao diện sử dụng chung hệ thống `VTSLiquidFormCard`, `VTSLiquidTextField`, `VTSLiquidPickerField`.
  - Khi ở chế độ Xem (`!isEditMode`), thuộc tính `isReadOnly = true` và `.disabled(true)` được kích hoạt.
  - **Lợi ích**: Triệt tiêu 100% hiện tượng xê dịch bố cục (Layout Shifting) khi người dùng chuyển đổi giữa Xem, Sửa và Tạo mới.

---

## 7. TÓM TẮT DỰ ÁN DÀNH CHO KĨ SƯ NGHỆ TRUYỀN

| Thành phần | Công nghệ / Mã nguồn chính | Trách nhiệm chính |
| :--- | :--- | :--- |
| **Network Client** | `NetworkManager.swift` | Gửi HTTP Async/Await, Token Header, Auto 401 Logout |
| **Auth & Keychain** | `AuthManager.swift`, `KeychainHelper.swift` | Bảo mật Keychain, lưu token, kiểm tra phân quyền Module |
| **Thành phần Form** | `VTSLiquidFormField.swift` | Card sáng, TextField floating label, Picker sheet, DatePicker |
| **Bảng ERP** | `ERPTable.swift` | Scroll 2 chiều, Sticky Column, Trim số thập phân `,000000` |
| **Xử lý Ảnh & OCR** | `VTSImageOCRHelper.swift`, `VTSImageEditorView.swift` | Quét chữ Vision API, Cắt & Xoay ảnh |
| **Màn hình Danh sách** | `VTSLiquidListScreen.swift` | Tích hợp sẵn Lọc ngày, Tìm kiếm, Pull-to-refresh |
