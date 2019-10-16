//
//  Element.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

struct Element: Identifiable, Hashable {
    var id: String
    var title: String
    var kind: Kind
    var order: Order
    var isRepeating: Bool
    var isOverlapping: Bool
    var initialVolume: Float
    var startDelay: ClosedRange<Double>
    var sampleGap: ClosedRange<Double>

    var playlist: [PlaylistEntry]

    enum Kind: Int16, Comparable {
        case music
        case effect
        case oneshot

        static func < (lhs: Element.Kind, rhs: Element.Kind) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum Order: Int16 {
        case ordered
        case shuffled
        case random
    }

    struct PlaylistEntry {
        var sample: Sample
        var volume: ClosedRange<Float>
    }

    init(managedObject: ElementManagedObject) {
        id = managedObject.slug!
        title = managedObject.title!
        kind = Kind(rawValue: managedObject.kindRawValue)!
        order = Order(rawValue: managedObject.orderRawValue)!
        isRepeating = managedObject.isRepeating
        isOverlapping = managedObject.isOverlapping
        initialVolume = managedObject.initialVolume
        startDelay = managedObject.minStartDelay...managedObject.maxStartDelay
        sampleGap = managedObject.minSampleGap...managedObject.maxSampleGap

        playlist = []
        if let playlistEntryObjects = managedObject.playlistEntries {
            for case let playlistEntryObject as PlaylistEntryManagedObject in playlistEntryObjects {
                let sample = Sample(managedObject: playlistEntryObject.sample!)
                let playlistEntry = PlaylistEntry(sample: sample, volume: playlistEntryObject.minVolume...playlistEntryObject.maxVolume)
                playlist.append(playlistEntry)
            }
        }
    }

    struct PlaylistIterator: Sequence, IteratorProtocol {
        private let element: Element
        private var playlist: [PlaylistEntry]

        init(element: Element) {
            self.element = element
            self.playlist = []

            fillPlaylist()
        }

        mutating func fillPlaylist() {
            switch element.order {
            case .ordered:
                playlist = element.playlist
            case .shuffled:
                playlist = element.playlist.shuffled()
            case .random:
                playlist = [element.playlist.randomElement()].compactMap { $0 }
            }
        }

        mutating func next() -> PlaylistEntry? {
            if playlist.isEmpty {
                // Oneshot playlists always repeat since they only ever play one at a time,
                guard element.isRepeating || element.kind == .oneshot else { return nil }
                fillPlaylist()
            }

            guard !playlist.isEmpty else { return nil }
            return playlist.removeFirst()
        }
    }

    func makePlaylistIterator() -> PlaylistIterator {
        return PlaylistIterator(element: self)
    }

    static func == (lhs: Element, rhs: Element) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
