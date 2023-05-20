import UIKit
import CoreMedia

@available(iOS 13.0, *)
public final class ScreenCapture {

    public struct State: Equatable {
        /// A Boolean value that indicates whether ScreenCapture is recording.
        public var isRunning = false
        /// count of recorded frame
        public var frameCount = 0

        public var recordStartedTime: CMTime = .zero

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
    private var size: CGSize

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

    private let captureFrameQueue = DispatchQueue(label: "com.p-x9.screenCapture.captureFrame", target: .main)
    private let writeFrameQueue = DispatchQueue(label: "com.p-x9.screenCapture.writeFrame",
                                                qos: .userInteractive,
                                                attributes: .concurrent,
                                                autoreleaseFrequency: .workItem,
                                                target: .global(qos: .userInteractive))

    /// Initializers for recording a particular window
    /// - Parameters:
    ///   - window: target window to be recorded
    ///   - config: configuration of recording
    public init(for window: UIWindow, with config: Configuration = .default) {
        self.window = window
        self.size = window.bounds.size
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
        self.size = scene.screen.bounds.size
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

        try movieWriter?.start()

        self.displayLink = CADisplayLink(target: self, selector: #selector(captureFrame(_:)))
        self.displayLink?.preferredFramesPerSecond = config.fps
        self.displayLink?.add(to: .main, forMode: .common)

        self._state = State()
        self._state.isRunning = true
    }

    /// end recording
    public func end() throws {
        if let displayLink,
           let movieWriter {
            displayLink.invalidate()

            let currentTime: CMTime = .current(preferredTimescale: 1000)
            let time = currentTime - state.recordStartedTime
            try movieWriter.end(at: time, waitUntilFinish: true)
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
            let buffer: CVPixelBuffer?

            if let windowScene = self.windowScene {
                buffer = windowScene.cvPixelBuffer(size: self.size, scale: self.scale)
            } else if let window = self.window {
                buffer = window.cvPixelBuffer(scale: self.scale)
            } else {
                return
            }

            guard let buffer else { return }

            let currentTime: CMTime = .current(preferredTimescale: 1000)
            if self.state.isWaitingFirstFrame {
                self._state.recordStartedTime = currentTime
            }
            let time = currentTime - self.state.recordStartedTime
            self.writeFrameQueue.async {
                do {
                    try movieWriter.write(buffer, at: time)
                    self._state.frameCount += 1
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension CMTime {
    static func current(preferredTimescale: CMTimeScale) -> CMTime {
        CMTimeMakeWithSeconds(CACurrentMediaTime(), preferredTimescale: preferredTimescale)
    }
}
