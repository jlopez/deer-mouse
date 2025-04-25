import Foundation
import AVFoundation
import Combine
import Vision // Import Vision framework
import SwiftUI // Needed for CGRect and DispatchQueue.main

// Conform to delegate protocol
class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var session = AVCaptureSession()
    @Published var faceBoundingBoxes: [CGRect] = [] // Published property for results

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

        let detectFaceRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                print("Face detection error: \(error.localizedDescription)")
                return
            }

            guard let results = request.results as? [VNFaceObservation] else {
                print("No face observations found.")
                DispatchQueue.main.async {
                    self.faceBoundingBoxes = [] // Clear boxes if no faces
                }
                return
            }

            // Get the dimensions of the pixel buffer
            let imageWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
            let imageHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))

            // Convert normalized Vision coordinates to SwiftUI coordinates (origin top-left)
            let convertedRects = results.map { observation -> CGRect in
                let boundingBox = observation.boundingBox // Normalized coordinates (origin bottom-left)

                // Transform to UIKit/AppKit coordinates (origin top-left) AND mirror horizontally
                let convertedBox = CGRect(
                    x: (1 - boundingBox.origin.x - boundingBox.width) * imageWidth, // Mirror X
                    y: (1 - boundingBox.origin.y - boundingBox.height) * imageHeight, // Flip Y
                    width: boundingBox.width * imageWidth,
                    height: boundingBox.height * imageHeight
                )
                return convertedBox
            }

            // Update the published property on the main thread
            DispatchQueue.main.async {
                self.faceBoundingBoxes = convertedRects
                // print("Detected \(convertedRects.count) faces.") // Optional debug print
            }
        }

        // Perform the request
        do {
            try sequenceHandler.perform([detectFaceRequest], on: pixelBuffer, orientation: exifOrientation)
        } catch {
            print("Failed to perform face detection request: \(error.localizedDescription)")
        }
    }
}
