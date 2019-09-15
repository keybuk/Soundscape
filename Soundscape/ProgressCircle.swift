//
//  ProgressCircle.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct ProgressArc: Shape {
    var progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: .radians(1.5 * .pi),
            endAngle: .radians(1.5 * .pi + progress * 2 * .pi),
            clockwise: progress < 0
        )
        return path
    }

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
}

struct ProgressCircle: View {
    @Binding var progress: Double

    var body: some View {
        GeometryReader { g in
            Circle()
                .stroke(lineWidth: self.lineWidth(size: g.size))
                .foregroundColor(Color(UIColor.secondarySystemFill))
            ProgressArc(progress: self.progress)
                .stroke(style: StrokeStyle(lineWidth: self.lineWidth(size: g.size), lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                .animation(.linear)
        }
    }

    func lineWidth(size: CGSize) -> CGFloat {
        let length = min(size.width, size.height)
        return length / (2 * log2(length))
    }
}

#if DEBUG
struct AnimationTest: View {
    @State var progress: Double = 0.8
    @State var newProgress: Double = 0.8

    var body: some View {
        VStack {
            ProgressCircle(progress: $progress)
            Slider(value: $newProgress, in: -1.0...1.0)
            Button(action: {
                self.progress = self.newProgress
            }) {
                Text("Change")
            }
        }
        .padding()
    }
}

struct CircleTest: View {
    @State var progress: Double

    var body: some View {
        ProgressCircle(progress: $progress)
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                CircleTest(progress: 0.8)
                CircleTest(progress: 0.4)
                CircleTest(progress: -0.4)
            }
            .frame(height: 30)

            HStack {
                CircleTest(progress: 0.8)
                CircleTest(progress: 0.4)
                CircleTest(progress: -0.4)
            }
            .frame(height: 44)

            HStack {
                CircleTest(progress: 0.8)
                CircleTest(progress: 0.4)
                CircleTest(progress: -0.4)
            }
            .frame(height: 88)

            AnimationTest()
        }
    }
}
#endif
