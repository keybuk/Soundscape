//
//  Sample+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Sample {
    @discardableResult
    static func createFrom(_ client: SyrinscapeChapterClient.SoundSample, manifest: SyrinscapeManifestClient, context managedObjectContext: NSManagedObjectContext) -> Sample? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let uuid = client.uuid,
            let title = client.title,
            let fileExtension = client.fileExtension
            else { return nil }

        let filename = "\(uuid).\(fileExtension)"
        guard let sampleFile = manifest.soundsetFile(matching: filename),
            let sampleURL = sampleFile.url
            else {
                print("Missing URL for sample \(filename)")
                return nil
        }

        let fetchRequest: NSFetchRequest<Sample> = Sample.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)

        let sample: Sample
        do {
            let results = try fetchRequest.execute()
            sample = results.first ?? Sample(context: managedObjectContext)
        } catch let error {
            print("Failed to fetch sample for \(uuid): \(error.localizedDescription)")
            return nil
        }

        sample.uuid = uuid
        sample.title = title
        sample.url = sampleURL

        do {
            if sample.hasChanges {
                try managedObjectContext.save()
            }
        } catch let error {
            print("Failed to save changes to sample \(uuid): \(error.localizedDescription)")
        }

        return sample
    }
}
