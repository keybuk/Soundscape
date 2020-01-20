//
//  SoundsetImage.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetImage: View {
    @ObservedObject var soundset: Soundset

    var body: some View {
        let image: Image
        if let imageData = soundset.isActive ? soundset.activeImageData : soundset.inactiveImageData,
            let dataProvider = CGDataProvider(data: imageData as CFData),
            let cgImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        {
            image = Image(decorative: cgImage, scale: 1.0)
        } else {
            image = Image(soundset.isActive ? "SoundsetImagePlaceholder" : "SoundsetInactiveImagePlaceholder")
        }

        return image
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

#if DEBUG
struct SoundsetImage_Previews: PreviewProvider {
    static var previews: some View {
        SoundsetImage(soundset: previewContent.soundsets[0])
            .previewLayout(.sizeThatFits)
    }
}
#endif
