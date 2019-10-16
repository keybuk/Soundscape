//
//  PlaylistEntry+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension PlaylistEntryManagedObject {
    static func createFrom(_ clientEntry: SyrinscapeChapterClient.PlaylistEntry, element: ElementManagedObject, context managedObjectContext: NSManagedObjectContext) -> PlaylistEntryManagedObject? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let sampleUUID = clientEntry.sampleFile
            else { return nil }

        let fetchRequest: NSFetchRequest<PlaylistEntryManagedObject> = PlaylistEntryManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "element == %@ AND sample.uuid == %@", element, sampleUUID)

        var playlistEntry: PlaylistEntryManagedObject?
        do {
            let results = try fetchRequest.execute()
            playlistEntry = results.first
        } catch let error {
            print("Failed to fetch playlist entry: \(error.localizedDescription)")
            return nil
        }

        if playlistEntry == nil {
            let sampleFetchRequest: NSFetchRequest<SampleManagedObject> = SampleManagedObject.fetchRequest()
            sampleFetchRequest.predicate = NSPredicate(format: "uuid == %@", sampleUUID)

            let sample: SampleManagedObject?
            do {
                let sampleResults = try sampleFetchRequest.execute()
                sample = sampleResults.first
            } catch let error {
                print("Failed to fetch sample \(sampleUUID): \(error.localizedDescription)")
                return nil
            }

            if sample == nil {
                print("Missing sample: \(sampleUUID) for playlist entry")
                return nil
            }

            playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
            playlistEntry!.sample = sample
        }

        if let minVolume = clientEntry.minGain, let maxVolume = clientEntry.maxGain {
            if minVolume <= maxVolume {
                playlistEntry!.minVolume = minVolume
                playlistEntry!.maxVolume = maxVolume
            } else {
                // Invert
                playlistEntry!.minVolume = maxVolume
                playlistEntry!.maxVolume = minVolume
            }
        } else {
            playlistEntry!.minVolume = 1
            playlistEntry!.maxVolume = 1
        }

        return playlistEntry
    }
}
