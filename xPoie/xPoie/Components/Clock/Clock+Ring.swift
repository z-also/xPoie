import SwiftUI

struct ClockRing: View {
    var progress: CGFloat
    var size: CGFloat = 180
    var thickness: CGFloat = 22
    var trackColor: Color = .gray
    var gradientColors: [Color] = [.blue, .green]
    var step: Double = 1.0 / 60.0
    
    var tick: ((CGFloat) -> Void)?

    var body: some View {
        let rect = size - thickness
        let radius = rect / 2
        let center = CGPoint(x: size / 2, y: size / 2)
        let stroke = StrokeStyle(lineWidth: thickness, lineCap: .round)
        
        ZStack {
            Circle()
                .stroke(trackColor, style: stroke)
//                .stroke(trackColor, style: StrokeStyle(lineWidth: thickness - 6, lineCap: .round))
                .frame(width: rect, height: rect)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: stroke
                )
                .rotationEffect(.degrees(-90))
                .frame(width: rect, height: rect)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            
            ForEach(0..<60) { i in
                Rectangle()
                    .fill(Color.white.opacity(i % 5 == 0 ? 0.5 : 0.2))
                    .frame(width: 1.5, height: i % 5 == 0 ? 7 : 4)
                    .offset(y: -(radius - thickness/2 + 7))
//                    .opacity(Double(i) / 60.0 <= progress ? 1.0 : 0.0)
                    .rotationEffect(.degrees(Double(i) * 6))
            }
            
            HStack {
                QuarterLabel(label: "45")
                Spacer()

                VStack {
                    QuarterLabel(label: "0")
                    Spacer()

                    Text("\(Int(progress * 60))")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("Mins")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    QuarterLabel(label: "30")
                }
                
                Spacer()
                QuarterLabel(label: "15")
            }
            .padding(4)
            .frame(width: size - thickness * 2, height: size - thickness * 2)
            
            Circle()
                .fill(Color.clear)
                .contentShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            updateProgress(at: value.location, center: center)
                        }
                )
        }
        .frame(width: size, height: size)
    }
    
    private func updateProgress(at location: CGPoint, center: CGPoint) {
        let vector = CGVector(dx: location.x - center.x, dy: location.y - center.y)
        let angle = atan2(vector.dy, vector.dx)
        
        var fixedAngle = angle + .pi / 2
        if fixedAngle < 0 { fixedAngle += 2 * .pi }
        
        let newProgress = fixedAngle / (2 * .pi)
        
        let steppedProgress = (newProgress / step).rounded() * step
        let clampedProgress = min(max(steppedProgress, 0.0), 1.0)
        
        if clampedProgress != self.progress {
            tick?(clampedProgress)
        }
    }
}

fileprivate struct QuarterLabel: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.gray)
    }
}
