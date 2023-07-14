import UIKit
import CoreMedia
@_spi(AVKit) import MovieWriter

@available(iOS 13.0, *)
public final class ScreenCapture {

    public struct State: Equatable {
        /// A Boolean value that indicates whether ScreenCapture is recording.
        public var isRunning = false
        /// count of recorded frame
        public var frameCount = 0

        /// Recording start time
        /// In fact, the `CACurrentMediaTime` at the time the first frame is written is retained.
        public var recordStartedTime: CMTime = .zero

        /// Retains the size of the window or windowScene at the start of recording.
        /// The video will remain this size even if the screen is rotated.
        public var recordInitialSize: CGSize = .zero

        /// Screen orientation when recording starts
        public var recordInitialOrientation: UIInterfaceOrientation = .unknown

        /// A Boolean value that indicates whether first frame was recorded.
        var isWaitingFirstFrame: Bool {
            frameCount == 0
        }
    }

    /// A Boolean value that indicates whether ScreenCapture is recording.
    /// (eq. state.isRunning)
    public var isRunning: Bool {
        state.isRunning
    }

    /// recording state
    /// it's initialized when `start` method called.
    public var state: State {
        _state
    }

    private var _state = State()

    /// configuration of recording
    public let config: Configuration

    /// size of recording area
    private var size: CGSize {
        windowScene?.screen.bounds.size ?? window?.bounds.size ?? .zero
    }

    private var orientation: UIInterfaceOrientation {
        windowScene?.interfaceOrientation ?? window?.windowScene?.interfaceOrientation ?? .portrait
    }

    /// scale factor of recording area
    /// original pixel size is `size` x `scale`
    private var scale: CGFloat

    /// target window to be recorded
    /// Only either `window` or `windowScene` is set to a value.
    private weak var window: UIWindow?

    /// target windowScene to be recorded
    /// Only either `window` or `windowScene` is set to a value.
    private weak var windowScene: UIWindowScene?

    /// Used to periodically retrieve frames.
    private var displayLink: CADisplayLink?

    /// Write video files frame by frame
    private var movieWriter: MovieWriter?

    private let captureFrameQueue = DispatchQueue(label: "com.p-x9.screenCapture.captureFrame",
                                                  qos: .userInitiated,
                                                  target: .global(qos: .userInitiated))
    private let writeFrameQueue = DispatchQueue(label: "com.p-x9.screenCapture.writeFrame",
                                                qos: .userInitiated,
                                                attributes: .concurrent,
                                                target: .global(qos: .userInitiated))

    /// Initializers for recording a particular window
    /// - Parameters:
    ///   - window: target window to be recorded
    ///   - config: configuration of recording
    public init(for window: UIWindow, with config: Configuration = .default) {
        self.window = window
        self.scale = config.scale ?? window.screen.scale
        self.config = config
    }

    /// Initializer for all windows in a scene to be recorded.
    /// - Parameters:
    ///   - scene: target windowScene to be recorded
    ///   - config: configuration of recording
    @available(iOS 13.0, *)
    public init(for scene: UIWindowScene, with config: Configuration = .default) {
        self.windowScene = scene
        self.scale = config.scale ?? scene.screen.scale
        self.config = config
    }

    /// start recording
    /// - Parameter outputURL: output url of recorded video file
    public func start(outputURL: URL) throws {
        guard !isRunning else { return }

        let size = size.scaled(scale)

        self.movieWriter = .init(outputUrl: outputURL,
                                 size: size,
                                 codec: config.codec,
                                 fileType: config.fileType)

        try movieWriter?.start(waitFirstWriting: true)

        self.displayLink = CADisplayLink(target: self, selector: #selector(captureFrame(_:)))
        self.displayLink?.preferredFramesPerSecond = config.fps
        self.displayLink?.add(to: .main, forMode: .common)

        self._state = State()
        self._state.recordInitialSize = self.size
        self._state.recordInitialOrientation = orientation
        self._state.isRunning = true
    }

    /// end recording
    public func end() throws {
        if let displayLink,
           let movieWriter {
            displayLink.invalidate()

            try movieWriter.end(at: .current, waitUntilFinish: true)
        }

        self.displayLink = nil
        self.movieWriter = nil
        self._state.isRunning = false
    }

    /// Called on every frame update.
    /// - Parameter link: sender (displayLink)
    @objc
    func captureFrame(_ link: CADisplayLink) {
        guard let movieWriter else { return }

        captureFrameQueue.async {
            var buffer: CVPixelBuffer?

            DispatchQueue.main.sync {
                let angle = self.state.recordInitialOrientation.numberOfRightAngleRotations(to: self.orientation) ?? 0
                if let windowScene = self.windowScene {
                    buffer = windowScene.cvPixelBuffer(
                        size: self._state.recordInitialSize,
                        scale: self.scale,
                        rotate: angle,
                        pool: self.movieWriter?.adaptor?.pixelBufferPool
                    )
                } else if let window = self.window {
                    buffer = window.cvPixelBuffer(
                        size: self._state.recordInitialSize,
                        scale: self.scale,
                        rotate: angle,
                        pool: self.movieWriter?.adaptor?.pixelBufferPool
                    )
                } else {
                    return
                }
            }

            guard let buffer else { return }

            let currentTime: CMTime = .current
            if self.state.isWaitingFirstFrame {
                self._state.recordStartedTime = currentTime
            }

            self.writeFrameQueue.async {
                do {
                    guard movieWriter.isRunning else { return }
                    try movieWriter.writeFrame(buffer, at: currentTime)
                    self._state.frameCount += 1
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension ScreenCapture {
    /// capture window or windowScene and save as image file.
    /// - Parameter outputURL: output url of screenshot image file
    public func capture(outputURL: URL) throws {
        var buffer: CVPixelBuffer?

        let capture: () -> Void = {
            let angle = self.state.recordInitialOrientation.numberOfRightAngleRotations(to: self.orientation) ?? 0
            if let windowScene = self.windowScene {
                buffer = windowScene.cvPixelBuffer(
                    size: self.size,
                    scale: self.scale,
                    rotate: angle
                )
            } else if let window = self.window {
                buffer = window.cvPixelBuffer(
                    size: self.size,
                    scale: self.scale,
                    rotate: angle
                )
            }
        }

        if Thread.isMainThread {
            capture()
        } else {
            DispatchQueue.main.sync {
                capture()
            }
        }

        guard let buffer else { return }

        let image = UIImage(pixelBuffer: buffer)

        let options: Data.WritingOptions = [
            .atomic
        ]

        switch outputURL.lastPathComponent {
        case "png", "PNG":
            try image.pngData()?.write(to: outputURL, options: options)
        default:
            try image.jpegData(compressionQuality: 1.0)?.write(to: outputURL, options: options)
        }
    }
}
