
//
//  Models.swift
//  VTS_STAFF
//
//  Toàn bộ Request/Response model được sinh tự động từ api.json (OpenAPI 3.0.4)
//  Mỗi struct ánh xạ 1:1 với schema trong components/schemas.
//

import Foundation

// MARK: - ============================================================
//                         PARAMS (REQUEST BODIES)
// MARK: - ============================================================

// MARK: Đăng nhập
/// POST /api/auth/DangNhap
struct Params_UserPass_Base: Encodable {
    /// TokenID thiết bị (FCM / push token, tuỳ chọn)
    var tokenID: String?
    /// Tên đăng nhập
    var user: String?
    /// Mật khẩu
    var pass: String?
    
    var clientToken: String?
    
    enum CodingKeys: String, CodingKey {
        case tokenID = "TokenID"
        case user    = "User"
        case pass    = "Pass"
        case clientToken = "ClientToken"
    }
}

// MARK: Refresh Token
/// POST /api/auth/RefreshToken
struct Params_Token_Base: Encodable {
    var tokenID: String?
    var clientToken: String?
    enum CodingKeys: String, CodingKey {
        case tokenID = "TokenID"
        case clientToken = "ClientToken"
    }
}

// MARK: Params_Ma – dùng chung cho ThongTin & Xoa (HangHoa, KhachHang, Xe)
/// Ví dụ: POST /api/hanghoa/ThongTin, /api/xe/Xoa, ...
struct Params_Ma: Encodable {
    var ma: String?
    
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
    }
}

// MARK: Params_SoPhieu – dùng cho PhieuVC (ThongTin, Xoa)
struct Params_SoPhieu: Encodable {
    var soPhieu: String?
    
    enum CodingKeys: String, CodingKey {
        case soPhieu = "SoPhieu"
    }
}

// MARK: Params_MaHinh – ảnh trong danh sách hình
struct Params_MaHinh: Codable {
    var maHinh: String?
    
    enum CodingKeys: String, CodingKey {
        case maHinh = "MaHinh"
    }
}

// MARK: Params_ThongTin_HinhAnh
struct Params_ThongTin_HinhAnh: Encodable {
    var soPhieu: String?
    var danhSachHinh: [Params_MaHinh]?
    
    enum CodingKeys: String, CodingKey {
        case soPhieu      = "SoPhieu"
        case danhSachHinh = "DanhSachHinh"
    }
}

// MARK: Params_GuiAnh – gửi ảnh base64
struct Params_GuiAnh: Encodable {
    var soPhieu: String?
    /// Ghi chú / mô tả ảnh
    var noiDungText: String?
    /// Base64 của ảnh
    var noiDungAnh: String?
    
    enum CodingKeys: String, CodingKey {
        case soPhieu    = "SoPhieu"
        case noiDungText = "NoiDungText"
        case noiDungAnh  = "NoiDungAnh"
    }
}

// MARK: Params_DateFromTo_Base – lọc theo khoảng ngày
struct Params_DateFromTo_Base: Encodable {
    /// Dạng "yyyy-MM-dd" hoặc ISO8601
    var dateFrom: String?
    var dateTo: String?
    
    enum CodingKeys: String, CodingKey {
        case dateFrom = "DateFrom"
        case dateTo   = "DateTo"
    }
}

// MARK: - ============================================================
//                         DATA IN (CRUD Bodies)
// MARK: - ============================================================

// MARK: HangHoa – Them / Sua
struct DataIn_List_HangHoa: Encodable {
    var ma: String?
    var ten: String?
    var loai: String?
    var nhom: String?
    var dvt: String?
    var ghiChu: String?
    
    enum CodingKeys: String, CodingKey {
        case ma     = "Ma"
        case ten    = "Ten"
        case loai   = "Loai"
        case nhom   = "Nhom"
        case dvt    = "DVT"
        case ghiChu = "GhiChu"
    }
}

// MARK: KhachHang – Them / Sua
struct DataIn_List_KhachHang: Encodable {
    var ma: String?
    var ten: String?
    var diaChi: String?
    var mst: String?
    var dienThoai: String?
    var email: String?
    var loai: String?
    var nhom: String?
    var ghiChu: String?
    
    enum CodingKeys: String, CodingKey {
        case ma        = "Ma"
        case ten       = "Ten"
        case diaChi    = "DiaChi"
        case mst       = "MST"
        case dienThoai = "DienThoai"
        case email     = "Email"
        case loai      = "Loai"
        case nhom      = "Nhom"
        case ghiChu    = "GhiChu"
    }
}

// MARK: Xe – Them / Sua
struct DataIn_List_Xe: Encodable {
    var ma: String?
    var ten: String?
    var loai: String?
    var nhom: String?
    var taiXe: String?
    var ghiChu: String?
    
    enum CodingKeys: String, CodingKey {
        case ma     = "Ma"
        case ten    = "Ten"
        case loai   = "Loai"
        case nhom   = "Nhom"
        case taiXe  = "TaiXe"
        case ghiChu = "GhiChu"
    }
}

// MARK: NhanVien – Sua
struct DataIn_NhanVien: Encodable {
    var emid: String?
    var emHo: String?
    var emTen: String?
    var emGioiTinh: Int?
    var emNgaySinh: Date?
    var emDienThoai: String?
    var emEmail: String?
    var emDiaChi_SoDuong: String?
    var emDiaChi_PhuongXa: String?
    var emDiaChi_TinhThanh: String?
    var emDiaChi_QuocGia: String?
    var emcccdpp_So: String?
    var ghiChu: String?
    
    enum CodingKeys: String, CodingKey {
        case emid                = "EMID"
        case emHo                = "EMHo"
        case emTen               = "EMTen"
        case emGioiTinh          = "EMGioiTinh"
        case emNgaySinh          = "EMNgaySinh"
        case emDienThoai         = "EMDienThoai"
        case emEmail             = "EMEmail"
        case emDiaChi_SoDuong    = "EMDiaChi_SoDuong"
        case emDiaChi_PhuongXa   = "EMDiaChi_PhuongXa"
        case emDiaChi_TinhThanh  = "EMDiaChi_TinhThanh"
        case emDiaChi_QuocGia    = "EMDiaChi_QuocGia"
        case emcccdpp_So         = "EMCCCDPP_So"
        case ghiChu              = "GhiChu"
    }
}

// MARK: - ============================================================
//                  PHIẾU VC – GIA CÔNG, NHẬP, XUẤT
// MARK: - ============================================================

// MARK: Thêm phiếu GiaCong
struct Params_ThemPhieu_GiaCong: Encodable {
    var ngay: Date = Date()
    var soThamChieu: String?
    var xeNgoai: Bool = false
    var soXe: String?
    var nhanVien: String?
    var taiXe: String?
    var khachHang: String?
    var hangHoa: String?
    var trongLuongXe: Double = 0
    var trongLuongHang: Double = 0
    var thoiGian01: Date?
    var hinh01NoiDungText: String?
    var hinh01NoiDung: String?
    var thoiGian02: Date?
    var hinh02NoiDungText: String?
    var hinh02NoiDung: String?
    var ghiChu: String?
    var trangThai: String?
    var hangHoaGC: String?
    var trongLuongHangGC: Double = 0
    var thoiGian03: Date?
    var hinh03NoiDungText: String?
    var hinh03NoiDung: String?
    var thoiGian04: Date?
    var hinh04NoiDungText: String?
    var hinh04NoiDung: String?
    var hangHoaTV: String?
    var trongLuongHangTV: Double = 0
    var thoiGian05: Date?
    var hinh05NoiDungText: String?
    var hinh05NoiDung: String?
    var thoiGian06: Date?
    var hinh06NoiDungText: String?
    var hinh06NoiDung: String?
    
    enum CodingKeys: String, CodingKey {
        case ngay                = "Ngay"
        case soThamChieu         = "SoThamChieu"
        case xeNgoai             = "XeNgoai"
        case soXe                = "SoXe"
        case nhanVien            = "NhanVien"
        case taiXe               = "TaiXe"
        case khachHang           = "KhachHang"
        case hangHoa             = "HangHoa"
        case trongLuongXe        = "TrongLuongXe"
        case trongLuongHang      = "TrongLuongHang"
        case thoiGian01          = "ThoiGian01"
        case hinh01NoiDungText   = "Hinh01NoiDungText"
        case hinh01NoiDung       = "Hinh01NoiDung"
        case thoiGian02          = "ThoiGian02"
        case hinh02NoiDungText   = "Hinh02NoiDungText"
        case hinh02NoiDung       = "Hinh02NoiDung"
        case ghiChu              = "GhiChu"
        case trangThai           = "TrangThai"
        case hangHoaGC           = "HangHoaGC"
        case trongLuongHangGC    = "TrongLuongHangGC"
        case thoiGian03          = "ThoiGian03"
        case hinh03NoiDungText   = "Hinh03NoiDungText"
        case hinh03NoiDung       = "Hinh03NoiDung"
        case thoiGian04          = "ThoiGian04"
        case hinh04NoiDungText   = "Hinh04NoiDungText"
        case hinh04NoiDung       = "Hinh04NoiDung"
        case hangHoaTV           = "HangHoaTV"
        case trongLuongHangTV    = "TrongLuongHangTV"
        case thoiGian05          = "ThoiGian05"
        case hinh05NoiDungText   = "Hinh05NoiDungText"
        case hinh05NoiDung       = "Hinh05NoiDung"
        case thoiGian06          = "ThoiGian06"
        case hinh06NoiDungText   = "Hinh06NoiDungText"
        case hinh06NoiDung       = "Hinh06NoiDung"
    }
}

// MARK: Sửa phiếu GiaCong (có thêm SoPhieu + XoaHinh)
struct Params_SuaPhieu_GiaCong: Encodable {
    var ngay: Date = Date()
    var soThamChieu: String?
    var xeNgoai: Bool = false
    var soXe: String?
    var nhanVien: String?
    var taiXe: String?
    var khachHang: String?
    var hangHoa: String?
    var trongLuongXe: Double = 0
    var trongLuongHang: Double = 0
    var thoiGian01: Date?
    var hinh01NoiDungText: String?
    var hinh01NoiDung: String?
    var thoiGian02: Date?
    var hinh02NoiDungText: String?
    var hinh02NoiDung: String?
    var ghiChu: String?
    var trangThai: String?
    var soPhieu: String?
    var hangHoaGC: String?
    var trongLuongHangGC: Double = 0
    var thoiGian03: Date?
    var hinh03NoiDungText: String?
    var hinh03NoiDung: String?
    var thoiGian04: Date?
    var hinh04NoiDungText: String?
    var hinh04NoiDung: String?
    var hangHoaTV: String?
    var trongLuongHangTV: Double = 0
    var thoiGian05: Date?
    var hinh05NoiDungText: String?
    var hinh05NoiDung: String?
    var thoiGian06: Date?
    var hinh06NoiDungText: String?
    var hinh06NoiDung: String?
    var xoaHinh01: Bool = false
    var xoaHinh02: Bool = false
    var xoaHinh03: Bool = false
    var xoaHinh04: Bool = false
    var xoaHinh05: Bool = false
    var xoaHinh06: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case ngay                = "Ngay"
        case soThamChieu         = "SoThamChieu"
        case xeNgoai             = "XeNgoai"
        case soXe                = "SoXe"
        case nhanVien            = "NhanVien"
        case taiXe               = "TaiXe"
        case khachHang           = "KhachHang"
        case hangHoa             = "HangHoa"
        case trongLuongXe        = "TrongLuongXe"
        case trongLuongHang      = "TrongLuongHang"
        case thoiGian01          = "ThoiGian01"
        case hinh01NoiDungText   = "Hinh01NoiDungText"
        case hinh01NoiDung       = "Hinh01NoiDung"
        case thoiGian02          = "ThoiGian02"
        case hinh02NoiDungText   = "Hinh02NoiDungText"
        case hinh02NoiDung       = "Hinh02NoiDung"
        case ghiChu              = "GhiChu"
        case trangThai           = "TrangThai"
        case soPhieu             = "SoPhieu"
        case hangHoaGC           = "HangHoaGC"
        case trongLuongHangGC    = "TrongLuongHangGC"
        case thoiGian03          = "ThoiGian03"
        case hinh03NoiDungText   = "Hinh03NoiDungText"
        case hinh03NoiDung       = "Hinh03NoiDung"
        case thoiGian04          = "ThoiGian04"
        case hinh04NoiDungText   = "Hinh04NoiDungText"
        case hinh04NoiDung       = "Hinh04NoiDung"
        case hangHoaTV           = "HangHoaTV"
        case trongLuongHangTV    = "TrongLuongHangTV"
        case thoiGian05          = "ThoiGian05"
        case hinh05NoiDungText   = "Hinh05NoiDungText"
        case hinh05NoiDung       = "Hinh05NoiDung"
        case thoiGian06          = "ThoiGian06"
        case hinh06NoiDungText   = "Hinh06NoiDungText"
        case hinh06NoiDung       = "Hinh06NoiDung"
        case xoaHinh01           = "XoaHinh01"
        case xoaHinh02           = "XoaHinh02"
        case xoaHinh03           = "XoaHinh03"
        case xoaHinh04           = "XoaHinh04"
        case xoaHinh05           = "XoaHinh05"
        case xoaHinh06           = "XoaHinh06"
    }
}

// MARK: Thêm phiếu Nhập
struct Params_ThemPhieu_Nhap: Encodable {
    var ngay: Date = Date()
    var soThamChieu: String?
    var xeNgoai: Bool = false
    var soXe: String?
    var nhanVien: String?
    var taiXe: String?
    var khachHang: String?
    var hangHoa: String?
    var trongLuongXe: Double = 0
    var trongLuongHang: Double = 0
    var thoiGian01: Date?
    var hinh01NoiDungText: String?
    var hinh01NoiDung: String?
    var thoiGian02: Date?
    var hinh02NoiDungText: String?
    var hinh02NoiDung: String?
    var ghiChu: String?
    var trangThai: String?
    
    enum CodingKeys: String, CodingKey {
        case ngay              = "Ngay"
        case soThamChieu       = "SoThamChieu"
        case xeNgoai           = "XeNgoai"
        case soXe              = "SoXe"
        case nhanVien          = "NhanVien"
        case taiXe             = "TaiXe"
        case khachHang         = "KhachHang"
        case hangHoa           = "HangHoa"
        case trongLuongXe      = "TrongLuongXe"
        case trongLuongHang    = "TrongLuongHang"
        case thoiGian01        = "ThoiGian01"
        case hinh01NoiDungText = "Hinh01NoiDungText"
        case hinh01NoiDung     = "Hinh01NoiDung"
        case thoiGian02        = "ThoiGian02"
        case hinh02NoiDungText = "Hinh02NoiDungText"
        case hinh02NoiDung     = "Hinh02NoiDung"
        case ghiChu            = "GhiChu"
        case trangThai         = "TrangThai"
    }
}

// MARK: Sửa phiếu Nhập
struct Params_SuaPhieu_Nhap: Encodable {
    var ngay: Date = Date()
    var soThamChieu: String?
    var xeNgoai: Bool = false
    var soXe: String?
    var nhanVien: String?
    var taiXe: String?
    var khachHang: String?
    var hangHoa: String?
    var trongLuongXe: Double = 0
    var trongLuongHang: Double = 0
    var thoiGian01: Date?
    var hinh01NoiDungText: String?
    var hinh01NoiDung: String?
    var thoiGian02: Date?
    var hinh02NoiDungText: String?
    var hinh02NoiDung: String?
    var ghiChu: String?
    var trangThai: String?
    var soPhieu: String?
    var xoaHinh01: Bool = false
    var xoaHinh02: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case ngay              = "Ngay"
        case soThamChieu       = "SoThamChieu"
        case xeNgoai           = "XeNgoai"
        case soXe              = "SoXe"
        case nhanVien          = "NhanVien"
        case taiXe             = "TaiXe"
        case khachHang         = "KhachHang"
        case hangHoa           = "HangHoa"
        case trongLuongXe      = "TrongLuongXe"
        case trongLuongHang    = "TrongLuongHang"
        case thoiGian01        = "ThoiGian01"
        case hinh01NoiDungText = "Hinh01NoiDungText"
        case hinh01NoiDung     = "Hinh01NoiDung"
        case thoiGian02        = "ThoiGian02"
        case hinh02NoiDungText = "Hinh02NoiDungText"
        case hinh02NoiDung     = "Hinh02NoiDung"
        case ghiChu            = "GhiChu"
        case trangThai         = "TrangThai"
        case soPhieu           = "SoPhieu"
        case xoaHinh01         = "XoaHinh01"
        case xoaHinh02         = "XoaHinh02"
    }
}

// MARK: Thêm phiếu Xuất (giống Nhập)
typealias Params_ThemPhieu_Xuat = Params_ThemPhieu_Nhap

// MARK: Sửa phiếu Xuất (giống Sửa Nhập)
typealias Params_SuaPhieu_Xuat = Params_SuaPhieu_Nhap
