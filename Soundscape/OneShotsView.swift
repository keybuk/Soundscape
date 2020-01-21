//
//  OneShotsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct OneShotsView: View {
    @State var search: String = ""
    @State var isSearching: Bool = false

    @ObservedObject var soundset: Soundset

    var body: some View {
        ScrollView {
            SearchField(search: $search, isSearching: $isSearching)
                .padding(.horizontal)
                .padding(isSearching ? .top : [])

            if isSearching {
                if !search.isEmpty {
                    PlaylistsBySoundset(fetchRequest: Playlist.fetchRequestGroupedBySoundset(kind: .oneShot, matching: search))
                        .padding(.horizontal)
                }
            } else {
                PlaylistGrid(fetchRequest: soundset.fetchRequestForPlaylists(kind: .oneShot))
                    .padding(.horizontal)
            }
        }
        .navigationBarTitle("One Shots")
        .navigationBarHidden(isSearching)
    }
}

#if DEBUG
struct OneshotsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OneShotsView(soundset: previewContent.soundsets[0])
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
