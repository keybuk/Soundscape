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
                PlayerStatusButton(player: player, action: self.togglePlaying)

                VStack(alignment: .leading, spacing: 0) {
                    Text("\(player.element.title!)")
                    Slider(value: $player.volume, in: 0...1)
                        .onTapGesture {}
                }
            }
            .padding()
        }
        .cornerRadius(8)
    }

    func togglePlaying() {
        if case .stopped = player.status {
            player.play()
        } else {
            player.stop()
        }
    }
}

struct PlayerStatusButton: View {
    @ObservedObject var player: Player
    var action: () -> Void

    var isDownloading: Bool {
        if case .downloading = player.status { return true }
        return false
    }

    var isPlaying: Bool {
        if case .stopped = player.status { return false }
        return true
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
            Button(action: action) {
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
}

#if DEBUG
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(player: Player(element: previewContent.soundsets[0].elements![0] as! Element, audio: AudioManager()) )

    }
}
#endif
