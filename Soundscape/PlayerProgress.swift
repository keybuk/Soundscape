//
//  PlayerProgress.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PlayerProgress: View {
    @ObservedObject var player: Player
    @State var progress: Double = 0

    var body: some View {
        GeometryReader { g in
            Circle()
                .stroke(lineWidth: self.lineWidth(size: g.size))
                .foregroundColor(Color(UIColor.secondarySystemFill))
            ProgressArc(progress: self.$progress)
                .stroke(style: self.strokeStyle(size: g.size))
                .onReceive(self.player.progressSubject
                        .receive(on: RunLoop.main)) {
                    self.progress = $0
                }
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
struct PlayerProgress_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProgress(player: Player(playlist: previewContent.soundsets[0].allPlaylists[0], audio: AudioManager()))
    }
}
#endif

