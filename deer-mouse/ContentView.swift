//
//  ContentView.swift
//  deer-mouse
//
//  Created by Jesus Lopez on 4/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        VStack {
            CameraPreviewView(session: cameraManager.session)
                .frame(minWidth: 640, minHeight: 480) // Set a reasonable default size
                .onAppear {
                    cameraManager.checkPermissions() // Check permissions first
                    cameraManager.startSession()
                }
                .onDisappear {
                    cameraManager.stopSession()
                }

            // Add other UI elements here later if needed
            Text("Camera Feed")
                .padding(.top, 5)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
