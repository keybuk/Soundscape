//
//  NowPlayingRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/20/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct NowPlayingRow: View {
    @EnvironmentObject var stage: Stage

    @ObservedObject var playlist: Playlist

    var body: some View {
        HStack {
            PlayerView(player: self.stage.playerForPlaylist(playlist))

            if playlist.isLockable {
                if self.stage.lockedPlaylist == playlist {
                    Image(systemName: "lock")
                        .padding()
                        .onTapGesture(perform: unlockPlaylist)
                } else {
                    Image(systemName: "lock.open")
                        .padding()
                        .onTapGesture(perform: lockPlaylist)
                }
            }
        }
    }

    func lockPlaylist() {
        stage.lockedPlaylist = playlist
    }

    func unlockPlaylist() {
        stage.lockedPlaylist = nil
    }
}

#if DEBUG
struct NowPlayingRow_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingRow(playlist: previewContent.soundsets[0].playlists![0] as! Playlist)
            .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif
