import SwiftUI

struct FaceDetectionOverlayView: View {
    let faceBoundingBoxes: [CGRect]
    let videoPreviewSize: CGSize // The size of the video preview view for scaling

    var body: some View {
        GeometryReader { geometry in
            // Use Canvas for efficient drawing
            Canvas { context, size in
                // Scale factor based on the preview size and the geometry reader size
                // This assumes the video preview maintains its aspect ratio within the geometry
                let scaleX = size.width / videoPreviewSize.width
                let scaleY = size.height / videoPreviewSize.height
                // Use the minimum scale to maintain aspect ratio and fit within bounds
                let scale = min(scaleX, scaleY)

                // Calculate offsets if the scaled video doesn't fill the geometry
                let offsetX = (size.width - (videoPreviewSize.width * scale)) / 2.0
                let offsetY = (size.height - (videoPreviewSize.height * scale)) / 2.0

                for box in faceBoundingBoxes {
                    // Scale and offset the box coordinates
                    let scaledRect = CGRect(
                        x: (box.origin.x * scale) + offsetX,
                        y: (box.origin.y * scale) + offsetY,
                        width: box.width * scale,
                        height: box.height * scale
                    )

                    // Draw the rectangle outline
                    let path = Path(roundedRect: scaledRect, cornerRadius: 4) // Use rounded rect for aesthetics
                    context.stroke(path, with: .color(.red), lineWidth: 2)
                }
            }
            // Ensure the overlay ignores safe areas if the preview does
            .ignoresSafeArea()
        }
    }
}

// Optional: Add a preview provider for development/testing
struct FaceDetectionOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        // Example bounding boxes (normalized coordinates scaled to a hypothetical 1920x1080 video)
        let exampleBoxes = [
            CGRect(x: 480, y: 270, width: 960, height: 540), // Centered box
            CGRect(x: 100, y: 100, width: 300, height: 300)  // Top-leftish box
        ]
        let previewSize = CGSize(width: 1920, height: 1080)

        FaceDetectionOverlayView(faceBoundingBoxes: exampleBoxes, videoPreviewSize: previewSize)
            .frame(width: 640, height: 360) // Simulate a smaller display frame
            .background(Color.gray) // Background to see the frame
    }
}
