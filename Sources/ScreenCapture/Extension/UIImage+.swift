//
//  UIImage+.swift
//  
//
//  Created by p-x9 on 2023/07/13.
//  
//

import UIKit

extension UIImage {
    convenience init(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        self.init(ciImage: ciImage)
    }
}
