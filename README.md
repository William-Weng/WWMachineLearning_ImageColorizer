# WWMachineLearning+ImageColorizer
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-16.0](https://img.shields.io/badge/iOS-16.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWMachineLearning_ImageColorizer) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

### [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- [Use the CoreML model to convert grayscale images into color images.](https://www.onswiftwings.com/posts/image-colorization-coreml/)
- [使用CoreML模型, 將灰階圖片轉成彩色圖片。](https://github.com/Vadbeg/colorization-coreml)

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)

```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWMachineLearning_ImageColorizer.git", .upToNextMajor(from: "1.0.2"))
]
```

https://github.com/user-attachments/assets/f1138d36-8345-4eef-b243-1cc97c868eb9

### [Function - 可用函式](https://github.com/sgl0v/ImageColorizer)
|函式|功能|
|-|-|
|loadModel(progress:completion:)|載入模型 (從快取 or 網路重新下載)|
|loadModel()|載入模型 (從快取 or 網路重新下載)|
|colorize(image:completion:)|使用ML模型將圖片彩色化|
|colorize(image:)|使用ML模型將圖片彩色化|

### Example
```swift
import UIKit
import CoreML
import WWHUD
import WWMachineLearning_Resnet50
import WWMachineLearning_ImageColorizer

final class ViewController: UIViewController {

    @IBOutlet weak var monoImageView: UIImageView!
    
    @IBAction func colorize(_ sender: UIButton) {
        
        Task {
            WWHUD.shared.display()
            
            _ = await WWMachineLearning.ImageColorizer.shared.loadModel()
            let colorizedResult = await WWMachineLearning.ImageColorizer.shared.colorize(image: monoImageView.image)
            try monoImageView.image = colorizedResult.get()
            
            WWHUD.shared.dismiss()
        }
    }
}
```
