//
//  PlaylistListController.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

final class PlaylistListController: ObservableObject {
    var managedObjectContext: NSManagedObjectContext

    @Published var kind: Playlist.Kind {
        didSet {
            _playlists = nil
        }
    }

    @Published var soundset: Soundset? {
        didSet {
            _playlists = nil
        }
    }

    @Published var search: String = "" {
        didSet {
            _playlists = nil
        }
    }

    init(managedObjectContext: NSManagedObjectContext, kind: Playlist.Kind, soundset: Soundset?) {
        self.managedObjectContext = managedObjectContext
        self.kind = kind
        self.soundset = soundset
    }

    @Published private var _playlists: [Playlist]?
    var playlists: [Playlist] {
        if let playlists = _playlists { return playlists }
        if search.isEmpty, let soundset = soundset {
            switch kind {
            case .music: return soundset.musicPlaylists
            case .effect: return soundset.effectPlaylists
            case .oneshot: return soundset.oneshotPlaylists
            }
        }

        let fetchRequest:  NSFetchRequest<ElementManagedObject> = ElementManagedObject.fetchRequest()

        let kindPredicate = NSPredicate(format: "kindRawValue == %d", kind.rawValue)
        if !search.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", search as NSString)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [kindPredicate, searchPredicate])
        } else {
            fetchRequest.predicate = kindPredicate
        }

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
}
