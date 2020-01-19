//
//  Playlist+Iterator.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Playlist {
    // FIXME: why not have OrderedIterator, ShuffledIterator, RandomIterator
    struct PlaylistIterator: Sequence, IteratorProtocol {
        private let playlist: Playlist
        private var entries: [PlaylistEntry]

        init(playlist: Playlist) {
            self.playlist = playlist
            self.entries = []

            fillPlaylist()
        }

        mutating func fillPlaylist() {
            // FIXME: expensive
            let playlistEntries = playlist.entries!.array as! [PlaylistEntry]

            switch playlist.order {
            case .ordered:
                entries = playlistEntries
            case .shuffled:
                entries = playlistEntries.shuffled()
            case .random:
                entries = [playlistEntries.randomElement()].compactMap { $0 }
            }
        }

        mutating func next() -> PlaylistEntry? {
            if entries.isEmpty {
                // Oneshot playlists always repeat since they only ever play one at a time,
                guard playlist.isRepeating || playlist.kind == .oneShot else { return nil }
                fillPlaylist()
            }

            guard !entries.isEmpty else { return nil }
            return entries.removeFirst()
        }
    }

    func makePlaylistIterator() -> PlaylistIterator {
        return PlaylistIterator(playlist: self)
    }
}
