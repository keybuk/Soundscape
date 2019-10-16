//
//  ElementRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct ElementRow: View {
    @EnvironmentObject var audio: AudioManager
    @EnvironmentObject var stage: Stage

    var element: Element

    var body: some View {
        PlayerView(player: self.stage.playerForElement(element, audio: self.audio))
    }
}

#if DEBUG
struct ElementRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewContent.soundsets[0].allElements) { element in
            ElementRow(element: element)
        }
        .environmentObject(AudioManager())
        .environmentObject(Stage())
    }
}
#endif
