//
//  Playlist.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

struct Playlist: Identifiable, Hashable {
    var id: String
    var title: String
    var kind: Kind
    var order: Order
    var isRepeating: Bool
    var isOverlapping: Bool
    var initialVolume: Float
    var startDelay: ClosedRange<Double>
    var sampleGap: ClosedRange<Double>
    var is3D: Bool
    var angle: ClosedRange<Float>
    var distance: ClosedRange<Float>
    var speed: Double

    var entries: [PlaylistEntry]

    enum Kind: Int16, Comparable {
        case music
        case effect
        case oneShot
        
        static func < (lhs: Playlist.Kind, rhs: Playlist.Kind) -> Bool {
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

    var soundset: Soundset

    var isLooping: Bool {
        kind == .music && ((entries.count == 1) || (order == .random))
    }

    init(managedObject: ElementManagedObject, soundset: Soundset? = nil) {
        self.soundset = soundset ?? Soundset(managedObject: managedObject.soundset!)

        id = managedObject.slug!
        title = managedObject.title!
        kind = Kind(rawValue: managedObject.kindRawValue)!
        order = Order(rawValue: managedObject.orderRawValue)!
        isRepeating = managedObject.isRepeating
        isOverlapping = managedObject.isOverlapping
        initialVolume = managedObject.initialVolume
        startDelay = managedObject.minStartDelay...managedObject.maxStartDelay
        sampleGap = managedObject.minSampleGap...managedObject.maxSampleGap
        is3D = managedObject.is3D
        angle = managedObject.minAngle...managedObject.maxAngle
        distance = managedObject.minDistance...managedObject.maxDistance
        speed = managedObject.speed

        entries = []
        if let playlistEntryObjects = managedObject.playlistEntries {
            for case let playlistEntryObject as PlaylistEntryManagedObject in playlistEntryObjects {
                let sample = Sample(managedObject: playlistEntryObject.sample!)
                let playlistEntry = PlaylistEntry(sample: sample, volume: playlistEntryObject.minVolume...playlistEntryObject.maxVolume)
                entries.append(playlistEntry)
            }
        }
    }

    struct PlaylistIterator: Sequence, IteratorProtocol {
        private let playlist: Playlist
        private var entries: [PlaylistEntry]

        init(playlist: Playlist) {
            self.playlist = playlist
            self.entries = []

            fillPlaylist()
        }

        mutating func fillPlaylist() {
            switch playlist.order {
            case .ordered:
                entries = playlist.entries
            case .shuffled:
                entries = playlist.entries.shuffled()
            case .random:
                entries = [playlist.entries.randomElement()].compactMap { $0 }
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

    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
