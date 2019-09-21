//
//  SearchController.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/21/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

final class SearchController: ObservableObject {
    var search: String
    var managedObjectContext: NSManagedObjectContext

    init(search: String, context managedObjectContext: NSManagedObjectContext) {
        self.search = search
        self.managedObjectContext = managedObjectContext
    }

    lazy var soundsets: [Soundset] = {
        let fetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", search)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Soundset.title, ascending: true)
        ]

        var results: [Soundset]?
        managedObjectContext.performAndWait {
            results = try? fetchRequest.execute()
        }

        return results ?? []
    }()

    lazy var moods: [Mood] = {
        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", search)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Mood.title, ascending: true)
        ]

        var results: [Mood]?
        managedObjectContext.performAndWait {
            results = try? fetchRequest.execute()
        }

        return results ?? []
    }()

    lazy var elements: [Element] = {
        let fetchRequest: NSFetchRequest<Element> = Element.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", search)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Element.title, ascending: true)
        ]

        var results: [Element]?
        managedObjectContext.performAndWait {
            results = try? fetchRequest.execute()
        }

        return results ?? []
    }()
    

}
