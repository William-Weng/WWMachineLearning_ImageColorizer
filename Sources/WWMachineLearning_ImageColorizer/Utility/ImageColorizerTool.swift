//
//  ImageColorizerTool.swift
//  Example
//
//  Created by William.Weng on 2025/8/28.
//

import UIKit
import CoreML
import WWMachineLearning_Resnet50

/// MARK: 處理圖片彩色化的功能
struct ImageColorizerTool {

    static public let shared = ImageColorizerTool()
    
    private init() {}
    
    /// 圖片彩色化
    /// - Parameters:
    ///   - model: MLModel
    ///   - inputImage: UIImage
    ///   - completion: Result<UIImage?, Error>
    func colorize(model: MLModel, image inputImage: UIImage, completion: @escaping (Result<UIImage?, Error>) -> Void)  {
        
        var rescaledImage: UIImage?
        
        guard let cgImage = inputImage.cgImage else { return }
        
        if (inputImage.scale != 1.0) { rescaledImage = inputImage._rescaled(1.0, orientation: inputImage.imageOrientation) }
        
        Task {
            let result = colorize(model: model, image: rescaledImage ?? inputImage)
            await MainActor.run { completion(result) }
        }
    }
}

/// MARK: - 主函式
private extension ImageColorizerTool {
    
    /// [圖片上色](https://www.onswiftwings.com/posts/image-colorization-coreml/)
    /// - Parameter inputImage: [UIImage](https://github.com/Vadbeg/colorization-coreml)
    /// - Returns: [Result<UIImage, Error>](https://github.com/sgl0v/ImageColorizer)
    func colorize(model: MLModel, image inputImage: UIImage) -> Result<UIImage?, Error> {
        
        do {
            let inputImageLab = try preProcess(inputImage: inputImage)
            let input = try coloriserInput(from: inputImageLab)
            let output = try model.prediction(from: input) // CoremlColorizer(configuration: MLModelConfiguration()).prediction(input: input)
            let outputImageLab = imageLab(from: output, inputImageLab: inputImageLab)
            let resultImage = try postProcess(inputImage: inputImage, outputLAB: outputImageLab)
            return .success(resultImage)
        } catch {
            return .failure(error)
        }
    }
}

/// MARK: - 小工具
private extension ImageColorizerTool {

    /// 將 Lab 色彩空間數據轉換為 Core ML 模型輸入格式 (由亮度l => 預測出a和b通道)
    /// - Parameter imageLab: Lab 色彩空間的圖像數據
    /// - Returns: Core ML 模型的輸入數據
    func coloriserInput(from imageLab: LabValues) throws -> MLDictionaryFeatureProvider {
        
        // 創建一個 MLMultiArray 來儲存模型的輸入數據
        let inputArray = try MLMultiArray(shape: Constants.coremlInputShape, dataType: MLMultiArrayDataType.float32)
        
        // 遍歷圖像的 L 通道（亮度），並將其填入 MLMultiArray
        imageLab.l.enumerated().forEach({ (idx, value) in
            let inputIndex = [NSNumber(value: 0), NSNumber(value: 0), NSNumber(value: idx / Constants.inputDimension), NSNumber(value: idx % Constants.inputDimension)]
            inputArray[inputIndex] = value as NSNumber
        })
        
        return try MLDictionaryFeatureProvider(dictionary: [Constants.inputKey: inputArray])  // CoremlColorizerInput(input1: inputArray)
    }

    /// 從 Core ML 模型輸出中提取 a 和 b 色彩通道，並與原始 L 通道結合 (原始圖片亮度 + 預測出的顏色值)
    /// - Parameters:
    ///   - colorizerOutput: Core ML 模型的輸出
    ///   - inputImageLab: 包含原始 L 通道的 Lab 數據
    /// - Returns: 包含 L、a、b 三個通道的完整 Lab 數據
    func imageLab(from colorizerOutput: MLFeatureProvider, inputImageLab: LabValues) -> LabValues {
        
        var a = [Float]()
        var b = [Float]()
        
        for idx in 0..<Constants.inputDimension * Constants.inputDimension {
            
            guard let featureValue = colorizerOutput.featureValue(for: Constants.outptKey),
                  let multiArrayValue = featureValue.multiArrayValue
            else {
                continue
            }
            
            let aIdx = [NSNumber(value: 0), NSNumber(value: 0), NSNumber(value: idx / Constants.inputDimension), NSNumber(value: idx % Constants.inputDimension)]
            let bIdx = [NSNumber(value: 0), NSNumber(value: 1), NSNumber(value: idx / Constants.inputDimension), NSNumber(value: idx % Constants.inputDimension)]
            
            let _a = multiArrayValue[aIdx].floatValue
            let _b = multiArrayValue[bIdx].floatValue

            a.append(_a)
            b.append(_b)
        }
        
        return LabValues(l: inputImageLab.l, a: a, b: b)
    }
    
    /// 先轉成圖片正規化後的LAB值 => (256 x 256)
    /// - Parameter inputImage: UIImage
    /// - Returns: LabValues
    func preProcess(inputImage: UIImage) throws -> LabValues {
        
        guard let normalizeImage = inputImage._resizedImage(with: Constants.inputSize),
              let lab = LCM2Utility.shared.labValues(cgImage: normalizeImage.cgImage, bundle: .module)
        else {
            throw WWMachineLearning.CustomError.preprocessFailure
        }
        
        return LabValues(l: lab[0], a: lab[1], b: lab[2])
    }
    
    /// 執行上色的功能
    /// - Parameters:
    ///   - inputImage: UIImage
    ///   - outputLAB: LabValues
    /// - Returns: UIImage
    func postProcess(inputImage: UIImage, outputLAB: LabValues) throws -> UIImage? {
        
        guard let image = LCM2Utility.shared.image(fromLabChannels: outputLAB.l, a: outputLAB.a, b: outputLAB.b, size: Constants.inputSize, bundle: .module),
              let resultImage = image._resizedImage(with: inputImage.size),
              let originalImage = inputImage._resizedImage(with: inputImage.size),
              let resultImageLab = LCM2Utility.shared.labValues(cgImage: resultImage.cgImage, bundle: .module),
              let originalImageLab = LCM2Utility.shared.labValues(cgImage: originalImage.cgImage, bundle: .module)
        else {
            throw WWMachineLearning.CustomError.preprocessFailure
        }
        
        let colorizerImage = LCM2Utility.shared.image(fromLabChannels: originalImageLab[0], a: resultImageLab[1], b: resultImageLab[2], size: inputImage.size, bundle: .module)
        
        return colorizerImage
    }
}
