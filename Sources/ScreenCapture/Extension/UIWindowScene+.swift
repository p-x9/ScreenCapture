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
    func cvPixelBuffer(
        size: CGSize,
        scale: CGFloat = 1,
        rotate: Int = 0,
        pool: CVPixelBufferPool? = nil
    ) -> CVPixelBuffer? {
        
        let options = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary

        let width = Int(size.width * scale)
        let height = Int(size.height * scale)

        var buffer: CVPixelBuffer? = nil
        if let pool {
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &buffer)
        } else {
            CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                kCVPixelFormatType_32ARGB, options, &buffer)
        }

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

        var rotate = rotate % 4
        if rotate < 0 { rotate += 4 }

        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.rotate(by: -CGFloat(rotate) * .pi / 2)

        switch rotate {
        case 0, 2:
            context.translateBy(x: -size.width / 2, y: -size.height / 2)
        case 1, 3:
            context.translateBy(x: -size.height / 2, y: -size.width / 2)
        default:
            break
        }

        windows
            .sorted(by: {
                $0.windowLevel < $1.windowLevel
            })
            .forEach {
                context.translateBy(x: $0.frame.minX, y: $0.frame.minY)
                $0.layer.presentation()?.render(in: context)
                context.translateBy(x: -$0.frame.minX, y: -$0.frame.minY)
            }

        return  buffer
    }
}
