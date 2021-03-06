//
//  Soundset+Properties.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Soundset {
    /// Returns `true` if the soundset is available.
    var isActive: Bool { downloadedDate != nil }

    /// Returns `true` if the soundset has music playlists.
    var hasMusicPlaylists: Bool {
        playlists!.index { (obj, _, _) -> Bool in
            return (obj as! Playlist).kind == .music
        } != NSNotFound
    }

    /// Returns `true` if the soundset has effect playlists.
    var hasEffectPlaylists: Bool {
        playlists!.index { (obj, _, _) -> Bool in
            return (obj as! Playlist).kind == .effect
        } != NSNotFound
    }

    /// Returns `true` if the soundset has moods.
    var hasMoods: Bool { moods!.count > 0 }
}
