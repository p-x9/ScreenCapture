import UIKit
import CoreMedia

public final class ScreenCapture {

    public var isRunning = false

    private weak var window: UIWindow?

    private var displayLink: CADisplayLink?

    private var movieWriter: MovieWriter?
    
    public init(for window: UIWindow) {
        self.window = window
    }

    public func start(outputURL: URL) throws {
        guard !isRunning, let window else { return }

        let scale = window.screen.scale
        let size = window.bounds.size.scaled(scale)

        self.movieWriter = .init(outputUrl: outputURL, size: size)

        try movieWriter?.start()

        self.displayLink = CADisplayLink(target: self, selector: #selector(captureFrame(_:)))
        self.displayLink?.add(to: .main, forMode: .common)

        self.isRunning = true
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
        self.isRunning = false
    }

    @objc
    func captureFrame(_ link: CADisplayLink) {
        guard let window else { return }
        guard let buffer = window.cvPixelBuffer(scale: window.screen.scale),
              let movieWriter = movieWriter else {
            return
        }
        do {
            let time = CMTimeAdd(movieWriter.currentTime, CMTime(seconds: link.duration, preferredTimescale: 1_000_000))
            try movieWriter.write(buffer, at: time)
        } catch {
            print(error)
        }
    }
}
