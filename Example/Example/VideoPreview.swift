//
//  VideoPreview.swift
//  Example
//
//  Created by p-x9 on 2023/07/15.
//  
//

import SwiftUI
import AVKit

struct VideoPreview: View {
    let player: AVPlayer

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VideoPlayer(player: player)
                .navigationTitle("Video Preview")
                .navigationBarItems(trailing: closeButton)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    var closeButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
        }

    }
}
