//
//  Soundset+FetchRequests.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Soundset {
    /// Returns an `NSFetchRequest` for soundsets sorted by title.
    static func fetchRequestSorted() -> NSFetchRequest<Soundset> {
        let fetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        return fetchRequest
    }

    /// Returns an `NSFetchRequest` for this soundset's playlists, filtered by `kind`.
    func fetchRequestForPlaylists(kind: Playlist.Kind) -> NSFetchRequest<Playlist> {
        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "soundset == %@ AND kindRawValue == %d", self, kind.rawValue)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundset", ascending: true)
        ]

        return fetchRequest
    }
}
