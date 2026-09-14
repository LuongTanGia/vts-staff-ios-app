//
//  PolicyDocumentView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

enum PolicyTab: String, CaseIterable, Identifiable {
    case terms = "terms"
    case privacy = "privacy"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .terms: return "Điều khoản sử dụng"
        case .privacy: return "Chính sách bảo mật"
        }
    }
}

struct PolicyDocumentView: View {
    // MARK: - Strings
    private enum Strings {
        static let toolbarTitle = "Chính sách & Điều khoản"
        static let pickerLabel = "Chính sách & Điều khoản"
    }

    @Environment(\.router) private var router
    @State private var selectedTab: PolicyTab
    
    init(documentName: String = "terms", title: String = "Chính sách & Điều khoản") {
        _selectedTab = State(initialValue: documentName == "privacy" ? .privacy : .terms)
    }
    
    var body: some View {
        VTSPageContainer {
            VStack(spacing: 0) {
                // Segmented picker
                Picker(Strings.pickerLabel, selection: $selectedTab) {
                    ForEach(PolicyTab.allCases) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, VTSSpacing.xl)
                .padding(.vertical, 8)
                .background(Color.vtsPrimary)
                
                VTSHTMLViewer(fileName: selectedTab.rawValue)
                    .id(selectedTab.rawValue)
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: Strings.toolbarTitle,
            showLogout: false
        ) {
            EmptyView()
        } trailing: {
            EmptyView()
        } primaryAction: {
            EmptyView()
        }
    }
}

#Preview {
    RouterView { _ in
        PolicyDocumentView(documentName: "privacy", title: "Chính sách bảo mật")
    }
}
