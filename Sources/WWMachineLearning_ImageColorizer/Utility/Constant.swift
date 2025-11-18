//
//  Constant.swift
//  WWMachineLearning_ColorImage
//
//  Created by William.Weng on 2025/8/28.
//

import UIKit
import WWNetworking
import WWMachineLearning_Resnet50

/// MARK: 常數
extension ImageColorizerTool {
    
    /// MARK: static
    struct Constants {
        
        // model.modelDescription.inputDescriptionsByName => ["input1": input1 : MultiArray (Float32, 1 × 1 × 256 × 256)]
        static let inputKey = "input1"
        static let inputDimension = 256
        static let inputSize = CGSize(width: inputDimension, height: inputDimension)
        static let coremlInputShape = [1, 1, NSNumber(value: Constants.inputDimension), NSNumber(value: Constants.inputDimension)]

        // model.modelDescription.outputDescriptionsByName => ["796": 796 : MultiArray (Float32, )]
        static let outptKey = "796"
    }
}

public extension WWMachineLearning.ImageColorizer {
    
    /// 下載 / 載入模型事件
    enum LoadModelEvent {
        case progress(_ progress: WWNetworking.DownloadProgressInformation)
        case completion(_ url: URL)
    }
}
