# Progress: Eye Gaze Mouse Control

## Current Status: Phase 2 (Calibration & Mapping)

Steps 1-5 are complete.

## What Works

-   The application displays a live feed from the selected (external) webcam.
-   Detects faces and facial landmarks (pupils, pose) in the video feed.
-   Provides a basic UI for calibration, collecting screen coordinate and gaze data pairs.
-   Estimates screen coordinates based on live gaze data and calibration using a KNN algorithm.
-   Displays a visual indicator (red circle) at the estimated gaze position after calibration.

## Detailed Plan & Remaining Steps

**Phase 1: Vision & Data Acquisition**

1.  **Step 1: Display Camera Feed**
    *   **Goal:** Access the default webcam and display the live video stream within the application window.
    *   **Technologies:** Swift, `AVFoundation`, SwiftUI.
    *   **Deliverable:** A running macOS application showing the user's face via the webcam feed.
    *   **Status:** **Completed - 4/25/2025**

2.  **Step 2: Detect Faces**
    *   **Goal:** Process the video frames using the `Vision` framework to detect human faces. Overlay a visual indicator (e.g., a bounding box) on the detected face(s) in the camera feed.
    *   **Technologies:** `Vision` (`VNDetectFaceRectanglesRequest`), `AVFoundation`, SwiftUI.
    *   **Deliverable:** The application now draws rectangles around detected faces in the live video feed.
    *   **Status:** **Completed - 4/25/2025**

3.  **Step 3: Detect Facial Landmarks (Pupils & Pose)**
    *   **Goal:** Enhance the `Vision` processing to detect detailed facial landmarks, specifically the pupils and head pose. Draw indicators (e.g., circles for pupils, axes for pose) over the detected locations on the video feed. Define `GazeInputData` struct.
    *   **Technologies:** `Vision` (`VNDetectFaceLandmarksRequest`), `AVFoundation`, SwiftUI.
    *   **Deliverable:** The application draws markers on facial landmarks (pupils) and indicates head pose in the live video feed. The `GazeInputData` struct (containing `leftPupil`, `rightPupil`, `roll`, `pitch`, `yaw`) is defined and populated.
    *   **Status:** **Completed - 4/25/2025**

**Phase 2: Calibration & Mapping**

4.  **Step 4: Basic Calibration UI & Data Capture**
    *   **Goal:** Implement a simple UI overlay for calibration (displaying target points). Capture the corresponding `GazeInputData` when the user signals they are looking at the target.
    *   **Technologies:** SwiftUI, `Vision` data handling.
    *   **Deliverable:** A calibration mode where the user looks at specific points, and the application records pairs of (Target Screen Coordinate, `GazeInputData`). Data can initially be stored in memory or printed.
    *   **Status:** **Completed - 4/25/2025**

5.  **Step 5: Implement Coordinate Mapping Function**
    *   **Goal:** Create a Swift function `estimateScreenCoords(gazeData: GazeInputData, calibrationData: [ScreenGazePair]) -> CGPoint?` that uses calibration data to estimate screen coordinates from live `GazeInputData`. Implement a visual indicator for the estimated point.
    *   **Technologies:** Swift logic, geometry/math (KNN), SwiftUI.
    *   **Deliverable:** A function that estimates screen coordinates using KNN. A visual indicator (red circle) is displayed on the screen at the estimated position after calibration.
    *   **Status:** **Completed - 4/28/2025**

**Phase 3: Control & Refinement**

6.  **Step 6: Mouse Pointer Control**
    *   **Goal:** Use the estimated screen coordinates to programmatically move the system's mouse pointer via `CoreGraphics`. Add a UI toggle for control activation. Handle Accessibility permissions.
    *   **Technologies:** `CoreGraphics` (`CGEvent`), SwiftUI.
    *   **Deliverable:** When enabled, the macOS mouse pointer moves based on the estimated gaze position. Requires user granting Accessibility permissions.
    *   **Status:** Pending

7.  **Step 7: Smoothing and Filtering (Optional Enhancement)**
    *   **Goal:** Reduce pointer jitter using filtering or averaging techniques.
    *   **Technologies:** Swift logic (filtering/smoothing algorithms).
    *   **Deliverable:** Smoother, more stable pointer movement.
    *   **Status:** Pending

## Next Immediate Step

-   Begin implementation of **Step 6: Mouse Pointer Control**.
