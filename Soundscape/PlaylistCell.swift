//
//  PlaylistCell.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PlaylistCell: View {
    @EnvironmentObject var stage: Stage

    @ObservedObject var playlist: Playlist
    
    var body: some View {
        PlayerButton(player: stage.playerForPlaylist(playlist))
    }
}

#if DEBUG
struct PlaylistCell_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCell(playlist: previewContent.soundsets[0].playlists![4] as! Playlist)
            .padding()
            .previewLayout(.sizeThatFits)
            .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif

