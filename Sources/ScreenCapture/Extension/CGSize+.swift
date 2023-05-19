//
//  CGImage+.swift
//  
//
//  Created by p-x9 on 2023/05/19.
//  
//

import CoreGraphics

extension CGSize {
    func scaled(_ factor: CGFloat) -> CGSize {
        .init(width: width * factor, height: height * factor)
    }
}
