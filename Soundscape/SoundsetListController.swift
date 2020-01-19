//
//  SoundsetListController.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

final class SoundsetListController: ObservableObject {
    var managedObjectContext: NSManagedObjectContext

    @Published var category: Soundset.Category = .fantasy {
        didSet {
            _soundsets = nil
        }
    }

    @Published var search: String = "" {
        didSet {
            _soundsets = nil
        }
    }

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // FIXME: do we really need a cache here? how often is this re-fetched incorrectly?
    @Published private var _soundsets: [Soundset]?
    var soundsets: [Soundset] {
        if let soundsets = _soundsets { return soundsets }

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

        var results: [Soundset]?
        managedObjectContext.performAndWait {
            results = try? fetchRequest.execute()
        }

        _soundsets = results ?? []
        return _soundsets!
    }
}


