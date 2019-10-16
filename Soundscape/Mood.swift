//
//  Mood.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

struct Mood: Identifiable, Hashable {
    var id: URL
    var title: String

    var playlists: [Parameters]

    struct Parameters {
        var playlist: Playlist
        var isPlaying: Bool
        var volume: Float
    }

    init(managedObject: MoodManagedObject, soundset: Soundset) {
        id = managedObject.objectID.uriRepresentation()
        title = managedObject.title!

        var playlists: [Parameters] = []
        if let elementParameters = managedObject.elementParameters {
            for case let elementParameterObject as ElementParameterManagedObject in elementParameters {
                guard let playlist = soundset.allPlaylists.first(where: { $0.id == elementParameterObject.element!.slug! }) else { continue }

                let parameters = Parameters(playlist: playlist, isPlaying: elementParameterObject.isPlaying, volume: elementParameterObject.volume)
                playlists.append(parameters)
            }
        }
        self.playlists = playlists
    }

    static func == (lhs: Mood, rhs: Mood) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
