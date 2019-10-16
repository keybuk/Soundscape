//
//  SoundsetView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct SoundsetView: View {
    @ObservedObject var soundset: Soundset

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SoundsetImageView(soundset: soundset)
                    .frame(height: 240)

                if !soundset.moods.isEmpty {
                    MoodsList(moods: soundset.moods)
                        .padding([.leading, .trailing])
                }

                if !soundset.musicPlaylists.isEmpty {
                    PlaylistsView(playlists: soundset.musicPlaylists)
                        .padding([.leading, .trailing])
                }

                if !soundset.effectPlaylists.isEmpty {
                    PlaylistsView(playlists: soundset.effectPlaylists)
                        .padding([.leading, .trailing])
                }

                if !soundset.oneshotPlaylists.isEmpty {
                    PlaylistsView(playlists: soundset.oneshotPlaylists)
                        .padding([.leading, .trailing])
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarItems(trailing: NavigationLink(destination: NowPlayingView()) { Text("Now Playing") })
    }
}

#if DEBUG
struct SoundsetView_Previews: PreviewProvider {
    static var previews: some View {
        SoundsetView(soundset: previewContent.soundsets[0])
            .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif
