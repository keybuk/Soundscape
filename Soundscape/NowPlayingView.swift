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

//    var groupedElements: [Soundset: [Element]] {
//        .init(grouping: stage.elements) {
//            $0.soundset!
//        }
//    }

    var body: some View {
        VStack {
            Spacer(minLength: 8)

            ScrollView {
//                ForEach(groupedElements.keys.sorted { $0.title! < $1.title! }) { soundset in
//                Section(header: Text("\(soundset.title!)")) {
//                ForEach(self.groupedElements[soundset]!.sorted(by: { $0.kind.rawValue < $1.kind.rawValue }).filter({ $0.kind != .oneShot })) { element in

                VStack(spacing: 8) {
                    ForEach(stage.playlists.sorted(by: { $0.kind < $1.kind }).filter({ $0.kind != .oneShot })) { playlist in
                        if playlist.kind == .music {
                            HStack {
                                PlayerView(player: self.stage.playerForPlaylist(playlist))

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
                                            self.stage.lockedPlaylist = playlist
                                        }
                                }
                            }
                            .padding([.leading, .trailing])
                        } else {
                            PlayerView(player: self.stage.playerForPlaylist(playlist))
                            .padding([.leading, .trailing])
                        }
                    }
                }
                .padding([.top, .bottom])
//                }
//                }
                //                }

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
    }
}
#endif
