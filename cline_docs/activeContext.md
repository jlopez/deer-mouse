# Active Context: Eye Gaze Mouse Control

## Current Focus

Preparing for **Step 6: Mouse Pointer Control** of Phase 3 (Control & Refinement).

## Recent Changes

-   **Completed Step 5: Implement Coordinate Mapping Function:**
    -   Created `CoordinateMapper.swift` with a `static func estimateScreenCoords(...)` using a weighted K-Nearest Neighbors (KNN, k=3) algorithm based on average pupil distance.
    -   Added `calibrationData` storage and `@Published var estimatedScreenCoordinate: CGPoint?` to `CameraManager`.
    -   Modified `CameraManager`'s `captureOutput` delegate method to call `CoordinateMapper.estimateScreenCoords` when calibration is complete and `latestGazeData` is available, updating `estimatedScreenCoordinate`.
    -   Added `setCalibrationData(_:)` method to `CameraManager` to receive data from the view model and manage `isCalibrationComplete` state.
    -   Modified `CalibrationViewModel` to hold a weak reference to `CameraManager`.
    -   Updated `CalibrationViewModel`'s `init`, `startCalibration`, `finishCalibration`, and `cancelCalibration` methods to call `cameraManager.setCalibrationData()` appropriately.
    -   Updated `ContentView`'s `init` to inject `CameraManager` into `CalibrationViewModel`.
    -   Added a red `Circle` overlay in `ContentView` positioned using `cameraManager.estimatedScreenCoordinate` when calibration is not active.
-   **Completed Step 4: Basic Calibration UI & Data Capture:** (Details omitted for brevity, see previous versions if needed)
-   **Completed Step 3: Detect Facial Landmarks (Pupils & Pose):** (Details omitted for brevity)
-   Updated Memory Bank (`progress.md`, `activeContext.md`).

## Next Steps

1.  **Implement Step 6: Mouse Pointer Control:**
    *   **Goal:** Use the estimated screen coordinates to programmatically move the system's mouse pointer via `CoreGraphics`. Add a UI toggle for control activation. Handle Accessibility permissions.
    *   **Tasks:**
        *   Create a new class/struct (e.g., `MouseController.swift`) responsible for mouse events.
        *   Implement a function `movePointer(to: CGPoint)` using `CGEvent.post(tap:location:mouseMoveTo:)`.
        *   Add logic to handle coordinate system differences (SwiftUI/View coordinates vs. global screen coordinates). `NSScreen.main?.frame` might be needed.
        *   Integrate this into `ContentView` or `CameraManager` to call `movePointer` based on `estimatedScreenCoordinate`.
        *   Add a toggle switch (`@State var isMouseControlActive: Bool`) in `ContentView` to enable/disable pointer movement.
        *   Implement Accessibility permission check and request (`AXIsProcessTrustedWithOptions`). Guide the user to System Settings if permission is denied.
        *   Ensure pointer movement only happens when the toggle is on AND calibration is complete AND an estimate exists.
