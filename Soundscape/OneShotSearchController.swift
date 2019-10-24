//
//  OneShotSearchController.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

final class OneShotSearchController: ObservableObject {
    var managedObjectContext: NSManagedObjectContext

    @Published var search: String = "" {
        didSet {
            _playlists = nil
        }
    }

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    @Published private var _playlists: [Playlist]?
    var playlists: [Playlist] {
        if let playlists = _playlists { return playlists }

        let fetchRequest:  NSFetchRequest<ElementManagedObject> = ElementManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "kindRawValue == %d AND title CONTAINS[cd] %@", Playlist.Kind.oneShot.rawValue, search as NSString)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundset.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]

        var results: [ElementManagedObject]?
        managedObjectContext.performAndWait {
            results = try? fetchRequest.execute()
        }

        _playlists = results?.map { Playlist(managedObject: $0) } ?? []
        return _playlists!
    }

    func clear() {
        search = ""
    }
}
