//
//  Campaign+FetchRequests.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/23/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Campaign {
    /// Returns an `NSFetchRequest` for soundsets sorted by title.
    static func fetchRequestSorted(matching search: String? = nil) -> NSFetchRequest<Campaign> {
        let fetchRequest: NSFetchRequest<Campaign> = Campaign.fetchRequest()

        var predicates: [NSPredicate] = []
        if let search = search, !search.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", search as NSString))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        return fetchRequest
    }
}
