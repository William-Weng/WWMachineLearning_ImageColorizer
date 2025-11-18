//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2025/11/17.
//

import UIKit

// MARK: - CGContext
extension CGContext {
    
    /// 建立CGContext (根據色域處理 - RGB / MONO)
    /// - Parameters:
    ///   - size: CGSize
    ///   - image: UIImage
    /// - Returns: CGContext?
    static func _build(size: CGSize, image: UIImage) -> CGContext? {
                
        guard let image = image.cgImage,
              let colorSpace = image.colorSpace
        else {
            return nil
        }
        
        let imageSize = CGSize(width: Int(size.width), height: Int(size.height))
        
        var bytesPerPixel = -1
        var bytesPerRow = -1
        var bitsPerComponent = -1
        
        switch colorSpace.model {
        case .rgb: bytesPerPixel = 4; bytesPerRow = bytesPerPixel * Int(size.width); bitsPerComponent = 8
        case .monochrome: bytesPerPixel = 1; bytesPerRow = bytesPerPixel * Int(size.width); bitsPerComponent = image.bitsPerComponent
        default: return nil
        }
        
        return CGContext._build(with: image.bitmapInfo.rawValue, size: imageSize, pixelData: nil, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace)
    }
}

// MARK: - UIImage
extension UIImage {
    
    /// [根據色域改變圖片尺寸 - RGB / MONO](https://github.com/sgl0v/ImageColorizer)
    /// - Parameter size: CGSize
    /// - Returns: UIImage?
    func _resizedImage(with size: CGSize) -> UIImage? {
        
        var resizedImage: UIImage?
        
        guard let image = cgImage,
              let context = CGContext._build(size: size, image: self)
        else {
            return resizedImage
        }

        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: size))
        
        guard let scaledImage = context.makeImage() else { return nil }
        return UIImage(cgImage: scaledImage)
    }
}
