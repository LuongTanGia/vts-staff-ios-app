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
    // MARK: - UI Text Strings
    private enum Strings {
        static let toolbarTitle = "Chính sách & Điều khoản"
        static let pickerLabel = "Chính sách & Điều khoản"
        static let confirmBtn = "Tôi đã đọc và đồng ý điều khoản"
    }

    @Environment(\.router) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: PolicyTab
    var showAcceptButton: Bool = false
    var onAccept: (() -> Void)? = nil
    
    init(
        documentName: String = "terms",
        title: String = "Chính sách & Điều khoản",
        showAcceptButton: Bool = false,
        onAccept: (() -> Void)? = nil
    ) {
        _selectedTab = State(initialValue: documentName == "privacy" ? .privacy : .terms)
        self.showAcceptButton = showAcceptButton
        self.onAccept = onAccept
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
                
                // Footer nút xác nhận
                if showAcceptButton {
                    VStack(spacing: 10) {
                        Divider()
                        
                        VTSButton(
                            Strings.confirmBtn,
                            icon: "checkmark.circle.fill",
                            style: .primary,
                            size: .large
                        ) {
                            onAccept?()
                            dismiss()
                        }
                        .padding(.horizontal, VTSSpacing.xl)
                        .padding(.bottom, 8)
                    }
                    .background(Color.white.ignoresSafeArea(edges: .bottom))
                }
            }
        }
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: Strings.toolbarTitle,
            showLogout: false,
            isWhiteText: true,
        ) {
            Button {
                dismiss()
                router.dismissScreen()
            } label: {
                LucideIcon(showAcceptButton ? .x : .chevronLeft, size: 20, color: .white)
            }
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
