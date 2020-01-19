//
//  Playlist+Order.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Playlist {
    /// Order in which to play the entries.
    var order: Order {
        get { Order(rawValue: orderRawValue)! }
        set { orderRawValue = newValue.rawValue }
    }

    enum Order: Int16 {
        /// Entries are played in the order given in the playlist.
        case ordered

        /// Entries are shuffled, and then each one played in turn, before shuffling again.
        case shuffled

        /// Entries are picked at random repeatedly.
        case random
    }
}
