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

                if soundset.hasMoods {
                    MoodGrid(fetchRequest: soundset.fetchRequestForMoods())
                        .padding(.horizontal)
                }

                if soundset.hasMusicPlaylists {
                    VStack(spacing: 8) {
                        PlaylistList(fetchRequest: soundset.fetchRequestForPlaylists(kind: .music))
                    }
                    .padding(.horizontal)
                }

                if soundset.hasEffectPlaylists {
                    VStack(spacing: 8) {
                        PlaylistList(fetchRequest: soundset.fetchRequestForPlaylists(kind: .effect))
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CampaignsButton(soundset: self.soundset)
            }

            ToolbarItem(placement: .primaryAction) {
                OneShotsButton(soundset: self.soundset)
            }

            ToolbarItem(placement: .primaryAction) {
                NowPlayingButton()
            }

        }
    }
}

#if DEBUG
struct SoundsetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SoundsetView(soundset: previewContent.soundsets[0])
            }

            NavigationView {
                SoundsetView(soundset: previewContent.soundsets[0])
            }
            .environment(\.colorScheme, .dark)
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
