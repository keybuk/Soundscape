//
//  ElementsList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct ElementsList: View {
    @EnvironmentObject var audio: AudioManager
    @EnvironmentObject var stage: Stage

    var elements: [Element]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(elements) { element in
                PlayerView(player: self.stage.playerForElement(element, audio: self.audio))
            }
        }
    }
}

#if DEBUG
struct ElementsList_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ElementsList(elements: previewContent.soundsets[0].allElements)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .environmentObject(AudioManager())
        .environmentObject(Stage())
    }
}
#endif
