//
//  ImagePreview.swift
//  Example
//
//  Created by p-x9 on 2023/07/15.
//  
//

import SwiftUI
import UIKit

struct ImagePreview: View {
    let image: Image

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                image
                    .resizable()
                    .scaledToFit()
            }
            .navigationTitle("Image Preview")
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
