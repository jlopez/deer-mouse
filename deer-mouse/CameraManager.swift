import Foundation
import AVFoundation
import Combine
import Vision // Import Vision framework
import SwiftUI // Needed for CGRect and DispatchQueue.main

// Conform to delegate protocol
class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var session = AVCaptureSession()
    @Published var faceBoundingBoxes: [CGRect] = [] // Keep for potential overlay drawing
    @Published var latestGazeData: GazeInputData? = nil // Published property for gaze data
    @Published var estimatedScreenCoordinate: CGPoint? = nil // Published estimated coordinate

    // Calibration state
    private var calibrationData: [ScreenGazePair] = []
    private var isCalibrationComplete: Bool = false

    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?
    private var videoDataOutput: AVCaptureVideoDataOutput? // Add video data output
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem) // Queue for processing

    // Vision request handler
    private let sequenceHandler = VNSequenceRequestHandler()

    override init() { // Need override as we now inherit from NSObject
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high // Or another suitable preset

        // Discover devices and prioritize external webcam
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .externalUnknown], mediaType: .video, position: .unspecified)
        let devices = discoverySession.devices

        print("Found video devices: \(devices.map { $0.localizedName })")

        // Prioritize external camera
        device = devices.first { $0.localizedName.lowercased().contains("webcam") || $0.localizedName.lowercased().contains("external") || $0.manufacturer != "Apple Inc." } // Heuristic for external

        // Fallback to default if no external found or heuristic fails
        if device == nil {
            print("No external camera found by heuristic, falling back to default.")
            device = AVCaptureDevice.default(for: .video)
        }

        guard let cameraDevice = device else {
            print("Error: Could not find any suitable video device.")
            session.commitConfiguration()
            return
        }

        print("Selected video device: \(cameraDevice.localizedName)")

        // Create input from the selected device
        do {
            input = try AVCaptureDeviceInput(device: cameraDevice)
            if let cameraInput = input, session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                print("Error: Could not add input for selected camera (\(cameraDevice.localizedName)) to session.")
                session.commitConfiguration()
                return
            }
        } catch {
            print("Error creating camera input: \(error)")
            session.commitConfiguration()
            return
        }

        // Add Video Data Output
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput?.alwaysDiscardsLateVideoFrames = true // Discard late frames to reduce latency
        videoDataOutput?.setSampleBufferDelegate(self, queue: videoDataOutputQueue) // Set delegate

        if let output = videoDataOutput, session.canAddOutput(output) {
            session.addOutput(output)
            print("Added video data output.")
        } else {
            print("Error: Could not add video data output to session.")
            session.commitConfiguration()
            return
        }

        session.commitConfiguration()
        print("Session configuration committed.")
    }

    func startSession() {
        guard !session.isRunning else { return }
        session.startRunning()
        print("Camera session started.")
    }

    func stopSession() {
        guard session.isRunning else { return }
        session.stopRunning()
        print("Camera session stopped.")
    }

    // Placeholder for requesting permission - will be refined later
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            print("Camera permission granted.")
            return
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Camera permission granted after request.")
                } else {
                    print("Camera permission denied after request.")
                }
            }
        case .denied: // The user has previously denied access.
            print("Camera permission denied.")
            // TODO: Guide user to settings
            return
        case .restricted: // The user can't grant access due to restrictions.
            print("Camera permission restricted.")
            return
        @unknown default:
            fatalError("Unknown camera authorization status")
        }
    }

    // Method to receive calibration data from ViewModel
    func setCalibrationData(_ data: [ScreenGazePair]) {
        DispatchQueue.main.async { // Ensure updates happen on the main thread
            self.calibrationData = data
            self.isCalibrationComplete = !data.isEmpty // Mark as complete if data is provided
            self.estimatedScreenCoordinate = nil // Reset estimate when calibration changes
            print("CameraManager received calibration data (\(data.count) points). Calibration complete: \(self.isCalibrationComplete)")
        }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get CVPixelBuffer from sample buffer.")
            return
        }

        // Determine the orientation based on the device and connection
        // Note: This might need adjustment depending on how the device/camera is mounted or oriented.
        // For a standard built-in FaceTime camera or external webcam in landscape, .up is often correct.
        // If the image appears rotated, experiment with .left, .right, or .down.
        let exifOrientation = CGImagePropertyOrientation.up // Adjust if needed

        // Change to landmarks request
        let detectFaceLandmarksRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                print("Face landmarks detection error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.faceBoundingBoxes = []
                    self.latestGazeData = nil
                }
                return
            }

            guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
                // print("No face observations found or results empty.") // Can be noisy
                DispatchQueue.main.async {
                    self.faceBoundingBoxes = [] // Clear boxes if no faces
                    self.latestGazeData = nil // Clear gaze data if no faces
                }
                return
            }

            // Get the dimensions of the pixel buffer
            let imageWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
            let imageHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))

            // --- Bounding Box Calculation (Keep for potential overlay) ---
            let boundingBoxes = results.map { observation -> CGRect in
                let boundingBox = observation.boundingBox // Normalized coordinates (origin bottom-left)
                // Transform to SwiftUI coordinates (origin top-left, mirrored)
                return CGRect(
                    x: (1 - boundingBox.origin.x - boundingBox.width) * imageWidth, // Mirror X
                    y: (1 - boundingBox.origin.y - boundingBox.height) * imageHeight, // Flip Y
                    width: boundingBox.width * imageWidth,
                    height: boundingBox.height * imageHeight
                )
            }

            // --- Landmark and Pose Extraction (Focus on the first detected face) ---
            var currentGazeData: GazeInputData? = nil
            if let firstFace = results.first, // Process only the first face for now
               let landmarks = firstFace.landmarks,
               let leftPupil = landmarks.leftPupil, // VNPoint in normalized face bounding box coords
               let rightPupil = landmarks.rightPupil, // VNPoint in normalized face bounding box coords
               let pose = firstFace.yaw?.doubleValue // Use yaw for now, add pitch/roll later if needed
            {
                // Function to convert normalized landmark point (CGPoint) to mirrored pixel coordinates (CGPoint)
                func convertLandmarkPoint(_ point: CGPoint, in boundingBox: CGRect) -> CGPoint {
                    // point.x and point.y are normalized relative to the boundingBox
                    // 1. Calculate position within the bounding box in normalized image coordinates (bottom-left origin)
                    let xNormBL = boundingBox.origin.x + (point.x * boundingBox.width)
                    let yNormBL = boundingBox.origin.y + (point.y * boundingBox.height)
                    // 2. Convert to pixel coordinates (top-left origin, mirrored)
                    let pixelX = (1 - xNormBL) * imageWidth // Mirror X
                    let pixelY = (1 - yNormBL) * imageHeight // Flip Y
                    return CGPoint(x: pixelX, y: pixelY)
                }

                // Ensure we have points before trying to access index 0
                guard !leftPupil.normalizedPoints.isEmpty, !rightPupil.normalizedPoints.isEmpty else {
                    print("Pupil landmark regions are empty.")
                    DispatchQueue.main.async {
                        self.latestGazeData = nil // Clear gaze data if pupils aren't found
                    }
                    return // Exit the completion handler for this frame
                }

                let leftPupilPixel = convertLandmarkPoint(leftPupil.normalizedPoints[0], in: firstFace.boundingBox)
                let rightPupilPixel = convertLandmarkPoint(rightPupil.normalizedPoints[0], in: firstFace.boundingBox)

                // Extract pose angles (convert NSNumber to Double, radians assumed)
                let yawAngle = firstFace.yaw?.doubleValue ?? 0.0
                let pitchAngle = firstFace.pitch?.doubleValue ?? 0.0
                let rollAngle = firstFace.roll?.doubleValue ?? 0.0

                currentGazeData = GazeInputData(
                    leftPupil: leftPupilPixel,
                    rightPupil: rightPupilPixel,
                    roll: rollAngle,
                    pitch: pitchAngle,
                    yaw: yawAngle
                )
            } else {
                 // print("Could not extract landmarks or pose from the first face.") // Can be noisy
            }


            // Update the published properties on the main thread
            // Update the published properties on the main thread
            DispatchQueue.main.async {
                self.faceBoundingBoxes = boundingBoxes // Update bounding boxes
                self.latestGazeData = currentGazeData // Update gaze data (will be nil if no face/landmarks)

                // --- Estimate Screen Coordinates if Calibrated ---
                if self.isCalibrationComplete, let liveGaze = currentGazeData {
                    // Call the mapper function
                    let estimatedCoords = CoordinateMapper.estimateScreenCoords(
                        gazeData: liveGaze,
                        calibrationData: self.calibrationData
                    )
                    self.estimatedScreenCoordinate = estimatedCoords
                    // if let coords = estimatedCoords { print("Estimated Screen Coords: \(coords)") } // Debug print
                } else {
                    // If not calibrated or no gaze data, clear the estimate
                    self.estimatedScreenCoordinate = nil
                }
                 // if let gaze = currentGazeData { print("Gaze: \(gaze)") } // Optional debug print
            }
        }

        // Perform the request
        do {
            // Use the landmarks request now
            try sequenceHandler.perform([detectFaceLandmarksRequest], on: pixelBuffer, orientation: exifOrientation)
        } catch {
            print("Failed to perform face landmarks detection request: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.faceBoundingBoxes = []
                self.latestGazeData = nil
            }
        }
    }
}
