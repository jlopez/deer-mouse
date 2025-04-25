# Active Context: Eye Gaze Mouse Control

## Current Focus

Implementing **Step 2: Detect Faces** of Phase 1 (Vision & Data Acquisition).

## Recent Changes

-   **Completed Step 1: Display Camera Feed:**
    -   Created `CameraManager.swift` to handle `AVCaptureSession`.
    -   Implemented logic to discover and select the external webcam.
    -   Added `AVCaptureVideoDataOutput` to the session.
    -   Created `CameraPreviewView.swift` using `NSViewRepresentable` to display the feed.
    -   Correctly attached the `AVCaptureVideoPreviewLayer` as a sublayer using a Coordinator.
    -   Updated `ContentView.swift` to integrate the camera manager and preview.
    -   Troubleshot and resolved issues related to device selection and layer rendering (`videoGravity`).
-   Updated Memory Bank (`progress.md`, `activeContext.md`).

## Next Steps

1.  **Implement Step 2: Detect Faces:**
    *   Modify `CameraManager` to handle `AVCaptureVideoDataOutputSampleBufferDelegate`.
    *   Process captured `CMSampleBuffer` frames.
    *   Create and perform `VNDetectFaceRectanglesRequest` using the `Vision` framework.
    *   Extract face bounding boxes (`VNFaceObservation`).
    *   Publish the detected bounding boxes (or relevant geometry).
    *   Create an overlay `View` in SwiftUI to draw rectangles based on the published bounding boxes, scaled to the preview coordinate system.
    *   Integrate the overlay view into `ContentView`.
