//
//  MovieWriter.swift
//  
//
//  Created by p-x9 on 2023/05/19.
//  
//

import Foundation
import AVFoundation
import CoreVideo

class MovieWriter {

    /// pixel size of recording area
    let size: CGSize

    /// output url of recorded video file
    let outputUrl: URL

    /// file type of recorded video file
    let fileType: AVFileType

    let outputSettings: [String: Any]
    let sourcePixelBufferAttributes: [String: Any]

    /// time in a recorded  video of the last frame written.
    private(set) var currentTime: CMTime = .zero

    /// A Boolean value that indicates whether MovieWriter is recording
    private(set) var isRunning = false

    private var videoWriter: AVAssetWriter?
    private var writerInput: AVAssetWriterInput?
    private var adaptor: AVAssetWriterInputPixelBufferAdaptor?

    init(outputUrl: URL,
         size: CGSize,
         codec: AVVideoCodecType = .h264,
         fileType: AVFileType = .mp4) {

        self.size = size
        self.outputUrl = outputUrl
        self.fileType = fileType

        self.outputSettings = [
            AVVideoCodecKey: codec,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]

        self.sourcePixelBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: size.width,
            kCVPixelBufferHeightKey as String: size.height
        ]
    }

    /// start video writing
    func start() throws {
        guard !isRunning else {
            throw MovieWriterError.alreadyRunning
        }

        self.videoWriter = try AVAssetWriter(url: outputUrl, fileType: fileType)

        guard let videoWriter else {
            throw MovieWriterError.failedToStart
        }

        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video,
                                             outputSettings: outputSettings)
        writerInput.expectsMediaDataInRealTime = true

        self.writerInput = writerInput

        self.adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )

        videoWriter.add(writerInput)

        if !videoWriter.startWriting() {
            throw MovieWriterError.failedToStart
        }
        videoWriter.startSession(atSourceTime: .zero)

        isRunning = true
    }

    /// end video writing
    func end(at time: CMTime, waitUntilFinish: Bool) throws {
        guard let writerInput, let videoWriter else { return }

        guard time >= currentTime else {
            throw MovieWriterError.invalidTime
        }

        writerInput.markAsFinished()
        videoWriter.endSession(atSourceTime: time)

        let semaphore = DispatchSemaphore(value: 0)

        videoWriter.finishWriting {
            semaphore.signal()
        }

        if !waitUntilFinish { semaphore.signal() }

        semaphore.wait()

        self.videoWriter = nil
        self.writerInput = nil
        self.adaptor = nil

        self.isRunning = false
    }

    /// write frame
    /// - Parameters:
    ///   - buffer: pixel buffer of frame
    ///   - time: time of frame in video
    func write(_ buffer: CVPixelBuffer, at time: CMTime) throws {
        guard isRunning,
              let adaptor else {
            throw MovieWriterError.notStarted
        }

        guard time >= currentTime else {
            throw MovieWriterError.invalidTime
        }

        guard adaptor.assetWriterInput.isReadyForMoreMediaData else {
            throw MovieWriterError.notReadyForWriteMoreData
        }

        if(!adaptor.append(buffer, withPresentationTime: time)) {
            throw MovieWriterError.failedToAppendBuffer
        }

        self.currentTime = time
    }
}
