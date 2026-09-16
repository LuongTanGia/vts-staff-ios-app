//
//  VTSHTMLViewer.swift
//  VTS_STAFF
//
//  Created by viettas on 20/06/2026.
//

import SwiftUI
import WebKit

struct VTSHTMLViewer: UIViewRepresentable {
    let fileName: String
    let fileExtension: String = "html"
    let subdirectory: String = "ChinhSach"
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        // Cấu hình thanh cuộn hiển thị mượt mà
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        // Hỗ trợ scale trang web khớp màn hình di động
        webView.scrollView.bounces = true
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension, subdirectory: subdirectory) {
            let accessURL = url.deletingLastPathComponent()
            uiView.loadFileURL(url, allowingReadAccessTo: accessURL)
        } else {
            // Thử tìm ở thư mục gốc nếu không tìm thấy trong thư mục con
            if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
                let accessURL = url.deletingLastPathComponent()
                uiView.loadFileURL(url, allowingReadAccessTo: accessURL)
            } else {
                print("VTSHTMLViewer: Không tìm thấy tệp \(fileName).\(fileExtension)")
            }
        }
    }
}
