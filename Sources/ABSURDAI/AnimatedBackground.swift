import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            LinearGradient(
                colors: [
                    Color(hue: (sin(t * 0.1) + 1) / 2 * 0.15 + 0.7, saturation: 0.8, brightness: 0.25),
                    Color(hue: (cos(t * 0.08) + 1) / 2 * 0.15 + 0.55, saturation: 0.9, brightness: 0.35),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}