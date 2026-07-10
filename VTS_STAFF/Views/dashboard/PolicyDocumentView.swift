//
//  PolicyDocumentView.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import SwiftfulRouting

struct PolicyDocumentView: View {
    @Environment(\.router) private var router
    let documentName: String
    let title: String
    
    var body: some View {
        VTSPageContainer {
            VTSHTMLViewer(fileName: documentName)
//                .ignoresSafeArea(edges: .bottom)
        }
        //        .navigationBarBackButtonHidden(true)
        .customToolbar(
            isPrimaryActionVisible: false,
            title: "",
            subtitle: "Chính sách & Điều khoản",
            showLogout: false
        )
        {
            
        }
        trailing: {
            EmptyView()
        }
        primaryAction: {
            EmptyView()
        }
//        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    RouterView { _ in
        PolicyDocumentView(documentName: "privacy", title: "Chính sách bảo mật")
    }
}
