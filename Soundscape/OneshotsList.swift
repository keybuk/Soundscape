//
//  OneshotsList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct OneShotsList: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @EnvironmentObject var stage: Stage

    @ObservedObject var controller: PlaylistListController

    var numberOfColumns: Int { horizontalSizeClass == .compact ? 2 : 3 }

    var body: some View {
        ScrollView {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $controller.search)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Image(systemName: "clear.fill")
                    .onTapGesture {
                        self.controller.search = ""
                }
            }
            .padding([.leading, .trailing])

            VStack(spacing: 8) {
                ForEach(controller.playlists.chunked(into: numberOfColumns), id: \.self) { playlistRow in
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
            .padding([.leading, .trailing])
        }
        .navigationBarTitle("One Shots")
    }
}

struct OneshotsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OneShotsList(controller: PlaylistListController(managedObjectContext: previewContent.managedObjectContext, kind: .oneShot, soundset: previewContent.soundsets[0]))
        }
        .environmentObject(Stage(audio: AudioManager()))
    }
}
