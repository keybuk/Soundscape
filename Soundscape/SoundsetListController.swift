//
//  SoundsetListController.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

/// Controller for lists of `Soundset`.
///
/// An `ObservableObject` with two published properties `category` and `search` that can be used to filter the collection of
/// soundsets. Both can vend bindings with `$controller.category` and `$controller.search`, and both when changed
/// emit the controller's `objectWillChange` publisher.
///
/// An `NSFetchRequest` matching the current filter can be obtained from the `fetchRequest` property.
final class SoundsetListController: ObservableObject {
    /// Category of soundsets to fetch.
    @Published var category: Soundset.Category = .fantasy

    /// Fetch soundsets containing this text in the title.
    @Published var search: String = ""

    var fetchRequest: NSFetchRequest<Soundset> {
        let fetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()

        let categoryPredicate = NSPredicate(format: "categoryRawValue == %d", category.rawValue)
        if !search.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", search as NSString)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, searchPredicate])
        } else {
            fetchRequest.predicate = categoryPredicate
        }

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        return fetchRequest
    }
}
