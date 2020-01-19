//
//  ProgressCircle.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct ProgressCircle: View {
    @Binding var progress: Double

    var body: some View {
        GeometryReader { g in
            Circle()
                .stroke(lineWidth: self.lineWidth(size: g.size))
                .foregroundColor(Color(UIColor.secondarySystemFill))
            ProgressArc(progress: self.progress)
                .stroke(style: self.strokeStyle(size: g.size))
        }
    }

    func lineWidth(size: CGSize) -> CGFloat {
        let length = min(size.width, size.height)
        return length / (2 * log2(length))
    }

    func strokeStyle(size: CGSize) -> StrokeStyle {
        StrokeStyle(lineWidth: self.lineWidth(size: size),
                    lineCap: .round, lineJoin: .round, miterLimit: 0,
                    dash: [], dashPhase: 0)
    }
}

#if DEBUG
struct ProgressCircle_AnimationTest: View {
    @State var progress: Double = 0.8
    @State var newProgress: Double = 0.8

    var body: some View {
        VStack {
            ProgressCircle(progress: $progress)
            Slider(value: $newProgress, in: -1.0...1.0)
            Button(action: {
                withAnimation(self.newProgress < 0 && self.progress > 0 ? nil : .linear) {
                    self.progress = self.newProgress
                }
            }) {
                Text("Change")
            }
        }
        .padding()
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                HStack {
                    ProgressCircle(progress: .constant(0.8))
                    ProgressCircle(progress: .constant(0.4))
                    ProgressCircle(progress: .constant(-0.4))
                }
                .frame(height: 30)

                HStack {
                    ProgressCircle(progress: .constant(0.8))
                    ProgressCircle(progress: .constant(0.4))
                    ProgressCircle(progress: .constant(-0.4))
                }
                .frame(height: 44)

                HStack {
                    ProgressCircle(progress: .constant(0.8))
                    ProgressCircle(progress: .constant(0.4))
                    ProgressCircle(progress: .constant(-0.4))
                }
                .frame(height: 88)

                HStack {
                    ProgressCircle(progress: .constant(0.4))
                    ProgressCircle(progress: .constant(-0.4))
                }

                ProgressCircle(progress: .constant(0.8))
            }

            ProgressCircle_AnimationTest()
        }
    }
}
#endif
