//
//  ResponseModels.swift
//  VTS_STAFF
//
//  Các model response (Decodable) cho từng domain.
//  Dùng kiểu generic APIResponse<T> để unwrap server envelope.
//  Nếu server trả thẳng array/object thì dùng trực tiếp.
//
import Foundation



// MARK: - TDangNhap
struct TDangNhap: Decodable {
    let rtkn, tkn: String?
    let userTest: Bool
    let ngayHetHan: String?
    let chucNangPhanQuyens: [TChucNangPhanQuyen]
    let soLEHeThong: TSoLeHeThong
    let dataError: Int
    let dataErrorDescription: String
    
    enum CodingKeys: String, CodingKey {
        case rtkn = "RTKN"
        case tkn = "TKN"
        case userTest = "UserTest"
        case ngayHetHan = "NgayHetHan"
        case chucNangPhanQuyens = "ChucNangPhanQuyens"
        case soLEHeThong = "SoLeHeThong"
        case dataError = "DataError"
        case dataErrorDescription = "DataErrorDescription"
    }
}

// MARK: - TChucNangPhanQuyen
struct TChucNangPhanQuyen: Codable, Hashable, Identifiable {
    var id: String { maChucNang }
    let sapXep, nhomChucNang, tenNhomChucNang: String?
    let maChucNang, tenChucNang: String
    let ghiChu: String?
    let allowVisible, allowView, allowAdd, allowDel: Bool
    let allowEdit, allowRun, allowExcel, allowToolbar: Bool
    let visible, view, add, del: Bool
    let edit, run, excel, toolbar: Bool
    
    enum CodingKeys: String, CodingKey {
        case sapXep = "SapXep"
        case nhomChucNang = "NhomChucNang"
        case tenNhomChucNang = "TenNhomChucNang"
        case maChucNang = "MaChucNang"
        case tenChucNang = "TenChucNang"
        case ghiChu = "GhiChu"
        case allowVisible = "ALLOW_VISIBLE"
        case allowView = "ALLOW_VIEW"
        case allowAdd = "ALLOW_ADD"
        case allowDel = "ALLOW_DEL"
        case allowEdit = "ALLOW_EDIT"
        case allowRun = "ALLOW_RUN"
        case allowExcel = "ALLOW_EXCEL"
        case allowToolbar = "ALLOW_TOOLBAR"
        case visible = "VISIBLE"
        case view = "VIEW"
        case add = "ADD"
        case del = "DEL"
        case edit = "EDIT"
        case run = "RUN"
        case excel = "EXCEL"
        case toolbar = "TOOLBAR"
    }
}

// MARK: - TSoLeHeThong
struct TSoLeHeThong: Decodable {
    let solesoluong, soledongia, solesotien, soletyle: Int
    
    enum CodingKeys: String, CodingKey {
        case solesoluong = "SOLESOLUONG"
        case soledongia = "SOLEDONGIA"
        case solesotien = "SOLESOTIEN"
        case soletyle = "SOLETYLE"
    }
}



// MARK: - TNhanVienInOutDataResult
struct TNhanVienInOutDataResult: Decodable, Sendable, Identifiable {
    let colOrder: Int
    let colCode, colName: String
    let colValue: Int
    
    var id: String { "inout-\(colCode)-\(colOrder)" }
    
    enum CodingKeys: String, CodingKey {
        case colOrder = "ColOrder"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue = "ColValue"
    }
}

// MARK: - TNhanVienPhongBanDataResult
struct TNhanVienPhongBanDataResult: Decodable, Sendable, Identifiable {
    let colOrder: Int
    let colCode, colName: String?
    let colValue, colValue0, colValue1: Int
    
    var id: String { "phongban-\(colCode ?? "")-\(colOrder)" }
    
    enum CodingKeys: String, CodingKey {
        case colOrder = "ColOrder"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue = "ColValue"
        case colValue0 = "ColValue0"
        case colValue1 = "ColValue1"
    }
}

// MARK: - THangHoa_ChuyenXeDataResult
struct THangHoa_ChuyenXeDataResult: Decodable, Sendable, Identifiable {
    let colType: String
    let colOrder: Int
    let colCode, colName: String?
    let colValue1, colValue2, colValue3, colValue4: Int
    
    var id: String { "chuyenxe-\(colType)-\(colCode ?? "")-\(colOrder)-\(colName ?? "")" }
    
    enum CodingKeys: String, CodingKey {
        case colType = "ColType"
        case colOrder = "ColOrder"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue1 = "ColValue1"
        case colValue2 = "ColValue2"
        case colValue3 = "ColValue3"
        case colValue4 = "ColValue4"
    }
}



// MARK: - THangNhapDataResult
struct THangNhapDataResult: Decodable, Sendable, Identifiable {
    let colType: String
    let colGroup: String
    let colOrder: Int
    let colCode, colName: String?
    let colValue, colDataType: Int
    
    var id: String { "nhap-\(colType)-\(colGroup)-\(colCode ?? "")-\(colOrder)-\(colDataType)-\(colName ?? "")" }
    
    enum CodingKeys: String, CodingKey {
        case colType = "ColType"
        case colGroup = "ColGroup"
        case colOrder = "ColOrder"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue = "ColValue"
        case colDataType = "ColDataType"
    }
}



// MARK: - THangXuatDataResult
struct THangXuatDataResult: Decodable, Sendable, Identifiable {
    let colType: String
    let colGroup: String
    let colOrder: Int
    let colCode, colName: String?
    let colValue, colDataType: Int
    
    var id: String { "xuat-\(colType)-\(colGroup)-\(colCode ?? "")-\(colOrder)-\(colDataType)-\(colName ?? "")" }
    
    enum CodingKeys: String, CodingKey {
        case colType = "ColType"
        case colGroup = "ColGroup"
        case colOrder = "ColOrder"
        case colCode = "ColCode"
        case colName = "ColName"
        case colValue = "ColValue"
        case colDataType = "ColDataType"
    }
}

// MARK: - TNhanVien_DanhSach
struct TNhanVien_DanhSach: Decodable, Sendable, Identifiable {
    let emid, emHo, emTen, emHoTen: String
    let emTenGioiTinh, emNgaySinh, emDienThoai, emEmail: String
    let emcccdppSo, emTenPhongBanHH, emNgayBatDauHH: String
    let emDiaChi: String?
    var id: String { "nhanvien-\(String(describing: emid))-\(String(describing: emHoTen))" }
    
    enum CodingKeys: String, CodingKey {
        case emid = "EMID"
        case emHo = "EMHo"
        case emTen = "EMTen"
        case emHoTen = "EMHoTen"
        case emTenGioiTinh = "EMTenGioiTinh"
        case emNgaySinh = "EMNgaySinh"
        case emDienThoai = "EMDienThoai"
        case emEmail = "EMEmail"
        case emDiaChi = "EMDiaChi"
        case emcccdppSo = "EMCCCDPP_So"
        case emTenPhongBanHH = "EMTenPhongBanHH"
        case emNgayBatDauHH = "EMNgayBatDauHH"
    }
}

// MARK: - TNhanVien_ThongTin
struct TNhanVien_ThongTin: Decodable, Sendable {
    let emid, emHo, emTen: String?
    let emGioiTinh: Int?
    let emNgaySinh: String?
    let emDienThoai, emEmail, emDiaChiSoDuong, emDiaChiPhuongXa: String?
    let emDiaChiTenPhuongXa, emDiaChiTinhThanh, emDiaChiTenTinhThanh, emDiaChiQuocGia: String?
    let emDiaChiTenQuocGia, emcccdppSo: String?
    let emNgayBatDauHH: String?
    let emTenPhongBanHH: String?
    let ghiChu: String?
    
    enum CodingKeys: String, CodingKey {
        case emid = "EMID"
        case emHo = "EMHo"
        case emTen = "EMTen"
        case emGioiTinh = "EMGioiTinh"
        case emNgaySinh = "EMNgaySinh"
        case emDienThoai = "EMDienThoai"
        case emEmail = "EMEmail"
        case emDiaChiSoDuong = "EMDiaChi_SoDuong"
        case emDiaChiPhuongXa = "EMDiaChi_PhuongXa"
        case emDiaChiTenPhuongXa = "EMDiaChi_TenPhuongXa"
        case emDiaChiTinhThanh = "EMDiaChi_TinhThanh"
        case emDiaChiTenTinhThanh = "EMDiaChi_TenTinhThanh"
        case emDiaChiQuocGia = "EMDiaChi_QuocGia"
        case emDiaChiTenQuocGia = "EMDiaChi_TenQuocGia"
        case emcccdppSo = "EMCCCDPP_So"
        case emNgayBatDauHH = "EMNgayBatDauHH"
        case emTenPhongBanHH = "EMTenPhongBanHH"
        case ghiChu = "GhiChu"
    }
}

// MARK: - TXe_DanhSach
struct TXe_DanhSach: Decodable, Sendable, Identifiable {
    let ma, ten, loai: String
    let nhom, maTaiXe, taiXe: String?
    
    var id: String { "xe-\(String(describing: ma))-\(String(describing: ten))" }
    
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case loai = "Loai"
        case nhom = "Nhom"
        case maTaiXe = "MaTaiXe"
        case taiXe = "TaiXe"
    }
    
}


// MARK: - TXe_ThongTin
struct TXe_ThongTin: Decodable, Sendable {
    let ma, ten, loai, tenLoai: String
    let nhom, tenNhom: String?
    let taiXe, tenTaiXe: String
    let ghiChu: String?
    let ngayTAO: String
    let nguoiTAO, ngaySuaCuoi, nguoiSuaCuoi: String?
    
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case loai = "Loai"
        case tenLoai = "TenLoai"
        case nhom = "Nhom"
        case tenNhom = "TenNhom"
        case taiXe = "TaiXe"
        case tenTaiXe = "TenTaiXe"
        case ghiChu = "GhiChu"
        case ngayTAO = "NgayTao"
        case nguoiTAO = "NguoiTao"
        case ngaySuaCuoi = "NgaySuaCuoi"
        case nguoiSuaCuoi = "NguoiSuaCuoi"
    }
}
// MARK: - TKhachhang_DanhSach
struct TKhachhang_TDanhSach: Decodable, Sendable, Identifiable {
    let ma, ten: String
    let diaChi, mst: String?
    let dienThoai: String?
    let email: String?
    let loai: TKhachhang_Loai
    let nhom, ghiChu: String?
    
    var id: String { "khachhang-\(String(describing: ma))-\(String(describing: ten))" }
    
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case diaChi = "DiaChi"
        case mst = "MST"
        case dienThoai = "DienThoai"
        case email = "Email"
        case loai = "Loai"
        case nhom = "Nhom"
        case ghiChu = "GhiChu"
    }
}

enum TKhachhang_Loai: String, Codable {
    case kháchHàng = "Khách hàng"
    case nhàCungCấp = "Nhà cung cấp"
    case nhàCungCấpKháchHàng = "Nhà cung cấp + Khách hàng"
}

// MARK: - TKhachhang_ThongTin
struct TKhachhang_ThongTin: Decodable, Sendable {
    let ma, ten: String?
    let diaChi: String?
    let mst: String?
    let dienThoai, email: String?
    let loai, tenLoai: String?
    let nhom, tenNhom, ghiChu: String?
    let ngayTAO: String?
    let nguoiTAO, ngaySuaCuoi, nguoiSuaCuoi: String?
    
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case diaChi = "DiaChi"
        case mst = "MST"
        case dienThoai = "DienThoai"
        case email = "Email"
        case loai = "Loai"
        case tenLoai = "TenLoai"
        case nhom = "Nhom"
        case tenNhom = "TenNhom"
        case ghiChu = "GhiChu"
        case ngayTAO = "NgayTao"
        case nguoiTAO = "NguoiTao"
        case ngaySuaCuoi = "NgaySuaCuoi"
        case nguoiSuaCuoi = "NguoiSuaCuoi"
    }
}

// MARK: - THangHoa_DanhSach
struct THangHoa_DanhSach: Decodable, Sendable, Identifiable {
    let ma, ten: String
    let loai: String?
    let nhom: String?
    let dvt: String?
    let ghiChu: String?
    
    var id: String { "khachhang-\(String(describing: ma))-\(String(describing: ten))" }
    
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case loai = "Loai"
        case nhom = "Nhom"
        case dvt = "DVT"
        case ghiChu = "GhiChu"
    }
}




// MARK: - THangHoa_ThongTin
struct THangHoa_ThongTin: Codable {
    let ma, ten, loai, tenLoai: String?
    let nhom, tenNhom: String?
    let dvt: String?
    let ghiChu: String?
    let ngayTAO: String?
    let nguoiTAO, ngaySuaCuoi, nguoiSuaCuoi: String?
    
    enum CodingKeys: String, CodingKey {
        case ma = "Ma"
        case ten = "Ten"
        case loai = "Loai"
        case tenLoai = "TenLoai"
        case nhom = "Nhom"
        case tenNhom = "TenNhom"
        case dvt = "DVT"
        case ghiChu = "GhiChu"
        case ngayTAO = "NgayTao"
        case nguoiTAO = "NguoiTao"
        case ngaySuaCuoi = "NgaySuaCuoi"
        case nguoiSuaCuoi = "NguoiSuaCuoi"
    }
}



// MARK: - Phieuvc_Nhap_DanhSach
struct TPhieuvc_Giacong_DanhSach: Decodable, Sendable, Identifiable {
    let soPhieu: String
    let soPhieuInt: Int
    let ngay: String
    let xeNgoai: Bool
    let soXe: String?
    let taiXe: String?
    let khachHang: String?
    let tenKhachHang: String?
    let hangHoa: String
    let tenHangHoa: String
    let dvt: String?
    let trongLuongXe: Double
    let trongLuongHang: Double
    let hangHoaGC: String?
    let tenHangHoaGC: String?
    let dvtgc: String?
    let trongLuongHangGC: Double
    let hangHoaTV: String?
    let tenHangHoaTV: String?
    let dvttv: String?
    let trongLuongHangTV: Double
    let ghiChu: String?
    let trangThai: String?
    let tenTrangThai: String?
    
    var id: String { "\(taiXe ?? "")-\(soPhieu)-\(tenTrangThai ?? "")" }
    
    enum CodingKeys: String, CodingKey {
        case soPhieu = "SoPhieu"
        case soPhieuInt = "SoPhieuInt"
        case ngay = "Ngay"
        case xeNgoai = "XeNgoai"
        case soXe = "SoXe"
        case taiXe = "TaiXe"
        case khachHang = "KhachHang"
        case tenKhachHang = "TenKhachHang"
        case hangHoa = "HangHoa"
        case tenHangHoa = "TenHangHoa"
        case dvt = "DVT"
        case trongLuongXe = "TrongLuongXe"
        case trongLuongHang = "TrongLuongHang"
        case hangHoaGC = "HangHoaGC"
        case tenHangHoaGC = "TenHangHoaGC"
        case dvtgc = "DVTGC"
        case trongLuongHangGC = "TrongLuongHangGC"
        case hangHoaTV = "HangHoaTV"
        case tenHangHoaTV = "TenHangHoaTV"
        case dvttv = "DVTTV"
        case trongLuongHangTV = "TrongLuongHangTV"
        case ghiChu = "GhiChu"
        case trangThai = "TrangThai"
        case tenTrangThai = "TenTrangThai"
    }
    
    init(
        soPhieu: String = "",
        soPhieuInt: Int = 0,
        ngay: String = "",
        xeNgoai: Bool = false,
        soXe: String? = nil,
        taiXe: String? = nil,
        khachHang: String? = nil,
        tenKhachHang: String? = nil,
        hangHoa: String = "",
        tenHangHoa: String = "",
        dvt: String? = nil,
        trongLuongXe: Double = 0,
        trongLuongHang: Double = 0,
        hangHoaGC: String? = nil,
        tenHangHoaGC: String? = nil,
        dvtgc: String? = nil,
        trongLuongHangGC: Double = 0,
        hangHoaTV: String? = nil,
        tenHangHoaTV: String? = nil,
        dvttv: String? = nil,
        trongLuongHangTV: Double = 0,
        ghiChu: String? = nil,
        trangThai: String? = nil,
        tenTrangThai: String? = nil
    ) {
        self.soPhieu = soPhieu
        self.soPhieuInt = soPhieuInt
        self.ngay = ngay
        self.xeNgoai = xeNgoai
        self.soXe = soXe
        self.taiXe = taiXe
        self.khachHang = khachHang
        self.tenKhachHang = tenKhachHang
        self.hangHoa = hangHoa
        self.tenHangHoa = tenHangHoa
        self.dvt = dvt
        self.trongLuongXe = trongLuongXe
        self.trongLuongHang = trongLuongHang
        self.hangHoaGC = hangHoaGC
        self.tenHangHoaGC = tenHangHoaGC
        self.dvtgc = dvtgc
        self.trongLuongHangGC = trongLuongHangGC
        self.hangHoaTV = hangHoaTV
        self.tenHangHoaTV = tenHangHoaTV
        self.dvttv = dvttv
        self.trongLuongHangTV = trongLuongHangTV
        self.ghiChu = ghiChu
        self.trangThai = trangThai
        self.tenTrangThai = tenTrangThai
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.soPhieu = (try? container.decodeIfPresent(String.self, forKey: .soPhieu)) ?? ""
        self.soPhieuInt = (try? container.decodeIfPresent(Int.self, forKey: .soPhieuInt)) ?? 0
        self.ngay = (try? container.decodeIfPresent(String.self, forKey: .ngay)) ?? ""
        self.xeNgoai = (try? container.decodeIfPresent(Bool.self, forKey: .xeNgoai)) ?? false
        self.soXe = try? container.decodeIfPresent(String.self, forKey: .soXe)
        self.taiXe = try? container.decodeIfPresent(String.self, forKey: .taiXe)
        self.khachHang = try? container.decodeIfPresent(String.self, forKey: .khachHang)
        self.tenKhachHang = try? container.decodeIfPresent(String.self, forKey: .tenKhachHang)
        self.hangHoa = (try? container.decodeIfPresent(String.self, forKey: .hangHoa)) ?? ""
        self.tenHangHoa = (try? container.decodeIfPresent(String.self, forKey: .tenHangHoa)) ?? ""
        self.dvt = try? container.decodeIfPresent(String.self, forKey: .dvt)
        
        if let dXe = try? container.decodeIfPresent(Double.self, forKey: .trongLuongXe) {
            self.trongLuongXe = dXe
        } else if let iXe = try? container.decodeIfPresent(Int.self, forKey: .trongLuongXe) {
            self.trongLuongXe = Double(iXe)
        } else {
            self.trongLuongXe = 0
        }
        
        if let dHang = try? container.decodeIfPresent(Double.self, forKey: .trongLuongHang) {
            self.trongLuongHang = dHang
        } else if let iHang = try? container.decodeIfPresent(Int.self, forKey: .trongLuongHang) {
            self.trongLuongHang = Double(iHang)
        } else {
            self.trongLuongHang = 0
        }
        
        self.hangHoaGC = try? container.decodeIfPresent(String.self, forKey: .hangHoaGC)
        self.tenHangHoaGC = try? container.decodeIfPresent(String.self, forKey: .tenHangHoaGC)
        self.dvtgc = try? container.decodeIfPresent(String.self, forKey: .dvtgc)
        
        if let dGC = try? container.decodeIfPresent(Double.self, forKey: .trongLuongHangGC) {
            self.trongLuongHangGC = dGC
        } else if let iGC = try? container.decodeIfPresent(Int.self, forKey: .trongLuongHangGC) {
            self.trongLuongHangGC = Double(iGC)
        } else {
            self.trongLuongHangGC = 0
        }
        
        self.hangHoaTV = try? container.decodeIfPresent(String.self, forKey: .hangHoaTV)
        self.tenHangHoaTV = try? container.decodeIfPresent(String.self, forKey: .tenHangHoaTV)
        self.dvttv = try? container.decodeIfPresent(String.self, forKey: .dvttv)
        
        if let dTV = try? container.decodeIfPresent(Double.self, forKey: .trongLuongHangTV) {
            self.trongLuongHangTV = dTV
        } else if let iTV = try? container.decodeIfPresent(Int.self, forKey: .trongLuongHangTV) {
            self.trongLuongHangTV = Double(iTV)
        } else {
            self.trongLuongHangTV = 0
        }
        
        self.ghiChu = try? container.decodeIfPresent(String.self, forKey: .ghiChu)
        self.trangThai = try? container.decodeIfPresent(String.self, forKey: .trangThai)
        self.tenTrangThai = try? container.decodeIfPresent(String.self, forKey: .tenTrangThai)
    }
}

typealias TPhieuvc_Nhap_DanhSach = TPhieuvc_Giacong_DanhSach
typealias TPhieuvc_Xuat_DanhSach = TPhieuvc_Giacong_DanhSach






// MARK: - ============================================================
//               GENERIC API RESULT (server wrapper)
// MARK: - ============================================================

/// Wrapper generic khi server trả về { "Success": bool, "Data": T, "Message": "..." }
/// Nếu server của bạn trả thẳng array thì dùng [T] trực tiếp.
protocol APIBaseResponse {
    var DataError: Int { get }
    var DataErrorDescription: String? { get }
}

struct APIObjectResponse<T: Decodable>: Decodable, APIBaseResponse {
    let DataError: Int
    let DataErrorDescription: String?
    let DataResult: T?
}

struct APIListResponse<T: Decodable>: Decodable, APIBaseResponse {
    let DataError: Int
    let DataErrorDescription: String?
    let DataResults: [T]?
}

typealias ApiResult<T: Decodable> = APIObjectResponse<T>


