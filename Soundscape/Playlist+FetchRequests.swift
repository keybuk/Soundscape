//
//  Playlist+FetchRequests.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Playlist {
    static func fetchRequestGroupedBySoundset(kind: Kind? = nil, matching search: String? = nil) -> NSFetchRequest<Playlist> {
        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()

        var predicates: [NSPredicate] = []
        if let kind = kind {
            predicates.append(NSPredicate(format: "kindRawValue == %d", kind.rawValue))
        }
        if let search = search, !search.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", search as NSString))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundset.title", ascending: true),
            NSSortDescriptor(key: "soundset", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]

        fetchRequest.propertiesToFetch = ["soundset"]

        return fetchRequest
    }
}
