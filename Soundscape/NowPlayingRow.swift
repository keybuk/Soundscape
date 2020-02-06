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
        PlayerView(player: self.stage.playerForPlaylist(playlist))
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
