//
//  UIImage+.swift
//  
//
//  Created by p-x9 on 2023/05/19.
//  
//

import UIKit

extension UIView {
    func cvPixelBuffer(scale: CGFloat = 1) -> CVPixelBuffer? {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary

        let width = Int(frame.width * scale)
        let height = Int(frame.height * scale)

        var buffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                            kCVPixelFormatType_32ARGB, options, &buffer)

        guard let buffer else { return nil }

        let lockFrags = CVPixelBufferLockFlags(rawValue: 0)

        CVPixelBufferLockBaseAddress(buffer, lockFrags)
        defer {
            CVPixelBufferUnlockBaseAddress(buffer, lockFrags)
        }

        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        guard let context else { return nil }

        context.translateBy(x: 0, y: bounds.size.height * scale)
        context.scaleBy(x: scale, y: -scale)

        layer.presentation()?.render(in: context)

        return  buffer
    }
}
