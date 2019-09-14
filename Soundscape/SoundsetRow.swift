//
//  SoundsetRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetRow: View {
    @ObservedObject var soundset: Soundset

    var body: some View {
        VStack {
            SoundsetRowImage(image: soundset.image)
                .overlay(SoundsetRowTitle(title: soundset.title!), alignment: .bottomLeading)
        }
    }
}

struct SoundsetRowImage: View {
    var image: Image

    var body: some View {
        image
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 88)
            .cornerRadius(8)
    }
}

struct SoundsetRowTitle: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(Color.white)
            .shadow(color: Color.black, radius: 2)
            .padding(8)
    }
}

#if DEBUG
struct SoundsetRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewContent.soundsets) { soundset in
            SoundsetRow(soundset: soundset)
        }
    }
}
#endif
