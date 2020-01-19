//
//  ProgressArc.swift
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

#if DEBUG
struct ProgressArc_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack(spacing: 20.0) {
                ProgressArc(progress: 0.8)
                    .stroke(style: Self.strokeStyle)

                ProgressArc(progress: -0.8)
                    .stroke(style: Self.strokeStyle)
            }

            HStack(spacing: 20.0) {
                ProgressArc(progress: 0.4)
                    .stroke(style: Self.strokeStyle)

                ProgressArc(progress: -0.4)
                    .stroke(style: Self.strokeStyle)
            }

            HStack(spacing: 20.0) {
                ProgressArc(progress: 1.0)
                    .stroke(style: Self.strokeStyle)

                ProgressArc(progress: -1.0)
                    .stroke(style: Self.strokeStyle)
            }
        }
        .padding(20.0)
    }

    static var strokeStyle = StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)
}
#endif
