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
    @EnvironmentObject var audio: AudioManager
    @EnvironmentObject var stage: Stage

    @ObservedObject var soundset: Soundset

    var moods: [Mood] { soundset.moods!.array as! [Mood] }
    var elements: [Element] { soundset.elements!.array as! [Element] }
    var musicElements: [Element] { elements.filter { $0.kind == .music } }
    var effectElements: [Element] { elements.filter { $0.kind == .effect } }
    var oneshotElements: [Element] { elements.filter { $0.kind == .oneshot } }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SoundsetImageView(soundset: soundset)
                    .frame(height: 240)

                if !moods.isEmpty {
                    MoodsList(moods: moods)
                        .padding([.leading, .trailing])
                }

                if !musicElements.isEmpty {
                    ElementsList(elements: musicElements)
                        .padding([.leading, .trailing])
                }

                if !effectElements.isEmpty {
                    ElementsList(elements: effectElements)
                        .padding([.leading, .trailing])
                }

                if !oneshotElements.isEmpty {
                    ElementsList(elements: oneshotElements)
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
