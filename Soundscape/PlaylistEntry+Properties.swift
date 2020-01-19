//
//  PlaylistEntry+Properties.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension PlaylistEntry {
    /// Range of volume (from 0.0 to 1.0) for the specific sample being played.
    ///
    /// This applies a variation in volume between samples in a playlist within the bounds of the
    /// set environmental volume applying to the playlist as a whole.
    var volume: ClosedRange<Float> { minVolume...maxVolume }
}
