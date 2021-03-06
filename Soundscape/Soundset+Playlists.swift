//
//  Soundset+Playlists.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Soundset {
    // FIXME: this could be fetch requests.
    var oneShotPlaylists: [Playlist] {
        (playlists!.array as! [Playlist])
            .filter { $0.kind == .oneShot }
    }
}
