import SwiftUI

/// A simple view that displays a visual target (e.g., a circle) at a specific point.
struct CalibrationTargetView: View {
    let position: CGPoint
    let size: CGFloat = 30 // Diameter of the target

    var body: some View {
        Circle()
            .fill(Color.red.opacity(0.7)) // Semi-transparent red circle
            .frame(width: size, height: size)
            .position(position) // Position the center of the circle
            .overlay(
                Circle() // Add a border for better visibility
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: size, height: size)
                    .position(position)
            )
            .overlay( // Add a smaller center dot
                Circle()
                    .fill(Color.white)
                    .frame(width: size / 5, height: size / 5)
                    .position(position)
            )
    }
}

#Preview {
    // Example usage within a ZStack for positioning context
    ZStack {
        CalibrationTargetView(position: CGPoint(x: 100, y: 150))
        CalibrationTargetView(position: CGPoint(x: 300, y: 250))
    }
    .frame(width: 400, height: 400)
    .background(Color.gray)
}
