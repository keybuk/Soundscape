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
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @EnvironmentObject var stage: Stage
    @EnvironmentObject var oneShotSearchController: OneShotSearchController
    @ObservedObject var soundset: Soundset
    @State var isNowPlayingPresented: Bool = false
    @State var isOneShotsPresented: Bool = false

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
                    PlaylistsList(playlists: soundset.musicPlaylists)
                        .padding([.leading, .trailing])
                }

                if !soundset.effectPlaylists.isEmpty {
                    PlaylistsList(playlists: soundset.effectPlaylists)
                        .padding([.leading, .trailing])
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            Button(action: { self.isOneShotsPresented = true }) { Text("One Shots") }
                .sheet(isPresented: $isOneShotsPresented) {
                    NavigationView {
                        OneShotsList(soundset: self.soundset)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .environmentObject(self.stage)
                    .environmentObject(self.oneShotSearchController)
                }

            Button(action: { self.isNowPlayingPresented = true }) { Text("Now Playing") }
                .sheet(isPresented: $isNowPlayingPresented) {
                    NavigationView {
                        NowPlayingView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .environmentObject(self.stage)
                }
        })
    }
}

#if DEBUG
struct SoundsetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SoundsetView(soundset: previewContent.soundsets[0])
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environmentObject(OneShotSearchController(managedObjectContext: previewContent.managedObjectContext))
    }
}
#endif
