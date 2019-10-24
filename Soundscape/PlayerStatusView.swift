//
//  PlayerStatusView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PlayerStatusView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            if player.isDownloading {
                Image(systemName: "icloud.and.arrow.down")
            } else if player.isPlaying && player.playlist.kind != .oneShot {
                Image(systemName: "stop.fill")
            } else {
                Image(systemName: "play.fill")
            }
            PlayerProgress(player: player)
        }
        .frame(width: 30, height: 30)
    }
}

#if DEBUG
struct PlayerStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerStatusView(player: Player(playlist: previewContent.soundsets[0].allPlaylists[0], audio: AudioManager()))
            .previewLayout(.sizeThatFits)
    }
}
#endif

