# ScreenCapture

Library for recording window and windowScene.
</br>
It is possible to use this function even when screen recording is being performed by an iOS function or while screen sharing is in progress.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/ScreenCapture)](https://github.com/p-x9/ScreenCapture/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/ScreenCapture)](https://github.com/p-x9/ScreenCapture/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/ScreenCapture)](https://github.com/p-x9/ScreenCapture/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/ScreenCapture)](https://github.com/p-x9/ScreenCapture/)

## Document
### Instance
```swift
import ScreenCapture

// config for recording
let config = Configuration(
    codec: .h264,
    fileType: .mp4,
    fps: 60,
    scale: 2
)

// record all windows in a scene
let screenCapture = ScreenCapture(for: windowScene,
                                  with: config)

// record a particular window
let screenCapture = ScreenCapture(for: window,
                                  with: config)
```

### Start Recording
```swift
let tmpURL = FileManager.default.temporaryDirectory
let url = tmpURL.appending(components: UUID().uuidString + ".mp4")

try screenCapture.start(outputURL: url)
```

### End Recording
```swift
try screenCapture.end()
```


## License

ScreenCapture is released under the MIT License. See [LICENSE](./LICENSE)
