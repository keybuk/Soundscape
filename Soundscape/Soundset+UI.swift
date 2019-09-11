//
//  Soundset+UI.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreGraphics

extension Soundset: Identifiable {}

extension Soundset {
    var image: Image { downloadedDate != nil ? activeImage : inactiveImage }

    var activeImage: Image {
        if let imageData = imageData,
            let dataProvider = CGDataProvider(data: imageData as CFData),
            let cgImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        {
            return Image(decorative: cgImage, scale: 1.0)
        } else {
            return Image("SoundsetImagePlaceholder")
        }
    }

    var inactiveImage: Image {
        if let imageData = inactiveImageData,
            let dataProvider = CGDataProvider(data: imageData as CFData),
            let cgImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        {
            return Image(decorative: cgImage, scale: 1.0)
        } else {
            return Image("SoundsetInactiveImagePlaceholder")
        }
    }
}
