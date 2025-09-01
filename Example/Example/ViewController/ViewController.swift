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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func colorize(_ sender: UIButton) {
        
        let image = monoImageView.image
        WWHUD.shared.display()
        
        Task {
            _ = await WWMachineLearning.ImageColorizer.shared.loadModel()
            let colorizedResult = await WWMachineLearning.ImageColorizer.shared.colorize(image: image!)
            
            try monoImageView.image = colorizedResult.get()
            WWHUD.shared.dismiss()
        }
    }
}
