//
//  ERPTableShowcaseView.swift
//  VTS_STAFF
//
//  Created by viettas on 22/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct TransportManifest: Identifiable {
    let id: String
    let plateNumber: String
    let customer: String
    let weight: Double
    let driver: String
    let status: String
}

struct ERPTableShowcaseView: View {
    @Environment(\.router) private var router
    
    @State private var searchText = ""
    @State private var selectedLayout = 0 // 0: Mặc định, 1: Cuộn ngang, 2: Cố định cột đầu
    
    // Danh sách dữ liệu mẫu đại diện cho các phiếu vận chuyển nội bộ
    private let mockManifests = [
        TransportManifest(id: "PN-001", plateNumber: "51A-123.45", customer: "Công ty Cát Tường", weight: 45.2, driver: "Nguyễn Văn An", status: "Hoàn thành"),
        TransportManifest(id: "PX-002", plateNumber: "29C-987.65", customer: "Doanh nghiệp Hùng Phát", weight: 32.0, driver: "Trần Thế Minh", status: "Đang xử lý"),
        TransportManifest(id: "PN-003", plateNumber: "43S-456.78", customer: "Hóa chất Đại Việt", weight: 18.5, driver: "Lê Hồng Quân", status: "Hoàn thành"),
        TransportManifest(id: "PX-004", plateNumber: "60H-222.11", customer: "Vật liệu Xây dựng Miền Nam", weight: 54.0, driver: "Phan Văn Đức", status: "Chờ duyệt"),
        TransportManifest(id: "PN-005", plateNumber: "51D-333.44", customer: "Logistics Toàn Cầu", weight: 27.8, driver: "Hoàng Minh Tuấn", status: "Đã huỷ"),
        TransportManifest(id: "PX-006", plateNumber: "36C-555.66", customer: "Nông sản Việt", weight: 12.3, driver: "Đỗ Gia Bảo", status: "Đang xử lý"),
        TransportManifest(id: "PN-007", plateNumber: "75A-777.88", customer: "Thép Thái Nguyên", weight: 62.5, driver: "Trịnh Quốc Việt", status: "Hoàn thành"),
        TransportManifest(id: "PX-008", plateNumber: "86C-888.99", customer: "Xi măng Hà Tiên", weight: 38.1, driver: "Vũ Tiến Dũng", status: "Chờ duyệt"),
        TransportManifest(id: "PN-009", plateNumber: "29H-111.22", customer: "Thủy sản Ngọc Hải", weight: 22.0, driver: "Ngô Quang Huy", status: "Đang xử lý"),
        TransportManifest(id: "PX-010", plateNumber: "51C-444.55", customer: "Gỗ xuất khẩu Phú Tài", weight: 41.6, driver: "Bùi Anh Tuấn", status: "Hoàn thành")
    ]
    
    // Dữ liệu sau lọc
    private var filteredManifests: [TransportManifest] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return mockManifests
        }
        return mockManifests.filter {
            $0.id.localizedCaseInsensitiveContains(searchText) ||
            $0.plateNumber.localizedCaseInsensitiveContains(searchText) ||
            $0.customer.localizedCaseInsensitiveContains(searchText) ||
            $0.driver.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // Tổng khối lượng tấn của dữ liệu đang hiển thị
    private var totalWeight: Double {
        filteredManifests.reduce(0) { $0 + $1.weight }
    }
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                // Thanh tìm kiếm & bộ lọc layout
                VStack(spacing: 12) {
                    VTSSearchBar(text: $searchText, placeholder: "Tìm kiếm mã phiếu, số xe, khách hàng...")
                    
                    Picker("Chế độ hiển thị", selection: $selectedLayout) {
                        Text("Cuộn dọc").tag(0)
                        Text("Không cuộn").tag(1)
                        Text("Tùy biến").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(Color.vtsBg)
                
                Divider()
                
                // Vùng hiển thị bảng dữ liệu ERP
                if filteredManifests.isEmpty {
                    VSpacer()
                    VTSEmptyState(
                        icon: "doc.text.magnifyingglass",
                        title: "Không tìm thấy kết quả",
                        subtitle: "Vui lòng nhập từ khóa khác"
                    )
                    VSpacer()
                } else {
                    if selectedLayout == 2 {
                        ERPTable(
                            dataSource: filteredManifests,
                            columns: tableColumns,
                            onRowTap: { row in
                                print("Đã chọn phiếu tùy biến: \(row.id)")
                            },
                            backgroundPreferenceValue: Color.vtsPrimary,
                            customRowBuilder: { item, width in
                                AnyView(
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text(item.id)
                                                .font(.vtsHeadline)
                                                .foregroundColor(.vtsPrimary)
                                            
                                            Text(item.plateNumber)
                                                .font(.vtsMono)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.vtsBgMid)
                                                .cornerRadius(4)
                                            
                                            Spacer()
                                            
                                            VTSPhieuStatusChip(trangThai: item.status)
                                        }
                                        
                                        HStack {
                                            Label(item.customer, systemImage: "building.2.fill")
                                                .font(.vtsCallout)
                                                .foregroundColor(.vtsTxtSecondary)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            
                                            Label(item.driver, systemImage: "person.circle.fill")
                                                .font(.vtsCallout)
                                                .foregroundColor(.vtsTxtSecondary)
                                                .lineLimit(1)
                                        }
                                        
                                        HStack {
                                            Text("Trọng lượng:")
                                                .font(.vtsCaption)
                                                .foregroundColor(.vtsTxtTertiary)
                                            Text(String(format: "%.1f tấn", item.weight))
                                                .font(.vtsCaption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.vtsWarning)
                                            
                                            Spacer()
                                            
                                            Text("Ước tính phí:")
                                                .font(.vtsCaption)
                                                .foregroundColor(.vtsTxtTertiary)
                                            // Sử dụng hàm format VND mới tạo
                                            Text(Double(item.weight * 500000).toVND())
                                                .font(.vtsCaption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.vtsSuccess)
                                        }
                                    }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.vtsSurface)
                                )
                            },
                            customHeaderBuilder: { width in
                                AnyView(
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.vtsPrimary)
                                        Text("Bố cục thẻ tùy biến & tự động ước tính phí (VND)")
                                            .font(.vtsCaption)
                                            .foregroundColor(.vtsTxtSecondary)
                                        Spacer()
                                        Text("Tổng: \(filteredManifests.count)")
                                            .font(.vtsCaption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.vtsPrimary)
                                    }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.vtsPrimary.opacity(0.08))
                                )
                            },
                            rowHeight: nil, // Tự động co dãn theo chiều cao của row tùy biến
                            disableVerticalScrolling: false
                        )
                    } else {
                        ERPTable(
                            dataSource: filteredManifests,
                            columns: tableColumns,
                            onRowTap: { row in
                                print("Đã chọn phiếu: \(row.id)")
                            },
                            backgroundPreferenceValue: Color.vtsPrimary,
                            rowHeight: nil,
                            disableVerticalScrolling: selectedLayout == 1
                        )
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Tính năng nâng cấp biểu mẫu",
            showLogout: false,
            leading: {
                Button {
                    router.dismissScreen()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.vtsPrimary)
                        .font(.title3)
                }
            },
            trailing: {
                EmptyView()
            },
            primaryAction: {
                EmptyView()
            }
        )
        .toolbar(.hidden, for: .tabBar)
    }
    
    // Cấu hình các cột động tùy biến theo chế độ cuộn
    private var tableColumns: [ERPColumn<TransportManifest>] {
        let isScroll = selectedLayout > 0
        
        return [
            ERPColumn(
                title: AnyView(Text("Mã Phiếu")),
                key: "id",
                width: isScroll ? 100 : 0.16,
                alignment: .center,
                render: { item, _ in
                    AnyView(
                        Text(item.id)
                            .fontWeight(.semibold)
                    )
                },
                sorter: { $0.id < $1.id },
                footer: AnyView(
                    Text("Tổng")
                        .frame(maxWidth: .infinity, alignment: .center)
                )
            ),
            ERPColumn(
                title: AnyView(Text("Số Xe")),
                key: "plate",
                width: isScroll ? 110 : 0.16,
                alignment: .leading,
                render: { item, _ in
                    AnyView(
                        Text(item.plateNumber)
                            .font(.vtsMono)
                    )
                },
                sorter: { $0.plateNumber < $1.plateNumber },
                footer: AnyView(
                    Text("\(filteredManifests.count) x")
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
            ),
            ERPColumn(
                title: AnyView(Text("Khách Hàng")),
                key: "customer",
                width: isScroll ? 200 : 0.22,
                alignment: .leading,
                render: { item, _ in
                    AnyView(
                        Text(item.customer)
                            .lineLimit(1)
                    )
                }
            ),
            ERPColumn(
                title: AnyView(Text("Tài Xế")),
                key: "driver",
                width: isScroll ? 140 : 0.18,
                alignment: .leading,
                render: { item, _ in
                    AnyView(
                        Text(item.driver)
                            .lineLimit(1)
                    )
                }
            ),
            ERPColumn(
                title: AnyView(Text("Tải Trọng")),
                key: "weight",
                width: isScroll ? 90 : 0.14,
                alignment: .trailing,
                render: { item, _ in
                    AnyView(
                        Text(String(format: "%.1f t", item.weight))
                            .fontWeight(.medium)
                    )
                },
                sorter: { $0.weight < $1.weight },
                footer: AnyView(
                    Text(String(format: "%.1f t", totalWeight))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                )
            ),
            ERPColumn(
                title: AnyView(Text("Trạng Thái")),
                key: "status",
                width: isScroll ? 110 : 0.14,
                alignment: .center,
                render: { item, _ in
                    AnyView(
                        VTSPhieuStatusChip(trangThai: item.status)
                    )
                }
            )
        ]
    }
}

fileprivate struct VSpacer: View {
    var body: some View {
        Spacer()
    }
}

#Preview {
    RouterView { _ in
        ERPTableShowcaseView()
    }
}
