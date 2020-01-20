//
//  PlaylistGrid.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct PlaylistGrid: View {
    @FetchRequest
    var playlists: FetchedResults<Playlist>

    init(fetchRequest: NSFetchRequest<Playlist>) {
        _playlists = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        Grid(playlists) { playlist in
            PlaylistCell(playlist: playlist)
        }
    }
}

#if DEBUG
struct PlaylistGrid_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                PlaylistGrid(fetchRequest: previewContent.soundsets[0].fetchRequestForPlaylists(kind: .oneShot))
            }
            .padding()
            .previewDevice("iPhone 11 Pro")

            ScrollView {
                PlaylistGrid(fetchRequest: previewContent.soundsets[0].fetchRequestForPlaylists(kind: .oneShot))
            }
            .padding()
            .previewDevice("iPad Air (3rd generation)")
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
