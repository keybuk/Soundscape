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
        HStack {
            PlayerStatusButton(player: player)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("\(player.element.title!)")
                    if player.element.kind == .music {
                        Image(systemName: "music.note")
                    } else if player.element.kind == .effect {
                        Image(systemName: "bolt")
                    }
                }
                Slider(value: $player.volume, in: 0...1)
            }
        }
    }
}

struct PlayerStatusButton: View {
    @ObservedObject var player: Player
    @State var isPlaying: Bool = false
    @State var isDownloading: Bool = false
    @State var progress: Double = 0

    var body: some View {
        ZStack {
            Button(action: self.togglePlaying) {
                if isDownloading {
                    Image(systemName: "icloud.and.arrow.down")
                } else if isPlaying {
                    Image(systemName: "stop.fill")
                } else {
                    Image(systemName: "play.fill")
                }
            }
            ProgressCircle(progress: $progress)
        }
        .frame(width: 30, height: 30)
        .onReceive(player.status.receive(on: RunLoop.main)) { status in
            self.isDownloading = false
            switch status {
            case .stopped:
                self.isPlaying = false
                self.progress = 0
            case .downloading:
                self.isDownloading = true
            case let .waiting(progress):
                self.isPlaying = true
                self.progress = -progress
            case let .playing(progress):
                self.isPlaying = true
                self.progress = progress
            }
        }
    }

    func togglePlaying() {
        if isPlaying {
            player.stop()
        } else {
            player.play()
        }
    }
}

#if DEBUG
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(player: Player(element: previewContent.soundsets[0].elements![0] as! Element, audio: AudioManager()) )

    }
}
#endif
