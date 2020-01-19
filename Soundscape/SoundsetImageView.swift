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
        Text(soundset.title!)
            .font(.headline)
            .foregroundColor(Color.white)
            .shadow(color: Color.black, radius: 2)
            .padding(8)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading)
            .background(SoundsetImage(soundset: soundset))
            .clipped()
    }
}

#if DEBUG
struct SoundsetImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            SoundsetImageView(soundset: previewContent.soundsets[0])
                .frame(maxHeight: 88)
                .cornerRadius(8)

            SoundsetImageView(soundset: previewContent.soundsets[0])
                .frame(maxHeight: 240)

            SoundsetImageView(soundset: previewContent.soundsets[0])
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
        }
        .padding()
    }
}
#endif
