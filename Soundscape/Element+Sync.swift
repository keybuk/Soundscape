//
//  Element+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension ElementManagedObject {
    static func createFrom(_ clientElement: SyrinscapeChapterClient.Element, kind: Element.Kind, soundset: SoundsetManagedObject, context managedObjectContext: NSManagedObjectContext) -> ElementManagedObject? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let slug = clientElement.slug,
            let title = clientElement.title
            else { return nil }

        let fetchRequest: NSFetchRequest<ElementManagedObject> = ElementManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "soundset == %@ AND slug == %@", soundset, slug)

        let element: ElementManagedObject
        do {
            let results = try fetchRequest.execute()
            element = results.first ?? ElementManagedObject(context: managedObjectContext)
        } catch let error {
            print("Failed to fetch element for \(slug): \(error.localizedDescription)")
            return nil
        }

        element.kindRawValue = kind.rawValue
        element.slug = slug
        element.title = title

        element.initialVolume = clientElement.initialGain ?? 1
        if let minStartDelay = clientElement.minStartDelay, let maxStartDelay = clientElement.maxStartDelay {
            if minStartDelay <= maxStartDelay {
                element.minStartDelay = minStartDelay
                element.maxStartDelay = maxStartDelay
            } else {
                // Invert
                element.minStartDelay = maxStartDelay
                element.maxStartDelay = minStartDelay
            }
        } else {
            element.minStartDelay = 0
            element.maxStartDelay = 0
        }
        if let minSampleGap = clientElement.minTriggerWait, let maxSampleGap = clientElement.maxTriggerWait {
            if minSampleGap <= maxSampleGap {
                element.minSampleGap = minSampleGap
                element.maxSampleGap = maxSampleGap
            } else {
                // Invert
                element.minSampleGap = maxSampleGap
                element.maxSampleGap = minSampleGap
            }
        } else {
            element.minSampleGap = 0
            element.maxSampleGap = 0
        }
        element.isRepeating = clientElement.repeatPlaylist
        element.isOverlapping = clientElement.allowPlaylistOverlap

        switch clientElement.randomisePlaylist {
        case "shuffle": element.orderRawValue = Element.Order.shuffled.rawValue
        case "inorder": element.orderRawValue = Element.Order.ordered.rawValue
        case "random": element.orderRawValue = Element.Order.random.rawValue
        default: element.orderRawValue = Element.Order.ordered.rawValue
        }

        let newEntries: [PlaylistEntryManagedObject] = clientElement.playlist.compactMap {
            PlaylistEntryManagedObject.createFrom($0, element: element, context: managedObjectContext)
        }
        element.playlistEntries = NSOrderedSet(array: newEntries)

        return element
    }
}
