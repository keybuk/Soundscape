//
//  ElementRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct ElementRow: View {
    @EnvironmentObject var stage: Stage

    var playlist: Playlist

    var body: some View {
        PlayerView(player: self.stage.playerForPlaylist(playlist))
    }
}

#if DEBUG
struct ElementRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewContent.soundsets[0].allPlaylists) { playlist in
            ElementRow(playlist: playlist)
        }
        .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif
