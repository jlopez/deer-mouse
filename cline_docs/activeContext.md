# Active Context: Eye Gaze Mouse Control

## Current Focus

Initializing the project and establishing the foundational Memory Bank documentation based on the initial planning phase.

## Recent Changes

-   Defined the project scope and core functionality (eye gaze mouse control via webcam).
-   Selected the primary technology stack: Swift, SwiftUI, AVFoundation, Vision, CoreGraphics.
-   Refined the data input structure (`GazeInputData`) to include pupil coordinates and head pose (roll, pitch, yaw) for improved accuracy.
-   Established a 7-step development plan.
-   Created `cline_docs/productContext.md`.

## Next Steps

1.  Complete the creation of the initial Memory Bank files (`activeContext.md`, `systemPatterns.md`, `techContext.md`, `progress.md`).
2.  Begin implementation of **Step 1: Display Camera Feed** using `AVFoundation` and SwiftUI. This involves:
    *   Setting up `AVCaptureSession`.
    *   Getting webcam input.
    *   Creating a video data output.
    *   Displaying the captured frames in a SwiftUI view.
