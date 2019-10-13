//
//  SoundsetImageView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetImageView: View {
    @ObservedObject var soundset: Soundset

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .background(SoundsetImageViewBackground(soundset: soundset))
            .overlay(SoundsetImageViewOverlay(soundset: soundset), alignment: .bottomLeading)
            .cornerRadius(8)
    }
}

struct SoundsetImageViewBackground: View {
    @ObservedObject var soundset: Soundset

    var body: some View {
        soundset.image
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

struct SoundsetImageViewOverlay: View {
    @ObservedObject var soundset: Soundset

    var body: some View {
        Text(soundset.title!)
            .font(.headline)
            .foregroundColor(Color.white)
            .shadow(color: Color.black, radius: 2)
            .padding(8)
    }
}

#if DEBUG
struct SoundsetImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SoundsetImageView(soundset: previewContent.soundsets[0])
                .frame(maxHeight: 88)

            SoundsetImageView(soundset: previewContent.soundsets[0])
                .frame(maxHeight: 240)

            SoundsetImageView(soundset: previewContent.soundsets[0])
                .aspectRatio(1, contentMode: .fit)
        }
        .padding()
    }
}
#endif
