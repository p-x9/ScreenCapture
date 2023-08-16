//
//  ScreenCapture.Notifications.swift
//  
//
//  Created by p-x9 on 2023/08/16.
//  
//

import Foundation

extension ScreenCapture {
    public static let willStartRecordingNotification = Notification.Name("com.p-x9.screencapture.willStartRecording")
    public static let didStartRecordingNotification = Notification.Name("com.p-x9.screencapture.didStartRecording")
    public static let willStopRecordingNotification = Notification.Name("com.p-x9.screencapture.willStopRecording")
    public static let didStopRecordingNotification = Notification.Name("com.p-x9.screencapture.didStopRecording")
}
