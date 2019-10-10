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

    var isDownloading: Bool {
        if case .downloading = player.status { return true }
        return false
    }

    var isPlaying: Bool {
        if case .playing(_) = player.status { return true }
        if case .waiting(_) = player.status { return true }
        return false
    }

    var progress: Double {
        switch player.status {
        case .stopped: return 0
        case .downloading: return 0
        case let .waiting(progress): return -progress
        case let .playing(progress): return progress
        }
    }

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
            ProgressCircle(progress: progress)
        }
        .frame(width: 30, height: 30)
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
