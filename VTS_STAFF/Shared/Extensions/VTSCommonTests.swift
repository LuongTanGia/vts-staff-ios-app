//
//  VTSCommonTests.swift
//  VTS_STAFF
//
//  Created on 2026-06-24.
//  Bộ kiểm thử Unit Test cho file VTSCommon.swift
//

#if canImport(XCTest)
import XCTest
@testable import VTS_STAFF

final class VTSCommonTests: XCTestCase {
    
    // MARK: - String Tests
    func testStringTrimming() {
        XCTAssertEqual("   hello   ".trimmed(), "hello")
        XCTAssertEqual("\nhello\n".trimmed(), "hello")
        XCTAssertEqual("   ".trimmed(), "")
    }
    
    func testStringIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("   ".isBlank)
        XCTAssertTrue("\n  \n".isBlank)
        XCTAssertFalse(" hello ".isBlank)
    }
    
    func testStringEmailValidation() {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertTrue("user.name+tag@sub.domain.vn".isValidEmail)
        XCTAssertFalse("plainaddress".isValidEmail)
        XCTAssertFalse("@missingusername.com".isValidEmail)
        XCTAssertFalse("username@.com".isValidEmail)
    }
    
    func testStringPhoneValidation() {
        XCTAssertTrue("0987654321".isValidVietnamesePhoneNumber)
        XCTAssertTrue("+84912345678".isValidVietnamesePhoneNumber)
        XCTAssertTrue("0355555555".isValidVietnamesePhoneNumber)
        XCTAssertFalse("123456789".isValidVietnamesePhoneNumber) // Thiếu số
        XCTAssertFalse("01234567890".isValidVietnamesePhoneNumber) // Quá 10 số (sau 0)
        XCTAssertFalse("02838220220".isValidVietnamesePhoneNumber) // Số bàn không khớp regex di động
    }
    
    func testStringRemoveDiacritics() {
        XCTAssertEqual("Tiếng Việt".removeDiacritics(), "Tieng Viet")
        XCTAssertEqual("Lê Hồng Quân".removeDiacritics(), "Le Hong Quan")
        XCTAssertEqual("đường đi".removeDiacritics(), "duong di")
        XCTAssertEqual("ĐỘC LẬP TỰ DO".removeDiacritics(), "DOC LAP TU DO")
    }
    
    func testStringToDate() {
        let dateStr = "2026-06-24 15:30:00"
        let date = dateStr.toDate(format: "yyyy-MM-dd HH:mm:ss")
        XCTAssertNotNil(date)
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 24)
        XCTAssertEqual(components.hour, 15)
        XCTAssertEqual(components.minute, 30)
    }
    
    func testStringToNumber() {
        XCTAssertEqual("123".toInt(), 123)
        XCTAssertEqual("  123  ".toInt(), 123)
        XCTAssertNil("123a".toInt())
        
        XCTAssertEqual("123.45".toDouble(), 123.45)
        XCTAssertEqual("123,45".toDouble(), 123.45) // Test dấu phẩy thập phân kiểu VN
        XCTAssertNil("abc".toDouble())
    }
    
    func testStringToJSON() {
        let dictJSON = "{\"id\":\"1\",\"name\":\"An\"}"
        let dict = dictJSON.toJSONDictionary()
        XCTAssertNotNil(dict)
        XCTAssertEqual(dict?["id"] as? String, "1")
        XCTAssertEqual(dict?["name"] as? String, "An")
        
        let arrayJSON = "[{\"id\":\"1\"},{\"id\":\"2\"}]"
        let array = arrayJSON.toJSONArray()
        XCTAssertNotNil(array)
        XCTAssertEqual(array?.count, 2)
        XCTAssertEqual(array?[1]["id"] as? String, "2")
    }
    
    // MARK: - Numeric Tests (VND Formatting)
    //    func testNumericToVND() {
    //        let amount1: Int = 1500000
    //        XCTAssertEqual(amount1.toVND(), "1.500.000 ₫")
    //        
    //        let amount2: Double = 500000.5
    //        XCTAssertEqual(amount2.toVND(), "500.000 ₫") // Làm tròn do tối đa 0 chữ số thập phân
    //        
    //        let amount3: Decimal = 12000000
    //        XCTAssertEqual(amount3.toVND(), "12.000.000 ₫")
    //    }
    //    
    //    func testNumericToFormattedString() {
    //        let number: Double = 1234567.89
    //        XCTAssertEqual(number.toFormattedString(), "1.234.567,89")
    //        
    //        let integer: Int = 1000000
    //        XCTAssertEqual(integer.toFormattedString(), "1.000.000")
    //    }
    
    // MARK: - Array Tests
    func testArraySafeSubscript() {
        let array = ["A", "B", "C"]
        XCTAssertEqual(array[safe: 0], "A")
        XCTAssertEqual(array[safe: 2], "C")
        XCTAssertNil(array[safe: -1])
        XCTAssertNil(array[safe: 3])
    }
    
    func testArrayChunked() {
        let array = [1, 2, 3, 4, 5]
        let chunks = array.chunked(into: 2)
        XCTAssertEqual(chunks.count, 3)
        XCTAssertEqual(chunks[0], [1, 2])
        XCTAssertEqual(chunks[1], [3, 4])
        XCTAssertEqual(chunks[2], [5])
    }
    
    func testArrayUnique() {
        let array = [1, 2, 2, 3, 1, 4]
        XCTAssertEqual(array.unique(), [1, 2, 3, 4])
    }
    
    struct TestItem {
        let id: String
        let score: Int
        let weight: Double
        let name: String
    }
    
    func testArrayObjectCalculations() {
        let items = [
            TestItem(id: "1", score: 80, weight: 1.5, name: "An"),
            TestItem(id: "2", score: 90, weight: 2.0, name: "Bình"),
            TestItem(id: "3", score: 70, weight: 2.5, name: "Cường")
        ]
        
        // Sum
        XCTAssertEqual(items.sum(by: \.score), 240)
        XCTAssertEqual(items.sum(by: \.weight), 6.0)
        
        // Average
        XCTAssertEqual(items.average(by: \.score), 80.0)
        XCTAssertEqual(items.average(by: \.weight), 2.0)
        
        // Min / Max
        XCTAssertEqual(items.min(by: \.score), 70)
        XCTAssertEqual(items.max(by: \.weight), 2.5)
    }
    
    func testArrayObjectSearchAndFilter() {
        let items = [
            TestItem(id: "1", score: 80, weight: 1.5, name: "Nguyễn Văn An"),
            TestItem(id: "2", score: 90, weight: 2.0, name: "Trần Lê Bình"),
            TestItem(id: "3", score: 70, weight: 2.5, name: "Lê Hồng Quân")
        ]
        
        // First where
        XCTAssertEqual(items.first(where: \.id, equals: "2")?.name, "Trần Lê Bình")
        
        // Sorted
        let sortedItems = items.sorted(by: \.score, ascending: true)
        XCTAssertEqual(sortedItems.map { $0.id }, ["3", "1", "2"])
        
        // Filter String containing (không dấu)
        let filtered1 = items.filtered(by: \.name, containing: "binh")
        XCTAssertEqual(filtered1.count, 1)
        XCTAssertEqual(filtered1[0].name, "Trần Lê Bình")
        
        let filtered2 = items.filtered(by: \.name, containing: "le")
        XCTAssertEqual(filtered2.count, 2) // "Trần Lê Bình" và "Lê Hồng Quân"
    }
    
    // MARK: - Dictionary Tests
    func testDictionaryToJSONAndObject() {
        struct MockUser: Codable, Equatable {
            let id: String
            let name: String
        }
        
        let dict: [String: Any] = ["id": "100", "name": "Nam"]
        
        let jsonStr = dict.toJSONString()
        XCTAssertNotNil(jsonStr)
        
        let user = dict.toObject(MockUser.self)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, "100")
        XCTAssertEqual(user?.name, "Nam")
        
        XCTAssertEqual(dict.get("id", default: "unknown"), "100")
        XCTAssertEqual(dict.get("age", default: 20), 20)
        
        XCTAssertEqual(Set(dict.allKeys), Set(["id", "name"]))
    }
    
    // MARK: - Array of Dictionaries Tests
    func testArrayOfDictionaries() {
        let list: [[String: Any]] = [
            ["name": "Táo", "price": 15000.0, "quantity": 5],
            ["name": "Lê", "price": 25000, "quantity": 2],
            ["name": "Cam Sành", "price": "18000", "quantity": 10] // Test chuỗi số
        ]
        
        // Sum & Average
        XCTAssertEqual(list.sum(for: "price"), 58000.0)
        XCTAssertEqual(list.sum(for: "quantity"), 17.0)
        XCTAssertEqual(list.average(for: "quantity"), 17.0 / 3.0, accuracy: 0.0001)
        
        // Min & Max
        XCTAssertEqual(list.min(for: "price"), 15000.0)
        XCTAssertEqual(list.max(for: "quantity"), 10.0)
        
        // Filter Equals
        let filtered1 = list.filtered(key: "quantity", equals: 2)
        XCTAssertEqual(filtered1.count, 1)
        XCTAssertEqual(filtered1[0]["name"] as? String, "Lê")
        
        // Filter Containing (không dấu)
        let filtered2 = list.filtered(key: "name", containing: "sanh")
        XCTAssertEqual(filtered2.count, 1)
        XCTAssertEqual(filtered2[0]["name"] as? String, "Cam Sành")
        
        // Sorted
        let sortedList = list.sorted(by: "price", ascending: true)
        XCTAssertEqual(sortedList[0]["name"] as? String, "Táo")
        XCTAssertEqual(sortedList[2]["name"] as? String, "Lê")
    }
}
#endif // canImport(XCTest)
