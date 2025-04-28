import Foundation
import CoreGraphics

struct CoordinateMapper {

    static func estimateScreenCoords(gazeData: GazeInputData, calibrationData: [ScreenGazePair], k: Int = 3) -> CGPoint? {
        guard calibrationData.count >= k else {
            print("Not enough calibration data (\(calibrationData.count)/\(k))")
            return nil // Need at least k points for KNN
        }

        // 1. Calculate distances to all calibration points
        let distances: [(pair: ScreenGazePair, distance: CGFloat)] = calibrationData.map { pair in
            let dist = calculateDistance(from: gazeData, to: pair.gazeData)
            return (pair: pair, distance: dist)
        }

        // 2. Sort by distance and take the k nearest neighbors
        let sortedNeighbors = distances.sorted { $0.distance < $1.distance }
        let nearestNeighbors = Array(sortedNeighbors.prefix(k))

        // 3. Calculate weighted average of screen coordinates
        var totalWeight: CGFloat = 0.0
        var weightedSumX: CGFloat = 0.0
        var weightedSumY: CGFloat = 0.0
        let epsilon: CGFloat = 1e-6 // Small value to prevent division by zero

        for neighbor in nearestNeighbors {
            // Inverse distance weighting: weight = 1 / distance
            // Add epsilon to handle potential zero distance
            let weight = 1.0 / (neighbor.distance + epsilon)

            weightedSumX += neighbor.pair.screenPoint.x * weight
            weightedSumY += neighbor.pair.screenPoint.y * weight
            totalWeight += weight
        }

        guard totalWeight > epsilon else {
             print("Total weight is too small, cannot estimate.")
             // This might happen if all distances are extremely large (unlikely)
             // Or if k=0 (but we guard against that)
             // Or if all distances are zero (meaning live gaze perfectly matches k calibration points)
             // In the perfect match case, we could just return the coordinate of the first match.
             if let firstMatch = nearestNeighbors.first(where: { $0.distance < epsilon }) {
                 return firstMatch.pair.screenPoint
             }
             return nil
        }

        let estimatedX = weightedSumX / totalWeight
        let estimatedY = weightedSumY / totalWeight

        // print("Estimated Coords: (\(estimatedX), \(estimatedY))") // Optional debug print
        return CGPoint(x: estimatedX, y: estimatedY)
    }

    // Helper function to calculate distance
    private static func calculateDistance(from liveGaze: GazeInputData, to calibrationGaze: GazeInputData) -> CGFloat {
        // Simple distance based on average pupil coordinates
        // Note: This assumes coordinates are in a comparable space.
        // Might need normalization or more complex features later.
        let liveAvgPupilX = (liveGaze.leftPupil.x + liveGaze.rightPupil.x) / 2.0
        let liveAvgPupilY = (liveGaze.leftPupil.y + liveGaze.rightPupil.y) / 2.0

        let calAvgPupilX = (calibrationGaze.leftPupil.x + calibrationGaze.rightPupil.x) / 2.0
        let calAvgPupilY = (calibrationGaze.leftPupil.y + calibrationGaze.rightPupil.y) / 2.0

        let dx = liveAvgPupilX - calAvgPupilX
        let dy = liveAvgPupilY - calAvgPupilY

        return sqrt(dx*dx + dy*dy)
    }
}
