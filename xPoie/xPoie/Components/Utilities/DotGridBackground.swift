import SwiftUI

struct DotGridBackground: View {
    let spacing: CGFloat
    let dotSize: CGFloat
    let dotColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let cols = Int(ceil(size.width / spacing)) + 2
                let rows = Int(ceil(size.height / spacing)) + 2
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * spacing - spacing + 2
                        let y = CGFloat(row) * spacing - spacing + 2
                        
                        let point = CGPoint(x: x, y: y)
                        let path = Path(ellipseIn: CGRect(
                            x: point.x - dotSize/2,
                            y: point.y - dotSize/2,
                            width: dotSize,
                            height: dotSize
                        ))
                        
                        context.fill(path, with: .color(dotColor))
                    }
                }
            }
            .drawingGroup()           // 非常重要！提升性能
        }
        .ignoresSafeArea()
    }
}
