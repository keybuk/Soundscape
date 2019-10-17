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
        ProgressCircle(progress: $progress)
            .onReceive(player.progressSubject.receive(on: RunLoop.main)) {
                self.progress = $0
            }
    }
}

#if DEBUG
struct PlayerProgress_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProgress(player: Player(playlist: previewContent.soundsets[0].allPlaylists[0], audio: AudioManager()))
    }
}
#endif

