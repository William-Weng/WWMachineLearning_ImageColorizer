//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2025/8/28.
//

import UIKit
import CoreML
import WWHUD
import WWMachineLearning_Resnet50
import WWMachineLearning_ImageColorizer

// MARK: - ViewController
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

