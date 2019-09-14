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
        private var indices: [Array<PlaylistEntry>.Index]

        init(element: Element) {
            self.element = element
            self.indices = []

            fillIndices()
        }

        mutating func fillIndices() {
            switch element.order {
            case .ordered:
                indices = Array(element.playlistEntries!.array.indices)
            case .shuffled:
                indices = element.playlistEntries!.array.indices.shuffled()
            case .random:
                indices = [element.playlistEntries!.array.indices.randomElement()!]
            }
        }

        mutating func next() -> PlaylistEntry? {
            if indices.isEmpty {
                guard element.isRepeating else { return nil }
                fillIndices()
            }
            guard !indices.isEmpty else { return nil }

            return element.playlistEntries!.object(at: indices.removeFirst()) as? PlaylistEntry
        }
    }

    func makePlaylistIterator() -> PlaylistIterator {
        return PlaylistIterator(element: self)
    }
}
