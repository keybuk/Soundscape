//
//  PlaylistsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PlaylistsView: View {
    @EnvironmentObject var stage: Stage

    var playlists: [Playlist]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(playlists) { playlist in
                PlayerView(player: self.stage.playerForPlaylist(playlist))
            }
        }
    }
}

#if DEBUG
struct PlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            PlaylistsView(playlists: previewContent.soundsets[0].allPlaylists)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif
