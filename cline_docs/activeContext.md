# Active Context: Eye Gaze Mouse Control

## Current Focus

Implementing **Step 3: Detect Facial Landmarks (Pupils & Pose)** of Phase 1 (Vision & Data Acquisition).

## Recent Changes

-   **Completed Step 2: Detect Faces:**
    -   Modified `CameraManager` to conform to `AVCaptureVideoDataOutputSampleBufferDelegate`.
    -   Added `AVCaptureVideoDataOutput` and configured it in `setupSession`.
    -   Implemented `captureOutput` delegate method to process `CMSampleBuffer`.
    -   Used `VNSequenceRequestHandler` and `VNDetectFaceRectanglesRequest` to detect faces.
    -   Converted `VNFaceObservation.boundingBox` (normalized, bottom-left origin) to `CGRect` (pixels, top-left origin) suitable for SwiftUI.
    -   Added `@Published var faceBoundingBoxes: [CGRect]` to `CameraManager`.
    -   Created `FaceDetectionOverlayView.swift` using `Canvas` to draw bounding boxes, scaling them relative to a `videoPreviewSize`.
    -   Integrated `FaceDetectionOverlayView` into `ContentView` using a `ZStack`.
-   **Fixed Bounding Box Mirroring:** Adjusted the `x` coordinate calculation in `CameraManager`'s `captureOutput` method to account for the mirrored camera preview, ensuring bounding boxes align correctly horizontally.
-   Updated Memory Bank (`progress.md`, `activeContext.md`).

## Next Steps

1.  **Implement Step 3: Detect Facial Landmarks (Pupils & Pose):**
    *   Modify the Vision request in `CameraManager` from `VNDetectFaceRectanglesRequest` to `VNDetectFaceLandmarksRequest`.
    *   In the request's completion handler:
        *   Access the landmarks (`VNFaceLandmarks2D`) from the `VNFaceObservation`.
        *   Specifically extract the `leftPupil` and `rightPupil` points (`VNPoint`).
        *   Extract the head pose angles (`roll`, `pitch`, `yaw` as `NSNumber`s).
        *   Define the `GazeInputData` struct (e.g., in a new `GazeDataTypes.swift` file) to hold `leftPupil: CGPoint`, `rightPupil: CGPoint`, `roll: Double`, `pitch: Double`, `yaw: Double`.
        *   Convert the `VNPoint` pupil coordinates and pose angles into the `GazeInputData` format. Remember to apply the same coordinate transformations (scaling, Y-flip, X-mirror) to the pupil points as were applied to the bounding box.
        *   Add a new `@Published` property to `CameraManager` (e.g., `latestGazeData: GazeInputData?`).
        *   Update this property on the main thread.
    *   Modify `FaceDetectionOverlayView` (or create a new overlay view) to draw indicators (e.g., small circles) at the mirrored/scaled pupil locations.
