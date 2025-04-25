# Deer Mouse: Eye Gaze Mouse Control for macOS

## Description

Deer Mouse aims to provide a hands-free method for controlling the macOS mouse cursor using only eye movements detected by a standard webcam. It leverages Apple's native frameworks like AVFoundation (for camera input) and Vision (for face/landmark detection) to estimate gaze direction and translate it into pointer movement.

This project is primarily an exploration and accessibility tool.

## Current Status (as of 4/25/2025)

-   **Phase 1: Vision & Data Acquisition**
    -   ✅ **Step 1: Display Camera Feed:** The application successfully displays a live feed from the selected webcam.
    -   ✅ **Step 2: Detect Faces:** The application now detects faces and draws bounding boxes around them (correctly mirrored).
    -   ✅ **Step 3: Detect Facial Landmarks (Pupils & Pose):** The application detects pupils and head pose, populating `GazeInputData`, and displays pupil indicators.
    -   ... (See `cline_docs/progress.md` for full plan)

## Core Technologies

-   **Language:** Swift
-   **UI:** SwiftUI
-   **Camera:** AVFoundation
-   **Detection:** Vision (Face Rectangles, Landmarks, Pose)
-   **Mouse Control:** CoreGraphics

## Setup & Usage

1.  **Clone the repository.**
2.  **Open `deer-mouse.xcodeproj` in Xcode.**
3.  **Build and Run** the `deer-mouse` target.
4.  **Permissions:**
    *   The app will request **Camera Access** on first launch. Please grant permission.
    *   For mouse control (Step 6 onwards), you will need to manually grant **Accessibility Access** in `System Settings > Privacy & Security > Accessibility`.

## Roadmap

The current plan involves several phases:

1.  **Vision & Data Acquisition:** Displaying the camera feed, detecting faces, and extracting key landmarks (pupils, head pose).
2.  **Calibration & Mapping:** Implementing a calibration process and developing a function to map gaze data to screen coordinates.
3.  **Control & Refinement:** Using the mapped coordinates to control the system mouse pointer and potentially adding smoothing.

*(See `cline_docs/` for detailed internal documentation used during development.)*
