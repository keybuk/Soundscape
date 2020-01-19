//
//  PlayerButton.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct PlayerButton: View {
    @ObservedObject var player: Player

    var body: some View {
        Button(action: self.play) {
            HStack {
                PlayerStatusView(player: player)

                Text("\(player.playlist.title!)")
                    .lineLimit(1)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color(UIColor.label))
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }

    func play() {
        player.play()
    }
}

#if DEBUG
struct PlayerButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayerButton(player: Player(playlist: previewContent.soundsets[0].oneShotPlaylists[0], audio: AudioManager()))
            .previewLayout(.sizeThatFits)
    }
}
#endif
