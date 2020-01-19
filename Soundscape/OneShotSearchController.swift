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
            _playlistsBySoundset = nil
        }
    }

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // FIXME: do we really need a cache here? how often is this re-fetched incorrectly?
    @Published private var _playlists: [Playlist]?
    var playlists: [Playlist] {
        if let playlists = _playlists { return playlists }

        let fetchRequest:  NSFetchRequest<Playlist> = Playlist.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "kindRawValue == %d AND title CONTAINS[cd] %@", Playlist.Kind.oneShot.rawValue, search as NSString)

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "soundset.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]

        var results: [Playlist]?
        managedObjectContext.performAndWait {
            results = try? fetchRequest.execute()
        }

        _playlists = results ?? []
        return _playlists!
    }

    // FIXME: do we use this or the one above?
    @Published private var _playlistsBySoundset: [ArraySlice<Playlist>]?
    var playlistsBySoundset: [ArraySlice<Playlist>] {
        if let playlistsBySoundset = _playlistsBySoundset { return playlistsBySoundset }

        _playlistsBySoundset = playlists.split(between: { $0.soundset != $1.soundset })
        return _playlistsBySoundset!
    }

    func clear() {
        search = ""
    }
}
