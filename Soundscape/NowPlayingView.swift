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
                SectionedList(stage.playlists, id: \.soundset) { soundsetPlaylists in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(soundsetPlaylists.first!.soundset!.title!)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)

                        NowPlayingMoodList(fetchRequest: soundsetPlaylists.first!.soundset!.fetchRequestForMoods())

                        ForEach(soundsetPlaylists) { playlist in
                            NowPlayingRow(playlist: playlist)
                        }
                    }
                }
                .padding()
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

#if DEBUG
struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NowPlayingView()
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
