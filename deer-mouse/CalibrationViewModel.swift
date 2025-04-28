import Foundation
import SwiftUI // For CGPoint and ObservableObject

/// Manages the state and logic for the eye gaze calibration process.
class CalibrationViewModel: ObservableObject {

    // Reference to the CameraManager to pass calibration data
    private weak var cameraManager: CameraManager?

    /// Indicates whether the calibration process is currently active.
    @Published var isCalibrating: Bool = false

    /// The sequence of points on the screen the user needs to look at.
    /// TODO: Define actual points based on screen size. Using placeholders for now.
    @Published var calibrationPoints: [CGPoint] = [
        CGPoint(x: 100, y: 100), // Top-left area
        CGPoint(x: 500, y: 100), // Top-right area
        CGPoint(x: 500, y: 500), // Bottom-right area
        CGPoint(x: 100, y: 500), // Bottom-left area
        CGPoint(x: 300, y: 300)  // Center area
    ]

    /// Stores the collected data pairs during calibration.
    @Published var collectedData: [ScreenGazePair] = []

    /// The index of the current calibration target point in the `calibrationPoints` array.
    @Published var currentCalibrationTargetIndex: Int = 0

    /// Returns the point for the current calibration target. Returns nil if calibration isn't active or is complete.
    var currentTargetPoint: CGPoint? {
        guard isCalibrating, currentCalibrationTargetIndex < calibrationPoints.count else {
            return nil
        }
        return calibrationPoints[currentCalibrationTargetIndex]
    }

    // Initializer to receive the CameraManager
    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
    }

    /// Starts the calibration process.
    func startCalibration() {
        // Also tell CameraManager calibration is starting (so it stops estimating)
        cameraManager?.setCalibrationData([]) // Pass empty array to reset state

        collectedData = [] // Clear previous data
        currentCalibrationTargetIndex = 0
        isCalibrating = true
        print("Calibration started. Target 1: \(currentTargetPoint ?? CGPoint.zero)")
    }

    /// Records the gaze data for the current target point and advances to the next target.
    /// - Parameter gazeData: The `GazeInputData` captured when the user signaled focus.
    func recordDataPoint(gazeData: GazeInputData) {
        guard let targetPoint = currentTargetPoint else {
            print("Error: Tried to record data point but no current target exists.")
            return
        }

        let pair = ScreenGazePair(screenPoint: targetPoint, gazeData: gazeData)
        collectedData.append(pair)
        print("Collected data for point \(currentCalibrationTargetIndex + 1): \(pair)")

        // Advance to the next point
        currentCalibrationTargetIndex += 1

        if currentCalibrationTargetIndex >= calibrationPoints.count {
            // Calibration finished
            finishCalibration()
        } else {
            print("Moving to target \(currentCalibrationTargetIndex + 1): \(currentTargetPoint ?? CGPoint.zero)")
        }
    }

    /// Ends the calibration process.
    func finishCalibration() {
        isCalibrating = false
        print("Calibration finished. Collected \(collectedData.count) data points.")
        // Pass the collected data to the CameraManager
        cameraManager?.setCalibrationData(collectedData)
    }

    /// Cancels the calibration process.
    func cancelCalibration() {
        isCalibrating = false
        collectedData = []
        currentCalibrationTargetIndex = 0
        // Also tell CameraManager calibration is cancelled (so it stops estimating)
        cameraManager?.setCalibrationData([]) // Pass empty array to reset state
        print("Calibration cancelled.")
    }
}
