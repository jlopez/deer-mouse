# Product Context: Eye Gaze Mouse Control

## Why This Project Exists

To provide a hands-free method for controlling the macOS mouse cursor, enabling users to interact with their computer using only their eye movements as detected by a standard webcam.

## What Problems It Solves

-   Accessibility challenges for users who cannot use traditional input devices (mouse, trackpad).
-   Situations where hands-free computer operation is desired or necessary.

## How It Should Work

1.  **Camera Input:** Access the built-in webcam using `AVFoundation`.
2.  **Gaze & Pose Detection:** Process video frames using the `Vision` framework (`VNDetectFaceLandmarksRequest`) to detect the user's face (`VNFaceObservation`). Extract facial landmarks, specifically the pupils (`leftPupil`, `rightPupil`), and the head pose angles (`roll`, `pitch`, `yaw`).
3.  **Calibration:** Guide the user through a calibration process where they look at specific points on the screen. Record the screen coordinates of these points and the corresponding detected sensor data (`GazeInputData` struct containing pupil `CGPoint`s and head pose angles).
4.  **Coordinate Mapping:** Use the calibration data to build a mapping model. This model takes live `GazeInputData` (pupils and head pose) and estimates the corresponding screen coordinates the user is looking at, compensating for head orientation and distance (using interpupillary distance as a proxy).
5.  **Mouse Control:** Use `CoreGraphics` to move the system mouse pointer to the estimated screen coordinates. Provide a mechanism to enable/disable control.
6.  **Feedback:** Display the camera feed in the UI, potentially overlaying detected landmarks and the estimated gaze point for debugging and user feedback.
