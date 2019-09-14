//
//  Element+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Element {
    @discardableResult
    static func createFrom(_ clientElement: SyrinscapeChapterClient.Element, kind: ElementKind, soundset: Soundset, context managedObjectContext: NSManagedObjectContext) -> Element? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let slug = clientElement.slug,
            let title = clientElement.title
            else { return nil }

        let fetchRequest: NSFetchRequest<Element> = Element.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "soundset == %@ AND slug == %@", soundset, slug)

        let element: Element
        do {
            let results = try fetchRequest.execute()
            element = results.first ?? Element(context: managedObjectContext)
        } catch let error {
            print("Failed to fetch element for \(slug): \(error.localizedDescription)")
            return nil
        }

        element.kind = kind
        element.slug = slug
        element.title = title

        element.initialVolume = clientElement.initialGain ?? 1
        element.minStartDelay = clientElement.minStartDelay ?? 0
        element.maxStartDelay = clientElement.maxStartDelay ?? 0
        element.minSampleGap = clientElement.minTriggerWait ?? 0
        element.maxSampleGap = clientElement.maxTriggerWait ?? 0
        element.isRepeating = clientElement.repeatPlaylist
        element.isOverlapping = clientElement.allowPlaylistOverlap

        switch clientElement.randomisePlaylist {
        case "shuffle": element.order = .shuffled
        case "inorder": element.order = .ordered
        case "random": element.order = .random
        default: element.order = .ordered
        }

        let newEntries: [PlaylistEntry] = clientElement.playlist.compactMap {
            PlaylistEntry.createFrom($0, element: element, context: managedObjectContext)
        }
        element.playlistEntries = NSOrderedSet(array: newEntries)

        return element
    }
}
