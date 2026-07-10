//
//  ERPTable.swift
//  VTS_STAFF
//
//  Created by viettas on 14/5/26.
//

import SwiftUI

// MARK: - Sort Direction

public enum ERPSortDirection {
    case none
    case ascending
    case descending
    
    mutating func toggle() {
        switch self {
        case .none: self = .ascending
        case .ascending: self = .descending
        case .descending: self = .none
        }
    }
}

// MARK: - Column Alignment

public enum ERPColumnAlignment {
    case leading
    case center
    case trailing
}

extension ERPColumnAlignment {
    public var swiftUI: Alignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

// MARK: - Column

public struct ERPColumn<Data>: Identifiable {
    public let id = UUID()
    public let title: AnyView
    public let key: String
    
    /// percent width (0 → 1) or absolute points (if scrollable horizontally)
    public let width: CGFloat?
    public let alignment: ERPColumnAlignment
    public let render: (Data, Int) -> AnyView
    
    /// nil = disable sort
    public let sorter: ((Data, Data) -> Bool)?
    
    /// nil = no footer
    public let footer: AnyView?
    public let color: Color?
    
    public init(
        title:  AnyView,
        key: String,
        width: CGFloat? = nil,
        alignment: ERPColumnAlignment = .leading,
        render: @escaping (Data, Int) -> AnyView,
        sorter: ((Data, Data) -> Bool)? = nil,
        footer: AnyView? = nil,
        color: Color? = nil
    ) {
        self.title = title
        self.key = key
        self.width = width
        self.alignment = alignment
        self.render = render
        self.sorter = sorter
        self.footer = footer
        self.color = color ?? .vtsBg
    }
}

// MARK: - Table

public struct ERPTable<Data: Identifiable>: View {
    
    public let dataSource: [Data]
    public let columns: [ERPColumn<Data>]
    public var onRowTap: ((Data) -> Void)?
    public var onRowLongPress: ((Data) -> Void)?
    public var onRowAction: ((VTSRowAction, Data) -> Void)?
    public var actions: [VTSRowAction] = [.xem, .sua, .xoa]
    
    @State private var selectedRow: Data.ID?
    @State private var sortColumn: UUID?
    @State private var sortDirection: ERPSortDirection = .ascending
    @State private var tableWidth: CGFloat = 375
    
    public var groupKey: ((Data) -> String)?
    public var isLoading: Bool = false
    public var loadDataIfNeeded: (() -> Void)?
    public var onRefresh: (() -> Void)?
    public var backgroundPreferenceValue: Color?
    
    public var showInternalLoadingOverlay: Bool = true
    public var customRowBuilder: ((Data, CGFloat) -> AnyView?)?
    public var customHeaderBuilder: ((CGFloat) -> AnyView?)?
    public var customFooterBuilder: (( CGFloat) -> AnyView?)?
    
    // Premium settings
    public var rowHeight: CGFloat? = nil
    public var disableVerticalScrolling: Bool = false
    
    @State private var animate = false
    @State private var isFirstAppear = true
    @State private var isScrolling = false
    @State private var scrollTimer: Timer?
    
    public init(
        dataSource: [Data],
        columns: [ERPColumn<Data>],
        defaultSortKey: String? = nil,
        defaultSortDirection: ERPSortDirection = .ascending,
        onRowTap: ((Data) -> Void)? = nil,
        onRowLongPress: ((Data) -> Void)? = nil,
        onRowAction: ((VTSRowAction, Data) -> Void)? = nil,
        actions: [VTSRowAction] = [.xem, .sua, .xoa],
        isLoading: Bool = false,
        loadDataIfNeeded: (() -> Void)? = nil,
        onRefresh: (() -> Void)? = nil,
        backgroundPreferenceValue: Color? = nil,
        groupKey: ((Data) -> String)? = nil,
        showInternalLoadingOverlay: Bool = true,
        customRowBuilder: ((Data, CGFloat) -> AnyView?)? = nil,
        customHeaderBuilder: ((CGFloat) -> AnyView?)? = nil,
        customFooterBuilder: ((CGFloat) -> AnyView?)? = nil,
        rowHeight: CGFloat? = nil,
        disableVerticalScrolling: Bool = false
    ) {
        self.dataSource = dataSource
        self.columns = columns
        self.onRowTap = onRowTap
        self.onRowLongPress = onRowLongPress
        self.onRowAction = onRowAction
        self.actions = actions
        self.isLoading = isLoading
        self.loadDataIfNeeded = loadDataIfNeeded
        self.onRefresh = onRefresh
        self.backgroundPreferenceValue = backgroundPreferenceValue ?? Color.vtsPrimary
        self.groupKey = groupKey
        self.showInternalLoadingOverlay = showInternalLoadingOverlay
        self.customRowBuilder = customRowBuilder
        self.customHeaderBuilder = customHeaderBuilder
        self.rowHeight = rowHeight
        self.disableVerticalScrolling = disableVerticalScrolling
        self.customFooterBuilder = customFooterBuilder
        
        if let defaultSortKey = defaultSortKey {
            let foundCol = columns.first(where: { $0.key == defaultSortKey })
            self._sortColumn = State(initialValue: foundCol?.id)
            self._sortDirection = State(initialValue: defaultSortDirection)
        }
    }
    
    // MARK: - Sorting
    
    private var sortedData: [Data] {
        guard let sortColumn = sortColumn,
              let column = columns.first(where: { $0.id == sortColumn }),
              let sorter = column.sorter,
              sortDirection != .none
        else { return dataSource }
        
        if let groupKey = groupKey {
            let groups = Dictionary(grouping: dataSource, by: groupKey)
            var result: [Data] = []
            
            for (_, items) in groups {
                let sorted = items.sorted {
                    sortDirection == .ascending ? sorter($0, $1) : sorter($1, $0)
                }
                result.append(contentsOf: sorted)
            }
            return result
        }
        
        return dataSource.sorted {
            sortDirection == .ascending ? sorter($0, $1) : sorter($1, $0)
        }
    }
    
    // MARK: - Body Layout
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Standard full-width layout
            header(tableWidth)
            
            if let customHeader = customHeaderBuilder?(tableWidth) {
                customHeader
            }
            
            if disableVerticalScrolling {
                VStack(spacing: 0) {
                    ForEach(Array(sortedData.enumerated()), id: \.element.id) { index, row in
                        rowView(row, index: index, fullWidth: tableWidth)
                            .frame(height: rowHeight)
                            .background(selectedRow == row.id ? Color.vtsPrimary.opacity(0.12) : (index % 2 == 0 ? Color.gray.opacity(0.15) : Color.clear))
                        Divider()
                    }
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(sortedData.enumerated()), id: \.element.id) { index, row in
                                    rowView(row, index: index, fullWidth: tableWidth)
                                        .frame(height: rowHeight)
                                        .offset(x: animate ? 0 : (isFirstAppear ? -80 : 80))
                                        .background(selectedRow == row.id ? Color.vtsPrimary.opacity(0.12) : (index % 2 == 0 ? Color.gray.opacity(0.15) : Color.clear))
                                        .opacity(animate ? 1 : 0)
                                        .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.04), value: animate)
                                    Divider()
                                }
                            }
                            .id("TOP")
                            
                            Color.clear
                                .frame(height: 0)
                                .id("BOTTOM")
                        }
                        .id(tableWidth)
                    }
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentOffset.y
                    } action: { oldValue, newValue in
                        guard !isFirstAppear else { return }
                        withAnimation(.smooth(duration: 0.2)) {
                            isScrolling = true
                        }
                        scrollTimer?.invalidate()
                        scrollTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                            withAnimation(.smooth(duration: 0.25)) {
                                isScrolling = false
                            }
                        }
                    }
                    .refreshable {
                        if let onRefresh = onRefresh {
                            onRefresh()
                        } else {
                            loadDataIfNeeded?()
                        }
                    }
                    .background(Color.white)
                    .overlay {
                        if isLoading && showInternalLoadingOverlay {
                            ProgressView("Đang tải dữ liệu...")
                        }
                    }
                    .allowsHitTesting(!isLoading)
                    .overlay(alignment: .bottomLeading) {
                        if isScrolling {
                            VStack(spacing: 12) {
                                floatingButton(icon: "arrow.up") {
                                    withAnimation(.smooth) {
                                        proxy.scrollTo("TOP", anchor: .top)
                                    }
                                }
                                floatingButton(icon: "arrow.down") {
                                    withAnimation(.smooth) {
                                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                                    }
                                }
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                    }
                }
                .onAppear {
                    animate = false
                    DispatchQueue.main.async {
                        animate = true
                    }
                    if isFirstAppear {
                        isFirstAppear = false
                    }
                }
            }
            
            
            if let customFooter = customFooterBuilder?(tableWidth) {
                customFooter
            }
            else {
                footer(tableWidth)
            }
            
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        tableWidth = geo.size.width
                    }
            }
        )
        .onAppear {
            loadDataIfNeeded?()
        }
    }
}

// MARK: - ERPTable Components & Helpers

private extension ERPTable {
    
    // MARK: Header
    func header(_ fullWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                headerCell(column, width: columnWidth(column, fullWidth))
            }
        }
        .background(backgroundPreferenceValue ?? Color.vtsPrimary)
        .frame(maxWidth: .infinity)
        
    }
    
    // MARK: Row
    func rowView(_ data: Data, index: Int, fullWidth: CGFloat) -> some View {
        let baseRow = Group {
            if let customView = customRowBuilder?(data, fullWidth) {
                customView
                    .font(.caption)
            } else {
                HStack(spacing: 0) {
                    ForEach(columns) { column in
                        rowCell(data, column: column, index: index, width: columnWidth(column, fullWidth))
                        
                    }
                }
            }
        }
            .frame(maxWidth: .infinity)
        
        let cell = Group {
            if onRowTap != nil || onRowLongPress != nil || onRowAction != nil {
                baseRow
                    .background(selectedRow == data.id ? Color.vtsPrimary.opacity(0.12) : Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedRow = data.id
                        onRowTap?(data)
                    }
                    .onLongPressGesture {
                        selectedRow = data.id
                        onRowLongPress?(data)
                    }
            } else {
                baseRow
            }
        }
        
        return Group {
            if let onRowAction = onRowAction {
                cell.contextMenu {
                    ForEach(actions, id: \.self) { action in
                        Button(role: action.isDestructive ? .destructive : .none) {
                            onRowAction(action, data)
                        } label: {
                            Label(action.label, systemImage: action.icon)
                        }
                    }
                }
            } else {
                cell
            }
        }
    }
    
    // MARK: Footer
    func footer(_ fullWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                footerCell(column, width: columnWidth(column, fullWidth))
            }
        }
        .background(backgroundPreferenceValue ?? Color.vtsPrimary)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    // MARK: Header Cell
    func headerCell(_ column: ERPColumn<Data>, width: CGFloat) -> some View {
        cell(width: width) {
            HStack(spacing: 4) {
                column.title
                    .font(.vtsTableHeader)
                if column.sorter != nil {
                    if let icon = sortIcon(column) {
                        Image(systemName: icon)
                            .font(.subheadline.bold())
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(width: width, alignment: .center)
            .background(Color.vtsPrimary.opacity(0.12))
            .lineLimit(2)
            .foregroundColor(Color.vtsBg)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard column.sorter != nil else { return }
            if sortColumn == column.id {
                sortDirection.toggle()
            } else {
                sortColumn = column.id
                sortDirection = .ascending
            }
        }
    }
    
    // MARK: Row Cell
    func rowCell(_ data: Data, column: ERPColumn<Data>, index: Int, width: CGFloat) -> some View {
        cell(width: width) {
            column.render(data, index)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .font(.vtsTableContent)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: column.alignment.swiftUI)
            //                .background(column.color)
                .border(Color.vtsBorder, width: 0.5)
            
        }
    }
    
    // MARK: Footer Cell
    func footerCell(_ column: ERPColumn<Data>, width: CGFloat) -> some View {
        cell(width: width) {
            Group {
                if let footer = column.footer {
                    footer
                } else {
                    Text("")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: column.alignment.swiftUI)
            .font(.vtsTableFooter)
            .foregroundColor(Color.vtsBg)
        }
    }
    
    // MARK: Column Helpers
    func columnWidth(_ column: ERPColumn<Data>, _ fullWidth: CGFloat) -> CGFloat {
        let totalPercent = columns.reduce(0) { $0 + ($1.width ?? 0) }
        let percent = (column.width ?? 0) / (totalPercent == 0 ? 1 : totalPercent)
        return fullWidth * percent
    }
    
    func sortIcon(_ column: ERPColumn<Data>) -> String? {
        guard sortColumn == column.id else {
            return nil
        }
        switch sortDirection {
        case .none:
            return nil
        case .ascending:
            return "arrow.down"
        case .descending:
            return "arrow.up"
        }
    }
    
    // MARK: Floating Button
    func floatingButton(icon: String, action: @escaping () -> Void) -> some View {
        Group {
            if #available(iOS 26.0, *) {
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.headline)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.glass)
            } else {
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.headline)
                        .frame(width: 52, height: 52)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Global Cell Builder

func cell<Content: View>(width: CGFloat, @ViewBuilder content: () -> Content) -> some View {
    content()
        .frame(width: width)
}

// MARK: - Models & Preview

struct User: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let address: String
}

struct ERPTable_Previews: PreviewProvider {
    
    static let dataSource: [User] = [
        User(name: "Mike", age: 32, address: "10 Downing Street"),
        User(name: "John", age: 42, address: "10 Downing Street 10 Downing Street 10 Downing Street"),
        User(name: "Anna", age: 28, address: "New York"),
        User(name: "David", age: 36, address: "California"),
    ]
    
    static let columns: [ERPColumn<User>] = [
        ERPColumn(
            title: AnyView(
                Text("Tên")
                
            ),
            key: "name",
            width: 0.3,
            alignment: .leading,
            render: { user, _ in
                AnyView(
                    Text(user.name)
                    
                )
            },
            sorter: { $0.name < $1.name },
            footer: AnyView(Text("Footer ffffffff")
                .padding(5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                            
            )
        ),
        
        ERPColumn(
            title: AnyView(
                Text("Tên")
                
            ),
            key: "age",
            width: 0.2,
            alignment: .center,
            render: { user, _ in
                AnyView(
                    Text("\(user.age)")
                    
                    
                )
            },
            sorter: { $0.age < $1.age },
            footer: AnyView(
                Text("Footer")
                
                
            )
        ),
        
        ERPColumn(
            title: AnyView(
                Text("Tên")
                
            ),
            key: "address",
            width: 0.5,
            alignment: .leading,
            render: { user, _ in
                AnyView(
                    Text(user.address)
                    
                )
            }
        )
    ]
    
    static var previews: some View {
        ERPTable(
            dataSource: dataSource,
            columns: columns,
            onRowTap: { row in
                print("Tapped:", row.name)
            },
            isLoading: false,
            loadDataIfNeeded: {
                print("Load data...")
            },
            backgroundPreferenceValue: Color(hex: "#003258"),
            rowHeight: nil,
            disableVerticalScrolling: false
        )
        
        .previewLayout(.sizeThatFits)
    }
}
