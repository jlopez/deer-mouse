# Active Context: Eye Gaze Mouse Control

## Current Focus

Implementing **Step 5: Implement Coordinate Mapping Function** of Phase 2 (Calibration & Mapping).

## Recent Changes

-   **Completed Step 4: Basic Calibration UI & Data Capture:**
    -   Defined `ScreenGazePair` struct in `GazeDataTypes.swift`.
    -   Created `CalibrationViewModel.swift` to manage calibration state (`isCalibrating`, `calibrationPoints`, `collectedData`, `currentCalibrationTargetIndex`) and logic (`startCalibration`, `recordDataPoint`, `finishCalibration`, `cancelCalibration`).
    -   Created `CalibrationTargetView.swift` to display a visual target.
    -   Integrated `CalibrationViewModel` into `ContentView.swift`.
    -   Added UI controls (Start/Record/Cancel buttons) to `ContentView.swift`.
    -   Conditionally displayed `CalibrationTargetView` based on `calibrationViewModel.isCalibrating` and `currentTargetPoint`.
    -   Implemented logic to capture `cameraManager.latestGazeData` and store `ScreenGazePair` on button press.
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

1.  **Implement Step 5: Implement Coordinate Mapping Function:**
    *   **Goal:** Create a Swift function `estimateScreenCoords(gazeData: GazeInputData, calibrationData: [ScreenGazePair]) -> CGPoint?` that uses calibration data to estimate screen coordinates from live `GazeInputData`.
    *   **Tasks:**
        *   Decide on an initial mapping algorithm (e.g., simple interpolation, weighted average based on proximity, polynomial regression - start simple).
        *   Create a new file (e.g., `CoordinateMapper.swift`) or add the function to an existing relevant file (perhaps `CalibrationViewModel` or a dedicated utility struct/class).
        *   Implement the `estimateScreenCoords` function, taking live `GazeInputData` and the `collectedData` (`[ScreenGazePair]`) as input.
        *   The function should return an estimated `CGPoint` representing screen coordinates, or `nil` if estimation isn't possible (e.g., insufficient calibration data).
        *   Add basic logging or debugging output within the function to see the estimated coordinates.
        *   (Optional) Add unit tests for the mapping function if feasible with sample data.
        *   Integrate the call to this function into `ContentView` or `CameraManager` to continuously estimate gaze coordinates when not calibrating (initially just print the output).
