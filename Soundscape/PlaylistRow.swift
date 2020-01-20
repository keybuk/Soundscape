//
//  PlaylistRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PlaylistRow: View {
    @EnvironmentObject var stage: Stage

    @ObservedObject var playlist: Playlist

    var body: some View {
        PlayerView(player: self.stage.playerForPlaylist(playlist))
    }
}

#if DEBUG
struct PlaylistRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistRow(playlist: previewContent.soundsets[0].playlists![0] as! Playlist)
            .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif
