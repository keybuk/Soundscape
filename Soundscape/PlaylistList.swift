//
//  PlaylistList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct PlaylistList: View {
    @FetchRequest
    var playlists: FetchedResults<Playlist>

    init(fetchRequest: NSFetchRequest<Playlist>) {
        _playlists = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        ForEach(playlists) { playlist in
            PlaylistRow(playlist: playlist)
        }
    }
}

#if DEBUG
struct PlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PlaylistList(fetchRequest: previewContent.soundsets[0].fetchRequestForPlaylists(kind: .music))
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
