# Technical Context: Eye Gaze Mouse Control

## Technologies Used

-   **Language:** Swift (latest stable version assumed)
-   **UI Framework:** SwiftUI
-   **Core Frameworks:**
    -   `AVFoundation`: For camera input capture and management.
    -   `Vision`: For face detection, facial landmark detection (including pupils), and head pose estimation (roll, pitch, yaw).
    -   `CoreGraphics`: For programmatic mouse event creation and posting.
    -   `AppKit` (potentially indirectly via SwiftUI or for specific needs like permissions): Underlying macOS application framework.
    -   `Combine` (likely used implicitly by SwiftUI or explicitly for data flow): For handling asynchronous events and data streams.

## Development Setup

-   **IDE:** Xcode (latest version recommended) for building, running, debugging, and project management.
-   **Editor (Optional):** VS Code can be used for editing Swift files within the project structure managed by Xcode.
-   **Build System:** Standard Xcode build system.
-   **Dependency Management:** No external dependencies planned initially (relying on built-in Apple frameworks). If libraries like MediaPipe/OpenCV were considered later, CocoaPods, Swift Package Manager, or manual integration would be needed.
-   **Operating System:** macOS (specific minimum version TBD, but should support the required frameworks).

## Technical Constraints & Considerations

-   **Permissions:** The application will require explicit user permission for:
    -   Camera Access (`Info.plist` key: `NSCameraUsageDescription`)
    -   Accessibility Access (for `CoreGraphics` mouse control - must be enabled by the user in System Settings > Privacy & Security > Accessibility). Handling the request and guiding the user is necessary.
-   **Performance:** Real-time video processing with `Vision` can be CPU/GPU intensive. Efficient implementation and potentially offloading work to background threads are important. `AVCaptureSession` presets and `Vision` request configuration might need tuning.
-   **Accuracy:** Webcam-based gaze tracking without specialized hardware is inherently limited in accuracy. Calibration quality, lighting conditions, head stability, glasses, and the mapping algorithm significantly impact results. Head pose compensation is included to mitigate some inaccuracies.
-   **Calibration Robustness:** The calibration process needs to be user-friendly and capture sufficient data to build a reasonable mapping model. The quality of the mapping model itself is crucial.
-   **SwiftUI Integration:** Displaying `AVFoundation` camera output and `Vision` overlays within SwiftUI requires bridging, typically using `NSViewRepresentable` or drawing directly onto a `Canvas`.
-   **Coordinate Systems:** Careful management of different coordinate systems is essential:
    -   Video frame coordinates (pixels).
    -   Vision normalized coordinates (relative to frame or bounding box).
    -   SwiftUI view coordinates.
    -   Screen coordinates (global).
