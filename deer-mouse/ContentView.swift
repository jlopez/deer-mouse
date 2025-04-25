//
//  ContentView.swift
//  deer-mouse
//
//  Created by Jesus Lopez on 4/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()

    // Define a constant for the expected video preview size for scaling calculations
    // TODO: Ideally, get this dynamically from CameraManager or the video format.
    private let videoPreviewSize = CGSize(width: 1920, height: 1080)

    var body: some View {
        ZStack { // Use ZStack to overlay views
            CameraPreviewView(session: cameraManager.session)
                // Keep the frame for layout, but the overlay will use GeometryReader
                .frame(minWidth: 640, minHeight: 480)
                .onAppear {
                    cameraManager.checkPermissions() // Check permissions first
                    cameraManager.startSession()
                }
                .onDisappear {
                    cameraManager.stopSession()
                }

            // Add the overlay view on top
            FaceDetectionOverlayView(
                faceBoundingBoxes: cameraManager.faceBoundingBoxes,
                videoPreviewSize: videoPreviewSize // Pass the expected size
            )
            // Allow the overlay to take the same space as the preview
            .frame(minWidth: 640, minHeight: 480)

            // Optional: Add other UI elements here later if needed, potentially outside the ZStack or conditionally within it.
        }
        .padding() // Apply padding to the ZStack container
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
