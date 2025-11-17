//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2025/11/17.
//

import UIKit

// MARK: - UIImage
extension UIImage {
    
    /// [根據色域改變圖片尺寸 - RGB / MONO](https://github.com/sgl0v/ImageColorizer)
    /// - Parameter size: CGSize
    /// - Returns: UIImage?
    func _resizedImage(with size: CGSize) -> UIImage? {
        
        var resizedImage: UIImage?
        
        guard let image = cgImage,
              let colorSpace = image.colorSpace
        else {
            return resizedImage
        }

        let imageSize = CGSize(width: Int(size.width), height: Int(size.height))

        switch colorSpace.model {
        case .rgb:
            
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * Int(size.width)
            let bitsPerComponent = 8
            
            let context = CGContext._build(with: image.bitmapInfo.rawValue, size: imageSize, pixelData: nil, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace)
            
            context?.interpolationQuality = .high
            context?.draw(image, in: CGRect(origin: .zero, size: size))
            
            guard let scaledImage = context?.makeImage() else { return nil }
            resizedImage = UIImage(cgImage: scaledImage)
            
        case .monochrome:
            
            let context = CGContext._build(with: image.bitmapInfo.rawValue, size: imageSize, pixelData: nil, bitsPerComponent: image.bitsPerComponent, bytesPerRow: Int(size.width), colorSpace: colorSpace)
            
            context?.interpolationQuality = .high
            context?.draw(image, in: CGRect(origin: .zero, size: size))
            
            guard let scaledImage = context?.makeImage() else { return nil }
            resizedImage = UIImage(cgImage: scaledImage)
            
        default: break
        }
        
        return resizedImage
    }
}
