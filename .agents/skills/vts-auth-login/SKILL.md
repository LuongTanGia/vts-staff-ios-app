---
name: vts-auth-login
description: >-
  Use this skill when implementing, maintaining, or integrating authentication workflows (Standard Username/Password and Sign in with Apple ID) across VTS iOS applications (VTS_KSNB, VTS_STAFF) adhering strictly to existing API endpoints and business logic.
---

# VTS Authentication & Apple ID Sign In Skill

Quy chuẩn và hướng dẫn triển khai luồng xác thực (Authentication) cho các ứng dụng iOS thuộc hệ sinh thái VTS (VTS_KSNB, VTS_STAFF, v.v.). **Giữ nguyên 100% logic nghiệp vụ và contract API hiện hữu.**

---

## 1. Tổng quan kiến trúc xác thực

Hệ thống hỗ trợ 2 phương thức đăng nhập cùng trỏ về một endpoint backend duy nhất:
1. **Đăng nhập truyền thống (User / Password)**: Sử dụng username, password và optional FCM Device Token.
2. **Đăng nhập Apple ID**: Sử dụng `authorizationCode` (dưới dạng chuỗi string) truyền vào trường `TokenID` của payload backend.
3. **Luồng phân nhánh sau đăng nhập**:
   - Nếu server trả về danh sách database chi nhánh (`dataResults: [TRemoteDBItem]`), người dùng chọn database trước khi vào app (hoặc auto-select nếu trước đó đã lưu hoặc chỉ có 1 DB).
   - Nếu server trả về token trực tiếp, lưu phiên đăng nhập vào `AuthManager` và vào Home.

---

## 2. API Contract chuẩn (Không thay đổi)

### Endpoint: `POST /api/auth/DangNhap`
* **Base URL**: Cấu hình theo `AppConfig.baseURL` (mặc định lấy từ cấu hình máy chủ hoặc người dùng tuỳ chỉnh).
* **Header**: Không yêu cầu Bearer Token (`requiresAuth: false`).
* **Content-Type**: `application/json`

### Request Payload (`Params_UserPass_Base`)
```swift
struct Params_UserPass_Base: Encodable {
    var tokenID: String?    // Cho Apple ID: chứa authorizationCode dạng String. Cho User/Pass: chứa FCM Device Token
    var user: String?       // Cho User/Pass: Tên đăng nhập. Cho Apple ID: nil hoặc mã user định danh
    var pass: String?       // Cho User/Pass: Mật khẩu. Cho Apple ID: nil
    
    enum CodingKeys: String, CodingKey {
        case tokenID = "TokenID"
        case user = "User"
        case pass = "Pass"
    }
}
```

### Response Model (`TDangNhap`)
* `dataError: Int?`: Mã lỗi server (0 hoặc nil = thành công).
* `dataErrorDescription: String?`: Thông điệp lỗi từ backend.
* `tkn: String?`: Access token JWT.
* `rtkn: String?`: Refresh token.
* `chucNangPhanQuyens: [TChucNangPhanQuyen]?`: Danh sách quyền hạn menu/chức năng.
* `soLEHeThong: TSoLeHeThong?`: Cấu hình số lẻ hiển thị (số lượng, đơn giá, số tiền, tỷ lệ).
* `dataResults: [TRemoteDBItem]?`: Danh sách cơ sở dữ liệu / chi nhánh kết nối.

---

## 3. Quy chuẩn Apple ID Sign In

### A. Cấu hình Project & Entitlements
File `.entitlements` của ứng dụng bắt buộc phải có capability:
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

### B. Cấu trúc dữ liệu AppleAuthResult
```swift
public struct AppleAuthResult: Identifiable, Codable, CustomStringConvertible {
    public let id: String
    public let appleUserId: String
    public let identityToken: String
    public let authorizationCode: String?
    public let email: String?
    public let fullName: String?

    public init(
        appleUserId: String,
        identityToken: String,
        authorizationCode: String? = nil,
        email: String? = nil,
        fullName: String? = nil
    ) {
        self.id = appleUserId
        self.appleUserId = appleUserId
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.email = email
        self.fullName = fullName
    }
}
```

### C. Logic xử lý Request & Callback (Thủ công qua nút bấm)
1. **Scope yêu cầu**: `[.fullName, .email]`
2. **Kiểm tra Điều khoản (Privacy Policy)**: Người dùng phải chấp thuận điều khoản trước khi trigger Apple Sign In. Nếu chưa đồng ý, chặn tap và hiển thị cảnh báo cảnh báo.
3. **Bỏ qua lỗi huỷ (Cancel)**:
   ```swift
   if let asError = error as? ASAuthorizationError, asError.code == .canceled {
       // Người dùng bấm huỷ sheet -> KHÔNG hiển thị alert lỗi
       return
   }
   ```
4. **Trích xuất dữ liệu Apple**:
   - `credential.user`: Định danh cố định của Apple. Lưu vào `KeychainHelper` và `UserDefaults` (`vts_apple_user_id`).
   - `credential.authorizationCode`: Chuyển đổi `Data` sang `String(data:..., encoding: .utf8)`. Dùng giá trị này làm `authCode` truyền vào `TokenID` khi gọi API.
   - `credential.identityToken`: Chuyển đổi `Data` sang UTF-8 string.
   - `credential.fullName` & `credential.email`: **Apple chỉ gửi ở lần cấp quyền đầu tiên!** Cần cache lại vào `UserDefaults` theo key `vts_apple_name_{appleUserId}` và `vts_apple_email_{appleUserId}` để các lần đăng nhập tiếp theo vẫn có thông tin hiển thị.

---

## 4. Quản lý trạng thái & Tự động đăng nhập (Auto Login)

### A. Các Key lưu trữ trạng thái
| Key | Vị trí | Ý nghĩa |
| :--- | :--- | :--- |
| `vts_apple_user_id` | Keychain & UserDefaults | Apple User Identifier của lần đăng nhập gần nhất |
| `vts_logged_in_with_apple` | UserDefaults (Bool) | Cờ ghi nhận phiên đăng nhập gần nhất là Apple ID |
| `vts_apple_manual_logout` | UserDefaults (Bool) | `true` khi user bấm Đăng xuất thủ công (ngăn tự động đăng nhập lại để user có thể đổi tài khoản) |
| `vts_selected_remote_db` | UserDefaults (String) | Remote DB đã được chọn trước đó |

### B. Luồng Auto Login Apple ID (`checkAndAutoLoginAppleIfNeeded`)
1. Kiểm tra chính sách: Nếu chưa đồng ý Điều khoản -> Bỏ qua.
2. Kiểm tra cờ `vts_apple_manual_logout`: Nếu là `true` -> Bỏ qua.
3. Kiểm tra cờ `vts_logged_in_with_apple`: Nếu `false` -> Bỏ qua.
4. Lấy `appleUserId` đã lưu trong Keychain / UserDefaults.
5. Kiểm tra trạng thái chứng chỉ qua Apple:
   ```swift
   let provider = ASAuthorizationAppleIDProvider()
   provider.getCredentialState(forUserID: appleUserId) { state, error in
       switch state {
       case .authorized:
           // Chứng chỉ còn hiệu lực -> Gọi performAppleSignInRequest() tự động
       case .revoked, .notFound:
           // Quyền bị thu hồi hoặc không tìm thấy -> Xoá trạng thái đã lưu
           clearAppleSavedState()
       case .transferred:
           break
       @unknown default:
           break
       }
   }
   ```

---

## 5. Mẫu cài đặt hoàn chỉnh (Code Templates)

### A. AuthService (`Networking/Services/AuthService.swift`)
```swift
// MARK: - Đăng nhập bằng Apple ID
@discardableResult
func dangNhapApple(authCode: String, user: String? = nil, fullName: String? = nil) async throws -> TDangNhap {
    let body = Params_UserPass_Base(tokenID: authCode, user: user, pass: nil)
    
    let response: TDangNhap = try await net.post(
        path: "/api/auth/DangNhap",
        body: body,
        requiresAuth: false
    )
    
    if let err = response.dataError, err != 0 {
        throw NetworkError.serverError(statusCode: err, message: response.dataErrorDescription ?? "Đăng nhập bằng Apple ID thất bại.")
    }
    
    if let token = response.tkn, !token.isEmpty {
        AuthManager.shared.saveSession(
            access:  token,
            refresh: response.rtkn,
            hoTen:   fullName ?? user ?? "Apple User",
            maNV:    "",
            avatar:  "",
            chucNangPhanQuyens: response.chucNangPhanQuyens ?? [],
            soLEHeThong: response.soLEHeThong,
            remoteDBList: response.dataResults ?? []
        )
    } else {
        if let desc = response.dataErrorDescription, !desc.isEmpty {
            throw NetworkError.serverError(statusCode: response.dataError ?? -1, message: desc)
        }
        throw AuthError.invalidCredentials
    }
    
    return response
}
```

### B. LoginViewModel (`Features/Auth/LoginViewModel.swift`)
```swift
// MARK: - Sign in with Apple Handlers
public func configureAppleSignIn(request: ASAuthorizationAppleIDRequest) {
    request.requestedScopes = [.fullName, .email]
}

public func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
    switch result {
    case .success(let authorization):
        UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
        handleAppleAuthorization(authorization)
    case .failure(let error):
        if let asError = error as? ASAuthorizationError, asError.code == .canceled {
            print("ℹ️ [APPLE AUTH]: Người dùng đã huỷ.")
            return
        }
        showError("Đăng nhập Apple thất bại: \(error.localizedDescription)")
    }
}

public func handleAppleAuthorization(_ authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
        showError("Không nhận diện được chứng chỉ Apple ID.")
        return
    }
    
    guard let tokenData = appleIDCredential.identityToken,
          let identityTokenString = String(data: tokenData, encoding: .utf8) else {
        showError("Không thể trích xuất Identity Token từ Apple ID.")
        return
    }
    
    var authCodeString: String? = nil
    if let authCodeData = appleIDCredential.authorizationCode {
        authCodeString = String(data: authCodeData, encoding: .utf8)
    }
    
    var fullNameString: String? = nil
    if let nameComponents = appleIDCredential.fullName {
        let formatter = PersonNameComponentsFormatter()
        let formatted = formatter.string(from: nameComponents).trimmingCharacters(in: .whitespacesAndNewlines)
        if !formatted.isEmpty { fullNameString = formatted }
    }
    
    let appleResult = AppleAuthResult(
        appleUserId: appleIDCredential.user,
        identityToken: identityTokenString,
        authorizationCode: authCodeString,
        email: appleIDCredential.email,
        fullName: fullNameString
    )
    
    // Lưu định danh
    KeychainHelper.shared.save(appleResult.appleUserId, forKey: "vts_apple_user_id")
    UserDefaults.standard.set(appleResult.appleUserId, forKey: "vts_apple_user_id")
    UserDefaults.standard.set(true, forKey: "vts_logged_in_with_apple")
    UserDefaults.standard.set(false, forKey: "vts_apple_manual_logout")
    
    self.appleAuthResult = appleResult
    
    guard let authCode = appleResult.authorizationCode, !authCode.isEmpty else {
        showError("Không lấy được authorization code từ Apple ID.")
        return
    }
    
    Task {
        await loginWithApple(authCode: authCode, result: appleResult)
    }
}
```

### C. LoginView SwiftUI Button (`Features/Auth/LoginView.swift`)
```swift
ZStack {
    SignInWithAppleButton(
        .signIn,
        onRequest: viewModel.configureAppleSignIn,
        onCompletion: viewModel.handleAppleSignIn
    )
    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
    .frame(height: 48)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    .opacity(viewModel.isAgreedToPrivacyPolicy ? 1.0 : 0.5)

    if !viewModel.isAgreedToPrivacyPolicy {
        Color.black.opacity(0.001)
            .frame(height: 48)
            .cornerRadius(12)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.showPrivacyWarning()
            }
    }
}
```

---

## 6. Những điều cấm kỵ (Guardrails)

1. **KHÔNG đổi cấu trúc payload API**: Trường chứa `authCode` bắt buộc phải là `TokenID` (chữ T viết hoa, map qua `Params_UserPass_Base`).
2. **KHÔNG sửa endpoint**: Endpoint bắt buộc là `POST /api/auth/DangNhap`.
3. **KHÔNG bỏ qua việc check `ASAuthorizationError.canceled`**: Việc hiện alert khi người dùng bấm Cancel sẽ bị reject trải nghiệm hoặc gây khó chịu.
4. **KHÔNG xoá cờ `vts_apple_manual_logout` khi chưa đăng nhập lại thành công**: Nếu xoá sai lúc user bấm Đăng xuất, app sẽ rơi vào vòng lặp tự động đăng nhập lại tài khoản cũ ngay khi mở màn hình login.
