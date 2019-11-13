//
//  NowPlayingView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var stage: Stage

    var body: some View {
        VStack {
            Spacer(minLength: 8)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(stage.playlistsBySoundset, id: \.self) { soundsetPlaylists in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(soundsetPlaylists.first!.soundset.title)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.leading, 8)

                            ForEach(soundsetPlaylists.sorted(by: { $0.kind < $1.kind }).filter({ $0.kind != .oneShot })) { playlist in
                                NowPlayingRow(playlist: playlist)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))

            Spacer()
            NowPlayingBottomBar()
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarTitle("Now Playing")
        .navigationBarItems(trailing: Button(action: stage.stop) { Text("Stop") })
    }
}

struct NowPlayingRow: View {
    @EnvironmentObject var stage: Stage

    var playlist: Playlist

    var body: some View {
        HStack {
            PlayerView(player: self.stage.playerForPlaylist(playlist))

            if playlist.isLockable {
                if self.stage.lockedPlaylist == playlist {
                    Image(systemName: "lock")
                        .padding()
                        .onTapGesture {
                            self.stage.lockedPlaylist = nil
                        }
                } else {
                    Image(systemName: "lock.open")
                        .padding()
                        .onTapGesture {
                            self.stage.lockedPlaylist = self.playlist
                        }
                }
            }
        }
        .padding(.horizontal)
    }
}

#if DEBUG
struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NowPlayingView()
        }
        .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif
