//
//  Playlist+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Playlist {
    static func createFrom(_ client: SyrinscapeChapterClient.Element, kind: Playlist.Kind, soundset: Soundset, context managedObjectContext: NSManagedObjectContext) -> Playlist? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let slug = client.slug,
            let title = client.title
            else { return nil }

        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "soundset == %@ AND slug == %@", soundset, slug)

        let playlist: Playlist
        do {
            let results = try fetchRequest.execute()
            playlist = results.first ?? Playlist(context: managedObjectContext)
        } catch let error {
            print("Failed to fetch playlist for \(slug): \(error.localizedDescription)")
            return nil
        }

        playlist.kindRawValue = kind.rawValue
        playlist.slug = slug
        playlist.title = title

        playlist.initialVolume = client.initialGain ?? 1
        if let minStartDelay = client.minStartDelay, let maxStartDelay = client.maxStartDelay {
            if minStartDelay <= maxStartDelay {
                playlist.minStartDelay = minStartDelay
                playlist.maxStartDelay = maxStartDelay
            } else {
                // Invert
                playlist.minStartDelay = maxStartDelay
                playlist.maxStartDelay = minStartDelay
            }
        } else {
            playlist.minStartDelay = 0
            playlist.maxStartDelay = 0
        }
        if let minSampleGap = client.minTriggerWait, let maxSampleGap = client.maxTriggerWait {
            if minSampleGap <= maxSampleGap {
                playlist.minSampleGap = minSampleGap
                playlist.maxSampleGap = maxSampleGap
            } else {
                // Invert
                playlist.minSampleGap = maxSampleGap
                playlist.maxSampleGap = minSampleGap
            }
        } else {
            playlist.minSampleGap = 0
            playlist.maxSampleGap = 0
        }
        if let minAngle = client.minAngle, let maxAngle = client.maxAngle {
            if minAngle <= maxAngle {
                playlist.minAngle = minAngle
                playlist.maxAngle = maxAngle
            } else {
                // Invert
                playlist.minAngle = maxAngle
                playlist.maxAngle = minAngle
            }
        } else {
            playlist.minAngle = 0
            playlist.maxAngle = 0
        }
        if let minDistance = client.minDistance, let maxDistance = client.maxDistance {
            if minDistance <= maxDistance {
                playlist.minDistance = minDistance
                playlist.maxDistance = maxDistance
            } else {
                // Invert
                playlist.minDistance = maxDistance
                playlist.maxDistance = minDistance
            }
        } else {
            playlist.minDistance = 0
            playlist.maxDistance = 0
        }
        playlist.isRepeating = client.repeatPlaylist
        playlist.isOverlapping = client.allowPlaylistOverlap
        playlist.is3D = !client.bypassPosition

        switch client.randomisePlaylist {
        case "shuffle": playlist.orderRawValue = Playlist.Order.shuffled.rawValue
        case "inorder": playlist.orderRawValue = Playlist.Order.ordered.rawValue
        case "random": playlist.orderRawValue = Playlist.Order.random.rawValue
        default: playlist.orderRawValue = Playlist.Order.ordered.rawValue
        }

        let oldEntries = playlist.entries!
        let newEntries: [PlaylistEntry] = client.playlist.compactMap {
            PlaylistEntry.createFrom($0, element: playlist, context: managedObjectContext)
        }
        playlist.entries = NSOrderedSet(array: newEntries)

        for case let .remove(offset: _, element: removed as PlaylistEntry, associatedWith: _) in playlist.entries!.difference(from: oldEntries) {
            print("Removed sample \(removed.sample!.uuid!) from playlist \(playlist.title!)")
            managedObjectContext.delete(removed)
        }

        return playlist
    }
}
