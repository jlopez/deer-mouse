//
//  ContentView.swift
//  deer-mouse
//
//  Created by Jesus Lopez on 4/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    // Initialize calibrationViewModel in init to pass cameraManager
    @StateObject private var calibrationViewModel: CalibrationViewModel

    // Define a constant for the expected video preview size for scaling calculations
    // TODO: Ideally, get this dynamically from CameraManager or the video format.
    private let videoPreviewSize = CGSize(width: 1920, height: 1080) // Example size

    // Custom initializer
    init() {
        let manager = CameraManager()
        _cameraManager = StateObject(wrappedValue: manager)
        _calibrationViewModel = StateObject(wrappedValue: CalibrationViewModel(cameraManager: manager))
    }

    var body: some View {
        // --- UI Controls ---
        VStack {
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
                    gazeData: cameraManager.latestGazeData, // Pass the gaze data
                    videoPreviewSize: videoPreviewSize // Pass the expected size
                )
                // Allow the overlay to take the same space as the preview
                .frame(minWidth: 640, minHeight: 480)

                // --- Calibration Target Overlay ---
                if calibrationViewModel.isCalibrating {
                    if let targetPoint = calibrationViewModel.currentTargetPoint {
                        CalibrationTargetView(position: targetPoint)
                            // Ensure the target view covers the same area conceptually
                            .frame(minWidth: 640, minHeight: 480)
                            .allowsHitTesting(false) // Prevent target from blocking interactions if needed
                    } else {
                        // Optionally show a message when calibration is done but before isCalibrating is false
                        Text("Calibration Complete!")
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                // --- End Calibration Target Overlay ---

                // --- Gaze Indicator Overlay ---
                if !calibrationViewModel.isCalibrating, let estimatedPoint = cameraManager.estimatedScreenCoordinate {
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 20, height: 20)
                        .position(estimatedPoint) // Position based on estimated coordinates
                        // Ensure the indicator covers the same area conceptually
                        .frame(minWidth: 640, minHeight: 480)
                        .allowsHitTesting(false)
                }
                // --- End Gaze Indicator Overlay ---

            } // End ZStack
            .frame(minWidth: 640, minHeight: 480) // Ensure ZStack has a defined frame

            Spacer() // Push controls to the bottom
            HStack {
                Button("Start Calibration") {
                    calibrationViewModel.startCalibration()
                }
                .disabled(calibrationViewModel.isCalibrating) // Disable if already calibrating

                if calibrationViewModel.isCalibrating {
                    Button("Record Point") {
                        if let gazeData = cameraManager.latestGazeData {
                            calibrationViewModel.recordDataPoint(gazeData: gazeData)
                        } else {
                            print("Error: Cannot record point, latestGazeData is nil.")
                            // Optionally show an alert to the user
                        }
                    }
                    // Disable if no target point (calibration finished) or no gaze data yet
                    .disabled(calibrationViewModel.currentTargetPoint == nil || cameraManager.latestGazeData == nil)

                    Button("Cancel Calibration") {
                        calibrationViewModel.cancelCalibration()
                    }
                }
            }
            .padding() // Add padding around the buttons
        } // End VStack for controls
        // --- End UI Controls ---
    } // End body
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
