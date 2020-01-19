//
//  Playlist+Looping.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Playlist {
    /// Range of delay in seconds before playing the first entry in this playlist as part of a mood.
    var startDelay: ClosedRange<Double> { minStartDelay...maxStartDelay }

    /// Range of delay in seconds between entries in this playlist.
    var sampleGap: ClosedRange<Double> { minSampleGap...maxSampleGap }

    /// Range of 3D positional angle for any entry in this playlist.
    var angle: ClosedRange<Float> { minAngle...maxAngle }

    /// Range of 3D positional distance for any entry in this playlist.
    var distance: ClosedRange<Float> { minDistance...maxDistance }

    /// Returns `true` when the playlist is suitable for looping.
    ///
    /// A playlist is suitable for looping when it contains a single music track, or a randomly selected
    /// music track. When `true` if a sample contains a loop, the loop will be repeated rather than
    /// the playlist iterated.
    var isLooping: Bool {
        // FIXME: this is misnamed
        kind == .music && ((entries!.count == 1) || (order == .random))
    }
}
