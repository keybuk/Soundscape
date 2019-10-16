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
            SoundsetImageView(soundset: soundset)
                .frame(height: 88)
                .cornerRadius(8)
        }
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
