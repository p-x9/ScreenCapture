//
//  ContentView.swift
//  Example
//
//  Created by p-x9 on 2023/05/20.
//  
//

import SwiftUI
import AVKit
import ScreenCapture

struct ContentView: View {
    @State var isRecording = false
    @EnvironmentObject var sceneDelegate: SceneDelegate

    let outputURL: URL = {
        let tmp = FileManager.default.temporaryDirectory
        return tmp.appending(components: "output.mp4")
    }()

    var screenCapture: ScreenCapture? {
        sceneDelegate.screenCapture
    }

    @State var showPlayer = false

    var body: some View {
        NavigationView {
            VStack {
                Button(isRecording ? "Stop Recording" : "Start Recording") {
                    guard let screenCapture else { return }

                    if isRecording {
                        try? screenCapture.end()
                        showPlayer = true
                    } else {
                        removeFileIfExisted()
                        try? screenCapture.start(outputURL: outputURL)
                    }
                    isRecording = screenCapture.isRunning
                }
                .padding()

                List(0..<100) { i in
                    NavigationLink {
                        Text("Row \(i)")
                    } label: {
                        Text("Row \(i)")
                    }

                }
            }
            .onAppear {
                print(outputURL)
            }
            .sheet(isPresented: $showPlayer) {
                VideoPlayer(player: AVPlayer(url: outputURL))
            }
        }
    }

    func removeFileIfExisted() {
        guard FileManager.default.fileExists(atPath: outputURL.path()) else {
            return
        }
        try? FileManager.default.removeItem(at: outputURL)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
