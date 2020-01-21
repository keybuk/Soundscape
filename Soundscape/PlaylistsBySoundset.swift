//
//  PlaylistsBySoundset.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct PlaylistsBySoundset: View {
    @FetchRequest
    var playlists: FetchedResults<Playlist>

    init(fetchRequest: NSFetchRequest<Playlist>) {
        _playlists = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        SectionedList(playlists, id: \.soundset) { soundsetPlaylists in
            VStack(alignment: .leading, spacing: 8) {
                Text("\(soundsetPlaylists.first!.soundset!.title!)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)

                Grid(soundsetPlaylists) { playlist in
                    PlaylistCell(playlist: playlist)
                }
            }
        }
    }
}

#if DEBUG
struct PlaylistsBySoundset_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                PlaylistsBySoundset(fetchRequest: Playlist.fetchRequestGroupedBySoundset())
            }
            .padding()
            .previewDevice("iPhone 11 Pro")

            ScrollView {
                PlaylistsBySoundset(fetchRequest: Playlist.fetchRequestGroupedBySoundset())
            }
            .padding()
            .previewDevice("iPad Air (3rd generation)")
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
