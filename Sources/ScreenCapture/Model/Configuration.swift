//
//  Configuration.swift
//  
//
//  Created by p-x9 on 2023/05/20.
//  
//

import Foundation
import AVFoundation
import CoreVideo

public struct Configuration: Equatable {

    /// Codec of  output video
    public var codec: AVVideoCodecType

    /// File type of output video
    public var fileType: AVFileType

    /// Number of frames recorded per second.
    public var fps: Int

    /// scale factor of recording area
    /// If nil, the value of UIScreen.scale is used
    public var scale: CGFloat?

    public init(codec: AVVideoCodecType, fileType: AVFileType, fps: Int, scale: CGFloat? = nil) {
        self.codec = codec
        self.fileType = fileType
        self.fps = fps
        self.scale = scale
    }
}

extension Configuration {
    public static var `default`: Self {
        .init(codec: .h264, fileType: .mp4, fps: 60, scale: nil)
    }
}
