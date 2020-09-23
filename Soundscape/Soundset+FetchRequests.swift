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
    static func fetchRequestSorted(category: Category? = nil, matching search: String? = nil) -> NSFetchRequest<Soundset> {
        let fetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()

        var predicates: [NSPredicate] = []
        if let category = category {
            predicates.append(NSPredicate(format: "categoryRawValue == %d", category.rawValue))
        }
        if let search = search, !search.isEmpty {
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "title CONTAINS[cd] %@", search as NSString),
                NSPredicate(format: "moods.title CONTAINS[cd] %@", search as NSString),
                NSPredicate(format: "playlists.title CONTAINS[cd] %@", search as NSString)
            ]))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
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

    /// Returns an `NSFetchRequest` for this soundset's moods.
    func fetchRequestForMoods() -> NSFetchRequest<Mood> {
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "soundset == %@", self)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundset", ascending: true)
        ]

        return fetchRequest
    }

}
