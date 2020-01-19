//
//  Playlist+Kind.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Playlist {
    /// Kind of samples the playlist contains.
    var kind: Kind {
        get { Kind(rawValue: kindRawValue)! }
        set { kindRawValue = newValue.rawValue }
    }

    enum Kind: Int16, Comparable {
        /// Background music.
        case music

        /// Sound effects.
        case effect

        /// One-shot sound effects, played once on demand.
        case oneShot

        // Comparable support for now playing view.
        static func < (lhs: Playlist.Kind, rhs: Playlist.Kind) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}
