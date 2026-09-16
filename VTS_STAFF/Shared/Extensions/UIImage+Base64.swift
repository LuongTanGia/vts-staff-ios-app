
//
//  UIImage+Base64.swift
//  VTS_STAFF
//
//  Encode/decode UIImage ↔ base64 string để gửi ảnh qua GuiAnh API.
//

import UIKit

extension UIImage {
    
    // MARK: - Encode sang base64 (nén JPEG)
    /// - Parameter quality: 0.0 → 1.0 (mặc định 0.7 để giảm kích thước)
    func toBase64(quality: CGFloat = 0.7) -> String? {
        guard let data = self.jpegData(compressionQuality: quality) else { return nil }
        return data.base64EncodedString()
    }
    
    // MARK: - Decode từ base64
    static func _fromBase64(_ string: String) -> UIImage? {
        guard let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) else { return nil }
        return UIImage(data: data)
    }
    
    // MARK: - Resize trước khi upload
    func resized(maxDimension: CGFloat = 1024) -> UIImage {
        let currentMax = max(size.width, size.height)
        guard currentMax > maxDimension else { return self }
        let scale = maxDimension / currentMax
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
