
//
//  Date+VTS.swift
//  VTS_STAFF
//
//  Extension tiện lợi cho Date: format theo chuẩn API và hiển thị UI.
//

import Foundation

extension Date {
    
    // MARK: - API format: "yyyy-MM-dd'T'HH:mm:ss"
    var toAPIString: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = AppConfig.apiDateFormat
        return fmt.string(from: self)
    }
    
    /// Chỉ lấy phần ngày: "yyyy/MM/dd"
    var toDateOnlyString: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy/MM/dd"
        return fmt.string(from: self)
    }
    
    // MARK: - Hiển thị UI (Tiếng Việt)
    var toDisplayString: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "vi_VN")
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: self)
    }
    
    var toDisplayWithTimeString: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "vi_VN")
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt.string(from: self)
    }
    
    // MARK: - Parse từ string API
    static func fromAPIString(_ string: String) -> Date? {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = AppConfig.apiDateFormat
        if let d = fmt.date(from: string) { return d }
        // Thử thêm với milliseconds
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return fmt.date(from: string)
    }
    
    // MARK: - Helpers
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var comps = DateComponents()
        comps.day = 1
        comps.second = -1
        return Calendar.current.date(byAdding: comps, to: startOfDay)!
    }
    
    static func daysRange(from startDate: Date, to endDate: Date) -> (from: String, to: String) {
        return (startDate.toDateOnlyString, endDate.toDateOnlyString)
    }
    
    static var todayRange: (from: Date, to: Date) {
        let now = Date()
        return (now, now)
    }
    
    static func getWeekRange(offsetWeeks: Int) -> (from: Date, to: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: offsetWeeks, to: now) else {
            return (now, now)
        }
        
        let weekday = calendar.component(.weekday, from: targetDate)
        let daysToSubtract = (weekday == 1) ? 6 : (weekday - 2)
        
        guard let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: targetDate) else {
            return (now, now)
        }
        
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
        return (monday, sunday)
    }
}

extension String {
    var toUIDateString: String {
        if let date = Date.fromAPIString(self) {
            let fmt = DateFormatter()
            fmt.dateFormat = "dd/MM/yyyy"
            return fmt.string(from: date)
        }
        if self.contains("T") {
            let parts = self.components(separatedBy: "T")
            if let first = parts.first {
                let dateParts = first.components(separatedBy: "-")
                if dateParts.count == 3 {
                    return "\(dateParts[2])/\(dateParts[1])/\(dateParts[0])"
                }
            }
        }
        return self
    }
}

