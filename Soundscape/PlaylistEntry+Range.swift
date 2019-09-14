//
//  PlaylistEntry+Range.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension PlaylistEntry {
    var volume: ClosedRange<Float> {
        get { minVolume...maxVolume }
        set {
            minVolume = newValue.lowerBound
            maxVolume = newValue.upperBound
        }
    }
}
