import Foundation
import CoreGraphics // Import CoreGraphics for CGPoint

/// Structure to hold the relevant data extracted from facial landmarks and pose.
struct GazeInputData {
    /// The detected location of the left pupil in the video frame's coordinate space (pixels, top-left origin, mirrored).
    let leftPupil: CGPoint

    /// The detected location of the right pupil in the video frame's coordinate space (pixels, top-left origin, mirrored).
    let rightPupil: CGPoint

    /// The head's roll angle (rotation around the Z-axis, i.e., tilting head left/right) in radians.
    let roll: Double

    /// The head's pitch angle (rotation around the X-axis, i.e., tilting head up/down) in radians.
    let pitch: Double

    /// The head's yaw angle (rotation around the Y-axis, i.e., turning head left/right) in radians.
    let yaw: Double

    // Consider adding interpupillary distance (IPD) later as a proxy for Z-distance.
    // let ipd: CGFloat?
}

/// Represents a pair of screen coordinates (where a calibration target was shown)
/// and the corresponding gaze data captured when the user looked at that target.
struct ScreenGazePair {
    let screenPoint: CGPoint
    let gazeData: GazeInputData
}
