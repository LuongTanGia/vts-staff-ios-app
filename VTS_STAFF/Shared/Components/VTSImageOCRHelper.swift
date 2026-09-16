//
//  VTSImageOCRHelper.swift
//  VTS_STAFF
//
//  Created by Antigravity on 07/08/2026.
//

import UIKit
import Vision

struct VTSImageOCRHelper {
    /// Asynchronously extracts text from an image using Vision Framework (Vietnamese + English)
    static func performOCR(on image: UIImage) async -> String {
        let normalized = fixOrientation(image)
        guard let cgImage = normalized.cgImage else {
            return ""
        }
        
        return await withCheckedContinuation { continuation in
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { req, err in
                guard err == nil, let observations = req.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                let strings = observations.compactMap { $0.topCandidates(1).first?.string }
                let fullText = strings.joined(separator: " ")
                continuation.resume(returning: fullText)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            if #available(iOS 16.0, *) {
                request.recognitionLanguages = ["vi-VN", "en-US"]
            } else {
                request.recognitionLanguages = ["en-US"]
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: "")
                }
            }
        }
    }
    
    /// Trích xuất số lượng / khối lượng từ văn bản OCR
    static func extractQuantity(from text: String) -> Double? {
        guard !text.isEmpty else { return nil }
        let pattern = #"(?:TL|KL|Khối lượng|Trọng lượng|SL|Số lượng|Net|Gross|Tare|Weight)?\s*[:=]?\s*([0-9]{1,3}(?:[.,][0-9]{3})*(?:[.,][0-9]+)?|[0-9]+(?:[.,][0-9]+)?)\s*(?:kg|tấn|tan|g)?\b"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            for match in matches {
                if let range = Range(match.range(at: 1), in: text) {
                    let raw = String(text[range])
                    let cleanStr = raw.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
                    if let val = Double(cleanStr), val > 0 {
                        return val
                    }
                }
            }
        }
        return nil
    }
    
    private static func fixOrientation(_ img: UIImage) -> UIImage {
        if img.imageOrientation == .up { return img }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        img.draw(in: CGRect(origin: .zero, size: img.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? img
        UIGraphicsEndImageContext()
        return normalized
    }
}
