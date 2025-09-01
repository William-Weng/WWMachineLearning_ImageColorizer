//
//  WWMachineLearning+ImageColorizer.swift
//  Example
//
//  Created by William.Weng on 2025/8/28.
//

import UIKit
import CoreML
import WWNetworking
import WWMachineLearning_Resnet50

// MARK: - WWMachineLearning.ImageColorizer
extension WWMachineLearning {
    
    public class ImageColorizer {
        
        public static let shared = ImageColorizer()
        
        private let modelUrlString = "https://github.com/William-Weng/WWMachineLearning_ImageColorizer/releases/download/1.0.0/CoremlColorizer.mlmodel"
        private var model: MLModel?

        private init() {}
    }
}

// MARK: - 公開函數
public extension WWMachineLearning.ImageColorizer {
    
    /// 載入模型 (從快取 or 網路重新下載)
    /// - Parameters:
    ///   - type: 模型類型
    ///   - progress: 下載進度
    ///   - completion: Result<URL, Error>
    func loadModel(progress: ((WWNetworking.DownloadProgressInformation) -> Void)? = nil, completion: @escaping (Result<URL, Error>) -> Void) {
                
        guard let modelUrl = URL(string: modelUrlString),
              let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else {
            return completion(.failure(WWMachineLearning.CustomError.notURL))
        }
        
        let compiledModelUrl = WWMachineLearning.shared.compiledModelUrl(modelUrl, for: folder)
        
        WWMachineLearning.shared.createFolder(folder)
        
        if FileManager.default._fileExists(with: compiledModelUrl).isExist {
            switch WWMachineLearning.shared.cacheModel(with: compiledModelUrl) {
            case .failure(let error): return completion(.failure(error))
            case .success(let model): self.model = model; return completion(.success(compiledModelUrl))
            }
        }
        
        WWMachineLearning.shared.downloadModel(modelUrl: modelUrl, folder: folder) { info in
            progress?(info)
        } completion: { downloadResult in
            switch downloadResult {
            case .failure(let error): completion(.failure(error))
            case .success(let model): self.model = model; completion(.success(compiledModelUrl))
            }
        }
    }
    
    /// 使用ML模型將圖片彩色化
    /// - Parameters:
    ///   - inputImage: UIImage
    ///   - completion: Result<UIImage?, Error>
    func colorize(image inputImage: UIImage, completion: @escaping (Result<UIImage?, Error>) -> Void)  {
        
        var rescaledImage: UIImage?
        if (inputImage.scale != 1.0) { rescaledImage = inputImage._rescaled(1.0, orientation: inputImage.imageOrientation) }
        
        guard let model else { return }
        
        DispatchQueue.global().async {
            ImageColorizerTool.shared.colorize(model: model, image: rescaledImage ?? inputImage) { DispatchQueue.main.async { completion($0) }}
        }
    }
    
    /// 載入模型 (從快取 or 網路重新下載)
    /// - Parameters:
    ///   - type: 模型類型
    /// - Returns: Result<URL, Error>
    func loadModel() async -> Result<URL, Error> {
        
        await withCheckedContinuation { continuation in
            loadModel() { continuation.resume(returning: $0) }
        }
    }
    
    /// 使用ML模型將圖片彩色化
    /// - Parameters:
    ///   - inputImage: UIImage
    /// - Returns: Result<UIImage?, Error>
    func colorize(image inputImage: UIImage) async -> Result<UIImage?, Error> {
        
        await withCheckedContinuation { continuation in
            colorize(image: inputImage) { continuation.resume(returning: $0) }
        }
    }
}



