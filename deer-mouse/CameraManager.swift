import Foundation
import AVFoundation
import Combine

class CameraManager: ObservableObject {
    @Published var session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?

    init() {
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

        session.commitConfiguration()
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
}
