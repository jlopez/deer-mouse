# Active Context: Eye Gaze Mouse Control

## Current Focus

Implementing **Step 4: Basic Calibration UI & Data Capture** of Phase 2 (Calibration & Mapping).

## Recent Changes

-   **Completed Step 3: Detect Facial Landmarks (Pupils & Pose):**
    -   Created `GazeDataTypes.swift` with the `GazeInputData` struct.
    -   Modified `CameraManager` to use `VNDetectFaceLandmarksRequest`.
    -   Implemented extraction and coordinate conversion (scaling, mirroring) for pupil landmarks (`leftPupil`, `rightPupil`) and head pose angles (`roll`, `pitch`, `yaw`).
    -   Added `@Published var latestGazeData: GazeInputData?` to `CameraManager` and updated it in the Vision completion handler.
    -   Fixed a type mismatch error in the landmark point conversion helper function (`CGPoint` vs `VNPoint`).
    -   Modified `FaceDetectionOverlayView` to accept `latestGazeData` and draw green indicators for pupils.
    -   Updated `ContentView` to pass `latestGazeData` to the overlay.
-   Updated README.md status.
-   Updated Memory Bank (`progress.md`, `activeContext.md`).

## Next Steps

1.  **Implement Step 4: Basic Calibration UI & Data Capture:**
    *   **Goal:** Implement a simple UI overlay for calibration (displaying target points). Capture the corresponding `GazeInputData` when the user signals they are looking at the target.
    *   **Tasks:**
        *   Define a data structure to hold calibration pairs: `struct ScreenGazePair { let screenPoint: CGPoint; let gazeData: GazeInputData }`. (Likely in `GazeDataTypes.swift`).
        *   Add state variables to `ContentView` or a new `CalibrationViewModel` to manage calibration state (e.g., `isCalibrating: Bool`, `calibrationPoints: [CGPoint]`, `collectedData: [ScreenGazePair]`, `currentCalibrationTargetIndex: Int`).
        *   Create a `CalibrationTargetView` (or similar) in SwiftUI that displays a visual target (e.g., a circle) at a specific screen coordinate.
        *   Modify `ContentView` to overlay `CalibrationTargetView` when `isCalibrating` is true, positioning it based on `calibrationPoints[currentCalibrationTargetIndex]`.
        *   Add a mechanism (e.g., a button, key press) for the user to signal they are looking at the current target.
        *   When the signal is received:
            *   Capture the current `cameraManager.latestGazeData`.
            *   Capture the screen coordinates of the current target.
            *   Store the `ScreenGazePair`.
            *   Advance `currentCalibrationTargetIndex`.
            *   Handle completion of the calibration sequence.
        *   Add UI elements (e.g., buttons) to start and potentially cancel calibration.
