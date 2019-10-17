//
//  PlayerView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            Button(action: self.togglePlaying) {
                Color(UIColor.secondarySystemGroupedBackground)
            }
            .layoutPriority(-1)

            HStack {
                PlayerStatusView(player: player)

                VStack(alignment: .leading, spacing: 0) {
                    Text("\(player.playlist.title)")
                    Slider(value: $player.volume, in: 0...1)
                        .onTapGesture {}
                }
            }
            .padding()
        }
        .cornerRadius(8)
    }

    func togglePlaying() {
        if player.isPlaying {
            player.stop()
        } else {
            player.play()
        }
    }
}

struct PlayerStatusView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            if player.isDownloading {
                Image(systemName: "icloud.and.arrow.down")
            } else if player.isPlaying {
                Image(systemName: "stop.fill")
            } else {
                Image(systemName: "play.fill")
            }
            PlayerProgress(player: player)
        }
        .frame(width: 30, height: 30)
    }
}

struct PlayerProgress: View {
    @ObservedObject var player: Player
    @State var progress: Double = 0

    var body: some View {
        ProgressCircle(progress: $progress)
            .onReceive(player.progressSubject.receive(on: RunLoop.main)) {
                self.progress = $0
            }
    }
}

#if DEBUG
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(player: Player(playlist: previewContent.soundsets[0].allPlaylists[0], audio: AudioManager()) )

    }
}
#endif
