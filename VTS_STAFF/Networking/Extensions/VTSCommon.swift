//
//  VTSCommon.swift
//  VTS_STAFF
//
//  Created on 2026-06-24.
//  Tiện ích dùng chung (Common utilities) xử lý String, Number, Array, Object (Dictionary).
//

import Foundation

// MARK: - ============================================================
//                         NUMBER & CURRENCY FORMATTER
// MARK: - ============================================================

public protocol VTSNumeric {
    var doubleValue: Double { get }
}

extension Int: VTSNumeric { public var doubleValue: Double { Double(self) } }
extension Int64: VTSNumeric { public var doubleValue: Double { Double(self) } }
extension Double: VTSNumeric { public var doubleValue: Double { self } }
extension Float: VTSNumeric { public var doubleValue: Double { Double(self) } }
extension Decimal: VTSNumeric { public var doubleValue: Double { NSDecimalNumber(decimal: self).doubleValue } }

private struct VTSNumberFormatterCache {
    static let vndFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.currencySymbol = "₫" // Đảm bảo hiển thị ký hiệu đồng ₫
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0 // VND thông thường không có phần thập phân
        return formatter
    }()
    
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "vi_VN") // Định dạng VN: 1.234.567,89
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

public extension VTSNumeric {
    /// Định dạng số sang tiền VND (Ví dụ: 1000000 -> "1.000.000 ₫")
    func toVND() -> String {
        return VTSNumberFormatterCache.vndFormatter.string(from: NSNumber(value: self.doubleValue)) ?? "\(Int(self.doubleValue)) ₫"
    }
    
    /// Định dạng số thông thường với dấu phân cách hàng nghìn (Ví dụ: 1234567.89 -> "1.234.567,89")
    /// - Parameter maxDecimals: Số lượng chữ số sau dấu phẩy tối đa
    func toFormattedString(maxDecimals: Int = 2) -> String {
        let formatter = VTSNumberFormatterCache.decimalFormatter
        formatter.maximumFractionDigits = maxDecimals
        return formatter.string(from: NSNumber(value: self.doubleValue)) ?? "\(self.doubleValue)"
    }
}

// MARK: - ============================================================
//                               STRING
// MARK: - ============================================================

public extension String {
    /// Loại bỏ các khoảng trắng và dòng mới ở đầu/cuối chuỗi
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Kiểm tra chuỗi có trống hoặc chỉ chứa khoảng trắng/dòng mới hay không
    var isBlank: Bool {
        return self.trimmed().isEmpty
    }
    
    /// Kiểm tra xem chuỗi có phải là email hợp lệ
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    /// Kiểm tra xem chuỗi có phải là số điện thoại Việt Nam hợp lệ (10 số, bắt đầu bằng 0 hoặc +84)
    var isValidVietnamesePhoneNumber: Bool {
        let phoneRegex = "^(0|\\+84)(3|5|7|8|9)[0-9]{8}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePred.evaluate(with: self)
    }
    
    /// Chuyển đổi chuỗi tiếng Việt có dấu thành không dấu (Ví dụ: "Tiếng Việt" -> "Tieng Viet")
    func removeDiacritics() -> String {
        let mutableString = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
        return (mutableString as String)
            .replacingOccurrences(of: "đ", with: "d")
            .replacingOccurrences(of: "Đ", with: "D")
    }
    
    /// Trả về chuỗi đã viết thường và loại bỏ dấu tiếng Việt (phục vụ tìm kiếm không dấu)
    var normalized: String {
        return self.removeDiacritics().lowercased()
    }
    
    /// Parse chuỗi thành Date dựa vào format chỉ định
    /// - Parameter format: Định dạng ngày (Ví dụ: "yyyy-MM-dd HH:mm:ss")
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
    
    /// Ép kiểu an toàn sang Int
    func toInt() -> Int? {
        return Int(self.trimmed())
    }
    
    /// Ép kiểu an toàn sang Double
    func toDouble() -> Double? {
        // Hỗ trợ cả dấu chấm lẫn dấu phẩy trong chuỗi (ví dụ "123.45" hoặc "123,45")
        let cleanStr = self.trimmed().replacingOccurrences(of: ",", with: ".")
        return Double(cleanStr)
    }
    
    /// Parse JSON String thành Dictionary [String: Any]
    func toJSONDictionary() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
    
    /// Parse JSON String thành Array [[String: Any]]
    func toJSONArray() -> [[String: Any]]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]]
    }
    
    /// Định dạng chuỗi ngày ISO8601 (ví dụ: "1980-10-30T07:00:00+07:00") sang format hiển thị "30/10/1980"
    func toDisplayDate() -> String {
        let formatters: [DateFormatter] = {
            let f1 = DateFormatter()
            f1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            f1.locale = Locale(identifier: "en_US_POSIX")
            
            let f2 = DateFormatter()
            f2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            f2.locale = Locale(identifier: "en_US_POSIX")
            
            let f3 = DateFormatter()
            f3.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            f3.locale = Locale(identifier: "en_US_POSIX")
            
            return [f1, f2, f3]
        }()
        
        var date: Date? = nil
        for formatter in formatters {
            if let d = formatter.date(from: self) {
                date = d
                break
            }
        }
        
        if date == nil {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            date = isoFormatter.date(from: self)
        }
        
        guard let validDate = date else { return self }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        outputFormatter.locale = Locale(identifier: "vi_VN")
        return outputFormatter.string(from: validDate)
    }
}

// MARK: - ============================================================
//                               ARRAY
// MARK: - ============================================================

public extension Array {
    /// Lấy phần tử an toàn theo index (tránh crash khi out of bounds)
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// Chia mảng thành các mảng con với kích thước chỉ định
    /// Ví dụ: [1, 2, 3, 4, 5].chunked(into: 2) -> [[1, 2], [3, 4], [5]]
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    /// Nhóm các phần tử của mảng theo một thuộc tính cụ thể
    /// Ví dụ: users.grouped(by: \.role)
    func grouped<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        return Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }
    
    // MARK: - Calculations (Tính toán trên Mảng Object)
    
    /// Tính tổng các giá trị số từ thuộc tính của các đối tượng trong mảng
    /// Ví dụ: items.sum(by: \.price)
    func sum<T: Numeric>(by keyPath: KeyPath<Element, T>) -> T {
        return reduce(0) { $0 + $1[keyPath: keyPath] }
    }
    
    /// Tính trung bình cộng các giá trị số thực từ thuộc tính của các đối tượng trong mảng
    /// Ví dụ: items.average(by: \.score)
    func average<T: BinaryFloatingPoint>(by keyPath: KeyPath<Element, T>) -> T {
        guard !isEmpty else { return 0 }
        let total = reduce(0) { $0 + $1[keyPath: keyPath] }
        return total / T(count)
    }
    
    /// Tính trung bình cộng các giá trị số nguyên (trả về Double) từ thuộc tính của các đối tượng trong mảng
    func average<T: BinaryInteger>(by keyPath: KeyPath<Element, T>) -> Double {
        guard !isEmpty else { return 0 }
        let total = reduce(0) { $0 + Double($1[keyPath: keyPath]) }
        return total / Double(count)
    }
    
    /// Tìm giá trị nhỏ nhất của một thuộc tính trong mảng
    func min<T: Comparable>(by keyPath: KeyPath<Element, T>) -> T? {
        return map { $0[keyPath: keyPath] }.min()
    }
    
    /// Tìm giá trị lớn nhất của một thuộc tính trong mảng
    func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> T? {
        return map { $0[keyPath: keyPath] }.max()
    }
    
    // MARK: - Search & Filter (Tìm kiếm & Bộ lọc trên Mảng Object)
    
    /// Tìm đối tượng đầu tiên có thuộc tính khớp với giá trị mong muốn
    /// Ví dụ: users.first(where: \.id, equals: "U-001")
    func first<T: Equatable>(where keyPath: KeyPath<Element, T>, equals value: T) -> Element? {
        return first { $0[keyPath: keyPath] == value }
    }
    
    /// Sắp xếp mảng theo thuộc tính KeyPath
    /// Ví dụ: items.sorted(by: \.name, ascending: true)
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        return sorted {
            let a = $0[keyPath: keyPath]
            let b = $1[keyPath: keyPath]
            return ascending ? a < b : a > b
        }
    }
    
    /// Lọc mảng các đối tượng chứa thuộc tính String chứa từ khóa tìm kiếm (không phân biệt hoa thường, mặc định không dấu)
    /// Ví dụ: employees.filtered(by: \.name, containing: "tuấn")
    func filtered(by keyPath: KeyPath<Element, String>, containing query: String, ignoreDiacritics: Bool = true) -> [Element] {
        let cleanQuery = query.trimmed()
        guard !cleanQuery.isEmpty else { return self }
        
        let searchString = ignoreDiacritics ? cleanQuery.removeDiacritics().lowercased() : cleanQuery.lowercased()
        
        return filter {
            let value = $0[keyPath: keyPath]
            let targetString = ignoreDiacritics ? value.removeDiacritics().lowercased() : value.lowercased()
            return targetString.contains(searchString)
        }
    }
}

// MARK: - Operations on Array of Dictionary Objects [[String: Any]]
public extension Array where Element == [String: Any] {
    // MARK: - Calculations (Tính toán trên Mảng JSON/Dictionary)
    
    /// Tính tổng một key có kiểu số trong mảng các dictionary
    /// Ví dụ: items.sum(for: "price")
    func sum(for key: String) -> Double {
        return reduce(0.0) { result, dict in
            if let value = dict[key] as? Double {
                return result + value
            } else if let value = dict[key] as? Int {
                return result + Double(value)
            } else if let stringValue = dict[key] as? String, let value = stringValue.toDouble() {
                return result + value
            }
            return result
        }
    }
    
    /// Tính trung bình cộng một key trong mảng các dictionary
    func average(for key: String) -> Double {
        guard !isEmpty else { return 0.0 }
        return sum(for: key) / Double(count)
    }
    
    /// Tìm giá trị nhỏ nhất của một key kiểu số trong mảng các dictionary
    func min(for key: String) -> Double? {
        let values = compactMap { dict -> Double? in
            if let v = dict[key] as? Double { return v }
            if let v = dict[key] as? Int { return Double(v) }
            if let s = dict[key] as? String { return s.toDouble() }
            return nil
        }
        return values.min()
    }
    
    /// Tìm giá trị lớn nhất của một key kiểu số trong mảng các dictionary
    func max(for key: String) -> Double? {
        let values = compactMap { dict -> Double? in
            if let v = dict[key] as? Double { return v }
            if let v = dict[key] as? Int { return Double(v) }
            if let s = dict[key] as? String { return s.toDouble() }
            return nil
        }
        return values.max()
    }
    
    // MARK: - Search & Filter (Tìm kiếm & Bộ lọc trên Mảng JSON/Dictionary)
    
    /// Tìm kiếm và lọc mảng dictionary theo một key chứa từ khóa tìm kiếm (không phân biệt hoa thường, mặc định không dấu)
    /// Ví dụ: list.filtered(key: "name", containing: "nam")
    func filtered(key: String, containing query: String, ignoreDiacritics: Bool = true) -> [[String: Any]] {
        let cleanQuery = query.trimmed()
        guard !cleanQuery.isEmpty else { return self }
        
        let searchString = ignoreDiacritics ? cleanQuery.removeDiacritics().lowercased() : cleanQuery.lowercased()
        
        return filter { dict in
            guard let value = dict[key] else { return false }
            let valueStr = String(describing: value)
            let targetString = ignoreDiacritics ? valueStr.removeDiacritics().lowercased() : valueStr.lowercased()
            return targetString.contains(searchString)
        }
    }
    
    /// Lọc mảng dictionary với điều kiện so sánh bằng dưới dạng chuỗi (Ví dụ: list.filtered(key: "status", equals: "Hoàn thành"))
    func filtered(key: String, equals value: Any) -> [[String: Any]] {
        let valStr = String(describing: value)
        return filter { dict in
            guard let val = dict[key] else { return false }
            return String(describing: val) == valStr
        }
    }
    
    /// Sắp xếp mảng dictionary theo một key kiểu số hoặc kiểu chuỗi
    func sorted(by key: String, ascending: Bool = true) -> [[String: Any]] {
        return sorted { dict1, dict2 in
            let v1 = dict1[key]
            let v2 = dict2[key]
            
            if let n1 = v1 as? Double, let n2 = v2 as? Double {
                return ascending ? n1 < n2 : n1 > n2
            }
            if let n1 = v1 as? Int, let n2 = v2 as? Int {
                return ascending ? n1 < n2 : n1 > n2
            }
            
            // So sánh chuỗi mặc định
            let s1 = String(describing: v1 ?? "")
            let s2 = String(describing: v2 ?? "")
            return ascending ? s1.localizedCompare(s2) == .orderedAscending : s1.localizedCompare(s2) == .orderedDescending
        }
    }
}

public extension Array where Element: Hashable {
    /// Loại bỏ các phần tử trùng lặp mà vẫn giữ nguyên thứ tự ban đầu
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - ============================================================
//                         OBJECT (DICTIONARY)
// MARK: - ============================================================

public extension Dictionary where Key == String, Value == Any {
    /// Chuyển đổi Dictionary sang JSON String
    /// - Parameter prettyPrint: Định dạng đẹp mắt (có tab thụt đầu dòng) hay không
    func toJSONString(prettyPrint: Bool = false) -> String? {
        guard let data = self.toData(prettyPrint: prettyPrint) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Chuyển đổi Dictionary sang Data
    func toData(prettyPrint: Bool = false) -> Data? {
        let options: JSONSerialization.WritingOptions = prettyPrint ? [.prettyPrinted] : []
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    /// Decode Dictionary sang một Codable Object cụ thể
    func toObject<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = self.toData() else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    /// Lấy giá trị an toàn với kiểu dữ liệu mong muốn hoặc trả về giá trị mặc định
    func get<T>(_ key: String, default defaultValue: T) -> T {
        return (self[key] as? T) ?? defaultValue
    }
    
    /// Lấy danh sách tất cả các key dưới dạng một mảng [String]
    var allKeys: [String] {
        return Array(self.keys)
    }
}
