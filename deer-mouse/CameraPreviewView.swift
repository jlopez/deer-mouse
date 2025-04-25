import SwiftUI
import AVFoundation

struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true // Important: NSView must be layer-backed

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill // Or .resizeAspect
        previewLayer.connection?.automaticallyAdjustsVideoMirroring = false // Often desired for face tracking
        previewLayer.connection?.isVideoMirrored = true // Mirror front camera

        view.layer = previewLayer // Set the layer directly

        // Ensure the layer resizes with the view
        view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        view.autoresizingMask = [.width, .height]
        previewLayer.frame = view.bounds // Initial frame

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Update the layer's frame if the view's bounds change
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.frame = nsView.bounds
        }
    }
}

// Optional: Preview Provider for SwiftUI Canvas
struct CameraPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy session for preview purposes
        let dummySession = AVCaptureSession()
        // You might add a dummy input/output here if needed for visual preview,
        // but often an empty session is enough to see the view structure.
        CameraPreviewView(session: dummySession)
            .frame(width: 300, height: 200)
    }
}
