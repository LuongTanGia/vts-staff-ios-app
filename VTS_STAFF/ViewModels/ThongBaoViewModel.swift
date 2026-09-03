//
//  ThongBaoViewModel.swift
//  VTS_STAFF
//
//  Created by Antigravity on 13/08/2026.
//

import Foundation
import Combine

@MainActor
final class ThongBaoViewModel: ObservableObject {
    @Published var tuNgay: Date = Date()
    @Published var denNgay: Date = Date()
    @Published var searchText: String = ""
    
    @Published var state: VTSViewState<[TThongBao_DanhSach]> = .idle
    @Published var notifications: [TThongBao_DanhSach] = []
    
    @Published var isMsgTaoPhieuEnabled: Bool = true
    @Published var isMsgXoaPhieuEnabled: Bool = true
    @Published var isSettingsLoading: Bool = false
    
    private let service: ThongBaoService
    
    init(service: ThongBaoService? = nil) {
        self.service = service ?? .shared
    }
    
    var filteredNotifications: [TThongBao_DanhSach] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            return notifications
        }
        return notifications.filter { item in
            (item.tieuDe?.lowercased().contains(query) ?? false) ||
            (item.noiDung?.lowercased().contains(query) ?? false) ||
            item.ma.lowercased().contains(query)
        }
    }
    
    var unreadCount: Int {
        notifications.filter { $0.daDoc != true }.count
    }
    
    func loadNotifications() async {
        if case .loading = state { return }
        
        if case .success = state {
            // Retain UI state on pull-to-refresh
        } else {
            state = .loading
        }
        
        let dateFromStr = tuNgay.toAPIString
        let dateToStr = denNgay.toAPIString
        
        do {
            let res = try await service.danhSach(dateFrom: dateFromStr, dateTo: dateToStr)
            let items = res.DataResults ?? []
            self.notifications = items
            if items.isEmpty {
                self.state = .empty
            } else {
                self.state = .success(items)
            }
        } catch {
            if error.isNoDataError {
                self.notifications = []
                self.state = .empty
            } else {
                self.state = .failure(error.localizedDescription)
            }
        }
    }
    
    func markAsRead(ma: String) async {
        do {
            _ = try await service.capNhatTrangThaiDaDoc(ma: ma)
            if let index = notifications.firstIndex(where: { $0.ma == ma }) {
                let old = notifications[index]
                notifications[index] = TThongBao_DanhSach(
                    notificationID: old.notificationID,
                    actionDate: old.actionDate,
                    actionType: old.actionType,
                    msgTitle: old.msgTitle,
                    msgContent: old.msgContent,
                    msgDataType: old.msgDataType,
                    msgDataJSON: old.msgDataJSON,
                    isRead: true
                )
            }
        } catch {
            ErrorManager.shared.showError("Không thể cập nhật trạng thái đã đọc: \(error.localizedDescription)")
        }
    }
    
    func markAllAsRead() async {
        do {
            _ = try await service.capNhatTrangThaiDaDocTatCa(maThongBaos: [])
            notifications = notifications.map { item in
                TThongBao_DanhSach(
                    notificationID: item.notificationID,
                    actionDate: item.actionDate,
                    actionType: item.actionType,
                    msgTitle: item.msgTitle,
                    msgContent: item.msgContent,
                    msgDataType: item.msgDataType,
                    msgDataJSON: item.msgDataJSON,
                    isRead: true
                )
            }
            ErrorManager.shared.showSuccess("Đã đánh dấu đọc tất cả thông báo")
        } catch {
            ErrorManager.shared.showError("Lỗi cập nhật: \(error.localizedDescription)")
        }
    }
    
    func loadNotificationSettings() async {
        isSettingsLoading = true
        defer { isSettingsLoading = false }
        
        do {
            let taoRes = try await service.getMsgTaoPhieu()
            let xoaRes = try await service.getMsgXoaPhieu()
            
            // Check DataResult or server settings
            if let taoVal = taoRes.DataResult as? Bool {
                self.isMsgTaoPhieuEnabled = taoVal
            }
            if let xoaVal = xoaRes.DataResult as? Bool {
                self.isMsgXoaPhieuEnabled = xoaVal
            }
        } catch {
            // Keep default values if call fails
        }
    }
    
    func toggleMsgTaoPhieu(enabled: Bool) async {
        self.isMsgTaoPhieuEnabled = enabled
        do {
            _ = try await service.setMsgTaoPhieu(clientToken: nil, enabled: enabled)
            ErrorManager.shared.showSuccess("Đã cập nhật cài đặt thông báo tạo phiếu")
        } catch {
            ErrorManager.shared.showError("Không thể lưu cài đặt: \(error.localizedDescription)")
        }
    }
    
    func toggleMsgXoaPhieu(enabled: Bool) async {
        self.isMsgXoaPhieuEnabled = enabled
        do {
            _ = try await service.setMsgXoaPhieu(clientToken: nil, enabled: enabled)
            ErrorManager.shared.showSuccess("Đã cập nhật cài đặt thông báo xóa phiếu")
        } catch {
            ErrorManager.shared.showError("Không thể lưu cài đặt: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Navigation Target Parsing
    enum VoucherType {
        case nhap
        case xuat
        case giacong
    }

    struct VoucherNavigationTarget {
        let type: VoucherType
        let soPhieu: String
        let fromDate: Date
        let toDate: Date
    }

    private func parseDate(from string: String?) -> Date? {
        guard let str = string, !str.isEmpty else { return nil }
        if let d = Date.fromAPIString(str) { return d }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd"
        if let d = fmt.date(from: str) { return d }
        fmt.dateFormat = "dd/MM/yyyy"
        if let d = fmt.date(from: str) { return d }
        return nil
    }

    func parseVoucherTarget(from item: TThongBao_DanhSach) -> VoucherNavigationTarget? {
        let fullText = ((item.tieuDe ?? "") + " " + (item.noiDung ?? "")).uppercased()
        
        // Bỏ qua phiếu xoá
        if fullText.contains("XÓA") || fullText.contains("XOA") {
            return nil
        }
        
        // Regex tìm mã phiếu: PN.xxx, PX.xxx, PGC.xxx
        let pattern = #"(PN|PX|PGC)\.[A-Z0-9]+"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let range = NSRange(fullText.startIndex..<fullText.endIndex, in: fullText)
        
        guard let match = regex.firstMatch(in: fullText, options: [], range: range),
              let swiftRange = Range(match.range, in: fullText) else { return nil }
        
        let matchedStr = String(fullText[swiftRange])
        
        let notifDate = parseDate(from: item.actionDate ?? item.ngay) ?? tuNgay
        let fromDate = min(tuNgay, notifDate)
        let toDate = max(denNgay, notifDate)
        
        if matchedStr.hasPrefix("PN") {
            return VoucherNavigationTarget(type: .nhap, soPhieu: matchedStr, fromDate: fromDate, toDate: toDate)
        } else if matchedStr.hasPrefix("PX") {
            return VoucherNavigationTarget(type: .xuat, soPhieu: matchedStr, fromDate: fromDate, toDate: toDate)
        } else if matchedStr.hasPrefix("PGC") {
            return VoucherNavigationTarget(type: .giacong, soPhieu: matchedStr, fromDate: fromDate, toDate: toDate)
        }
        
        return nil
    }
}
