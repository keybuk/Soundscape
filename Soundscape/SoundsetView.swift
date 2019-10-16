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
    @ObservedObject var soundset: Soundset

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SoundsetImageView(soundset: soundset)
                    .frame(height: 240)

                if !soundset.moods.isEmpty {
                    MoodsList(moods: soundset.moods)
                        .padding([.leading, .trailing])
                }

                if !soundset.musicElements.isEmpty {
                    ElementsList(elements: soundset.musicElements)
                        .padding([.leading, .trailing])
                }

                if !soundset.effectElements.isEmpty {
                    ElementsList(elements: soundset.effectElements)
                        .padding([.leading, .trailing])
                }

                if !soundset.oneshotElements.isEmpty {
                    ElementsList(elements: soundset.oneshotElements)
                        .padding([.leading, .trailing])
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarItems(trailing: NavigationLink(destination: NowPlayingView()) { Text("Now Playing") })
    }
}

#if DEBUG
struct SoundsetView_Previews: PreviewProvider {
    static var previews: some View {
        SoundsetView(soundset: previewContent.soundsets[0])
            .environmentObject(AudioManager())
            .environmentObject(Stage())
    }
}
#endif
