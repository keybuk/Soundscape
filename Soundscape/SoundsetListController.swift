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

final class SoundsetListController: ObservableObject, RandomAccessCollection {
    var managedObjectContext: NSManagedObjectContext
    @Published var category: Soundset.Category = .fantasy
    @Published var search: String = ""

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    @Published private var _results: [SoundsetManagedObject]?
    var results: [SoundsetManagedObject] {
        if let results = _results { return results }

        let fetchRequest: NSFetchRequest<SoundsetManagedObject> = SoundsetManagedObject.fetchRequest()

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

        var results: [SoundsetManagedObject]?
        managedObjectContext.performAndWait {
            results = try? fetchRequest.execute()
        }

        _results = results ?? []
        return _results!
    }

    private var soundsets: [NSManagedObjectID: Soundset] = [:]

    var startIndex: Int { results.startIndex }
    var endIndex: Int { results.endIndex }

    subscript(position: Int) -> Soundset {
        let managedObject = results[position]
        if let soundset = soundsets[managedObject.objectID] {
            return soundset
        } else {
            let soundset = Soundset(managedObject: managedObject)
            soundsets[managedObject.objectID] = soundset
            return soundset
        }
    }

    func index(after i: Int) -> Int {
        results.index(after: i)
    }

    func index(before i: Int) -> Int {
        results.index(before: i)
    }
}


