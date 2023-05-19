//
//  UIWindowScene+.swift
//  
//
//  Created by p-x9 on 2023/05/20.
//  
//

import UIKit
import CoreVideo

@available(iOS 13.0, *)
extension UIWindowScene {
    func cvPixelBuffer(size: CGSize, scale: CGFloat = 1) -> CVPixelBuffer? {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary

        let width = Int(size.width * scale)
        let height = Int(size.height * scale)

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

        context.translateBy(x: 0, y: size.height * scale)
        context.scaleBy(x: scale, y: -scale)

        windows.forEach {
            context.translateBy(x: $0.frame.minX, y: $0.frame.minY)
            $0.layer.presentation()?.render(in: context)
        }

        return  buffer
    }
}
