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

}
