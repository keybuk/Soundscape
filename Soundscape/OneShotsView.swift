//
//  OneShotsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

extension UIApplication {
    func endEditing(force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct OneShotsView: View {
    @State var search: String = ""
    @State var isSearching: Bool = false

    @ObservedObject var soundset: Soundset

    var body: some View {
        ScrollView {
            HStack {
                SearchField(search: $search, isSearching: $isSearching)

                if isSearching  {
                    Button("Cancel") {
                        UIApplication.shared.endEditing(force: true)
                        self.isSearching = false
                        self.search = ""
                    }
                    .foregroundColor(Color(.systemBlue))
                }
            }
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
