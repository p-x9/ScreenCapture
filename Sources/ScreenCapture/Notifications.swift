//
//  ScreenCapture.Notifications.swift
//  
//
//  Created by p-x9 on 2023/08/16.
//  
//

import Foundation

extension ScreenCapture {
    /// A notification that posts immediately prior to starting a recording.
    public static let willStartRecordingNotification = Notification.Name("com.p-x9.screencapture.willStartRecording")
    /// A notification that posts immediately after starting a recording.
    public static let didStartRecordingNotification = Notification.Name("com.p-x9.screencapture.didStartRecording")

    /// A notification that posts immediately prior to stopping a recording.
    public static let willStopRecordingNotification = Notification.Name("com.p-x9.screencapture.willStopRecording")
    /// A notification that posts immediately after stopping a recording.
    public static let didStopRecordingNotification = Notification.Name("com.p-x9.screencapture.didStopRecording")
}
