import UIKit
import CoreMedia

@available(iOS 13.0, *)
public final class ScreenCapture {

    public struct State: Equatable {
        public var isRunning = false
        public var frameCount = 0

        var isWaitingFirstFrame: Bool {
            frameCount == 0
        }
    }

    public var isRunning: Bool {
        state.isRunning
    }

    public var state: State {
        _state
    }

    private var _state = State()

    private var size: CGSize
    private var scale: CGFloat
    private weak var window: UIWindow?
    private weak var windowScene: UIWindowScene?

    private var displayLink: CADisplayLink?

    private var movieWriter: MovieWriter?
    
    public init(for window: UIWindow) {
        self.window = window
        self.size = window.bounds.size
        self.scale = window.screen.scale
    }

    @available(iOS 13.0, *)
    public init(for scene: UIWindowScene) {
        self.windowScene = scene
        self.size = scene.screen.bounds.size
        self.scale = scene.screen.scale
    }

    public func start(outputURL: URL) throws {
        guard !isRunning else { return }

        let size = size.scaled(scale)

        self.movieWriter = .init(outputUrl: outputURL, size: size)

        try movieWriter?.start()

        self.displayLink = CADisplayLink(target: self, selector: #selector(captureFrame(_:)))
        self.displayLink?.add(to: .main, forMode: .common)

        self._state = State()
        self._state.isRunning = true
    }

    public func end() throws {
        if let displayLink,
           let movieWriter {
            displayLink.invalidate()

            let time = CMTimeAdd(movieWriter.currentTime, CMTime(seconds: displayLink.duration, preferredTimescale: 1_000_000))
            try movieWriter.end(at: time, waitUntilFinish: true)
        }

        self.displayLink = nil
        self.movieWriter = nil
        self._state.isRunning = false
    }

    @objc
    func captureFrame(_ link: CADisplayLink) {
        guard let movieWriter else { return }

        let buffer: CVPixelBuffer?
        
        if let windowScene {
            buffer = windowScene.cvPixelBuffer(size: size, scale: scale)
        } else if let window {
            buffer = window.cvPixelBuffer(scale: scale)
        } else {
            return
        }

        guard let buffer else { return }

        do {
            let timeOffset: CFTimeInterval = state.isWaitingFirstFrame ? 0 : link.duration
            let time = CMTimeAdd(movieWriter.currentTime, CMTime(seconds: timeOffset, preferredTimescale: 1_000_000))
            try movieWriter.write(buffer, at: time)
            _state.frameCount += 1
        } catch {
            print(error)
        }
    }
}
