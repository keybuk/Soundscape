//
//  OneshotsList.swift
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

struct OneShotsList: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var stage: Stage
    @EnvironmentObject var searchController: OneShotSearchController

    @State var search: String = ""
    @State var isSearching: Bool = false

    @ObservedObject var soundset: Soundset

    var numberOfColumns: Int { horizontalSizeClass == .compact ? 2 : 3 }
    var playlists: [Playlist] { isSearching ? searchController.playlists : soundset.oneShotPlaylists }
    var playlistsBySoundset: [ArraySlice<Playlist>] { isSearching ? searchController.playlistsBySoundset : [soundset.oneShotPlaylists.dropFirst(0)] }

    var body: some View {
        ScrollView {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $search, onEditingChanged: { _ in
                        self.isSearching = true
                    }, onCommit: {
                        self.searchController.search = self.search
                    })
                    .foregroundColor(.primary)
                    if !search.isEmpty {
                        Button(action: {
                            self.search = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                .foregroundColor(.secondary)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)

                if isSearching  {
                    Button("Cancel") {
                        UIApplication.shared.endEditing(force: true)
                        self.search = ""
                        self.isSearching = false
                        self.searchController.clear()
                    }
                    .foregroundColor(Color(.systemBlue))
                }
            }
            .padding(.horizontal)
            .padding(isSearching ? .top : [])

            VStack(spacing: 12) {
                ForEach(playlistsBySoundset, id: \.self) { soundsetPlaylists in
                    VStack(alignment: .leading, spacing: 8) {
                        if self.isSearching {
                            Text("\(soundsetPlaylists.first!.soundset.title)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                        }

                        ForEach(Array(soundsetPlaylists).chunked(into: self.numberOfColumns), id: \.self) { playlistRow in
                            HStack(spacing: 8) {
                                ForEach(playlistRow) { playlist in
                                    PlayerButton(player: self.stage.playerForPlaylist(playlist))
                                }

                                ForEach(playlistRow.count..<self.numberOfColumns, id: \.self) { _ in
                                    Spacer()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationBarTitle("One Shots")
        .navigationBarHidden(isSearching)
    }
}

struct OneshotsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OneShotsList(soundset: previewContent.soundsets[0])
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environmentObject(OneShotSearchController(managedObjectContext: previewContent.managedObjectContext))
    }
}
