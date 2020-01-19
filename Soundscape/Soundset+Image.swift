//
//  Soundset+Image.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreGraphics

extension Soundset {
    /// Returns `true` if the soundset is available.
    var isActive: Bool { downloadedDate != nil }

    /// Returns the appropriate image for the soundset.
    var image: Image { isActive ? activeImage : inactiveImage }

    /// Returns an image appropriate for a soundset that is available.
    var activeImage: Image {
        // FIXME: Repeated compute!
        if let imageData = activeImageData,
            let dataProvider = CGDataProvider(data: imageData as CFData),
            let cgImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        {
            return Image(decorative: cgImage, scale: 1.0)
        } else {
            return Image("SoundsetImagePlaceholder")
        }
    }

    /// Returns an image appropriate for a soundset that is unavailable.
    var inactiveImage: Image {
        // FIXME: Repeated compute!
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

