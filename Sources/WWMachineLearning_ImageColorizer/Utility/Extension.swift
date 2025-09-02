//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2025/8/28.
//

import UIKit
import CoreGraphics

// MARK: - CGContext (static function)
extension CGContext {
    
    /// 建立Context
    /// - Parameters:
    ///   - info: UInt32
    ///   - size: CGSize
    ///   - pixelData: UnsafeMutableRawPointer?
    ///   - bitsPerComponent: Int
    ///   - bytesPerRow: Int
    ///   - colorSpace: CGColorSpace
    /// - Returns: CGContext?
    static func _build(with info: UInt32, size: CGSize, pixelData: UnsafeMutableRawPointer?, bitsPerComponent: Int, bytesPerRow: Int, colorSpace: CGColorSpace) -> CGContext? {
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: info)
        return context
    }
}

// MARK: - CGContext (function)
extension CGImage {
    
    /// 轉換圖片顏色組成 (1024色 => 256色)
    /// - Parameters:
    ///   - bitsPerComponent: 每一個顏色組件 =>（R, G, B, A）各用 8-bits 表示 (256色)
    ///   - bitsPerPixel: 顏色組成 =>R(8) + G(8) + B(8) + A(8) = 32-bits
    func _convertBitsPerComponent(_ bitsPerComponent: Int, bitsPerPixel: Int) -> CGImage? {
        
        let bytesPerRow = width * bitsPerPixel / 8
        let colorSpace = colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let rect = CGRect(x: 0, y: 0, width: width, height: height)

        guard let context = CGContext._build(with: bitmapInfo.rawValue, size: rect.size, pixelData: nil, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, colorSpace: colorSpace) else { return nil }
        
        context.draw(self, in: rect)
        return context.makeImage()
    }
}

// MARK: - UIGraphicsImageRendererFormat (function)
extension UIGraphicsImageRendererFormat {
    
    /// 設定比例
    /// - Parameter scale: 比例
    /// - Returns: Self
    func _scale(_ scale: CGFloat) -> Self {
        self.scale = scale
        return self
    }
    
    /// 透明度開關
    /// - Parameter opaque: Bool
    /// - Returns: Self
    func _opaque(_ opaque: Bool) -> Self {
        self.opaque = opaque
        return self
    }
}

// MARK: - UIImage (function)
extension UIImage {
    
    /// 改變圖片大小
    /// - Returns: UIImage
    /// - Parameters:
    ///   - size: 要改變的尺寸
    ///   - format: UIGraphicsImageRendererFormat
    func _resized(for size: CGSize, format: UIGraphicsImageRendererFormat) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let resizeImage = renderer.image { (context) in draw(in: renderer.format.bounds) }
        
        return resizeImage
    }
    
    /// 根據畫面比例重新調整圖片大小 => UIScreen.main.scale
    /// - Parameters:
    ///   - scale: CGFloat
    ///   - orientation: UIImage.Orientation
    /// - Returns: UIImage?
    func _rescaled(_ scale: CGFloat, orientation: UIImage.Orientation) -> UIImage? {
        
        guard let cgImage = self.cgImage else { return nil }
        
        let scaleImage = UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
        return scaleImage
    }
    
    /// 圖片標準化 (比例 / 大小 / 色深) => 模型處理用
    /// - Parameters:
    ///   - size: 大小
    ///   - bitsPerComponent: 每一個顏色組件 =>（R, G, B, A）各用 8 位表示 (256色)
    ///   - bitsPerPixel: 顏色組成 =>R(8) + G(8) + B(8) + A(8) = 32
    func _normalize(with size: CGSize, bitsPerComponent: Int, bitsPerPixel: Int) -> UIImage? {
        
        let format = UIGraphicsImageRendererFormat.default()._scale(1.0)
        let resizedImage = self._resized(for: size, format: format)
        
        guard let cgimage = resizedImage.cgImage?._convertBitsPerComponent(bitsPerComponent, bitsPerPixel: bitsPerPixel) else { return nil }
        
        return UIImage(cgImage: cgimage)
    }
    
    /// 將灰階色域 (Mono) 圖片轉換為彩色色域 (RGBA) 圖片
    /// - Returns: UIImage?
    func _monochromeColorSpaceToSRGB() -> UIImage? {
        guard let cgImage = cgImage?._monochromeColorSpaceToSRGB() else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - CGImage (function)
extension CGImage {
    
    /// 將灰階色域 (Mono) 圖片轉換為彩色色域 (RGBA) 圖片
    /// - Returns: CGImage?
    func _monochromeColorSpaceToSRGB() -> CGImage? {
        
        let size = CGSize(width: width, height: height)
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext._build(with: bitmapInfo, size: size, pixelData: nil, bitsPerComponent: 8, bytesPerRow: width * 4, colorSpace: CGColorSpaceCreateDeviceRGB()) else { return nil }
        
        context.draw(self, in: CGRect(origin: .zero, size: size))
        return context.makeImage()
    }
}
