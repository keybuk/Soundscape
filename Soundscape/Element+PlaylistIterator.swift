//
//  Element+PlaylistIterator.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Element {
    struct PlaylistIterator: Sequence, IteratorProtocol {
        private let element: Element
        private var playlist: [PlaylistEntry]

        init(element: Element) {
            self.element = element
            self.playlist = []

            fillPlaylist()
        }

        mutating func fillPlaylist() {
            let playlistEntries = element.playlistEntries!.array as! [PlaylistEntry]

            switch element.order {
            case .ordered:
                playlist = playlistEntries
            case .shuffled:
                playlist = playlistEntries.shuffled()
            case .random:
                playlist = [playlistEntries.randomElement()].compactMap { $0 }
            }
        }

        mutating func next() -> PlaylistEntry? {
            if playlist.isEmpty {
                guard element.isRepeating else { return nil }
                fillPlaylist()
            }

            guard !playlist.isEmpty else { return nil }
            return playlist.removeFirst()
        }
    }

    func makePlaylistIterator() -> PlaylistIterator {
        return PlaylistIterator(element: self)
    }
}
