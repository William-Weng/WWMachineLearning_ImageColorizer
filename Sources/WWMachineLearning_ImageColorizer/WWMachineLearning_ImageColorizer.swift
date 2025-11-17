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
        
        public private(set) var model: MLModel?
        
        private let urlString = "https://github.com/William-Weng/WWMachineLearning_ImageColorizer/releases/download/1.0.0/CoremlColorizer.mlmodel"

        private init() {}
    }
}

// MARK: - 公開函數
public extension WWMachineLearning.ImageColorizer {
    
    /// [載入模型 (從快取 or 網路重新下載)](https://github.com/William-Weng/MLImageColorizer)
    /// - Parameters:
    ///   - folder: 下載資料夾
    ///   - configuration: ML模型設定
    ///   - progress: 下載進度
    ///   - completion: Result<URL, Error>
    func loadModel(folder: URL = .applicationDirectory, configuration: MLModelConfiguration = .init(), progress: ((WWNetworking.DownloadProgressInformation) -> Void)? = nil, completion: @escaping (Result<URL, Error>) -> Void) {
        
        WWMachineLearning.shared.loadModel(urlString: urlString, folder: folder, configuration: configuration) { downloadProgress in
            progress?(downloadProgress)
        } completion: { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let model, let url): self.model = model; completion(.success(url))
            }
        }
    }
    
    /// [使用ML模型將圖片彩色化](https://github.com/sgl0v/ImageColorizer)
    /// - Parameters:
    ///   - inputImage: UIImage
    ///   - completion: Result<UIImage?, Error>
    func colorize(image inputImage: UIImage?, completion: @escaping (Result<UIImage?, Error>) -> Void)  {
        
        guard let model else { completion(.failure(WWMachineLearning.CustomError.notModelLoaded)); return }
        guard let inputImage else { completion(.failure(WWMachineLearning.CustomError.isImageEmpty)); return }
        
        var rescaledImage: UIImage?
        
        if (inputImage.scale != 1.0) { rescaledImage = inputImage._rescaled(1.0, orientation: inputImage.imageOrientation) }
        
        DispatchQueue.global().async {
            ImageColorizerTool.shared.colorize(model: model, image: rescaledImage ?? inputImage) { result in
                DispatchQueue.main.async { completion(result) }
            }
        }
    }
    
    /// [載入模型 (從快取 or 網路重新下載)](https://github.com/Vadbeg/colorization-coreml)
    /// - Parameters:
    ///   - folder: 下載資料夾
    ///   - configuration: ML模型設定
    /// - Returns: AsyncThrowingStream<LoadModelEvent, Error>
    func loadModel(folder: URL = .applicationDirectory, configuration: MLModelConfiguration = .init()) async -> AsyncThrowingStream<LoadModelEvent, Error> {
        
        AsyncThrowingStream { continuation in
            
            loadModel(folder: folder, configuration: configuration, progress: { progress in
                continuation.yield(.progress(progress))
            }, completion: { result in
                switch result {
                case .success(let url): continuation.yield(.completion(url)); continuation.finish()
                case .failure(let error): continuation.finish(throwing: error)
                }
            })
        }
    }
    
    /// [使用ML模型將圖片彩色化](https://www.onswiftwings.com/posts/image-colorization-coreml/)
    /// - Parameters:
    ///   - inputImage: UIImage
    /// - Returns: Result<UIImage?, Error>
    func colorize(image inputImage: UIImage?) async -> Result<UIImage?, Error> {
        
        await withCheckedContinuation { continuation in
            colorize(image: inputImage) { continuation.resume(returning: $0) }
        }
    }
}



