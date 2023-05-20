//
//  ExampleApp.swift
//  Example
//
//  Created by p-x9 on 2023/05/20.
//  
//

import SwiftUI
import UIKit
import TouchTracker
import ScreenCapture

@main
struct ExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .touchTrack()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?
    var windowScene: UIWindowScene?

    var screenCapture: ScreenCapture?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        self.windowScene = windowScene
        self.window = windowScene.keyWindow

        let config = Configuration(codec: .h264, fileType: .mp4, fps: 60)
        screenCapture = .init(for: windowScene, with: config)
    }
}
