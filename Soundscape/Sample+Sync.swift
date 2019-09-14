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
    static func createFrom(_ clientSample: SyrinscapeChapterClient.SoundSample, manifestClient: SyrinscapeManifestClient, context managedObjectContext: NSManagedObjectContext) -> Sample? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let uuid = clientSample.uuid,
            let title = clientSample.title,
            let fileExtension = clientSample.fileExtension
            else { return nil }

        let filename = "\(uuid).\(fileExtension)"
        guard let sampleFile = manifestClient.soundsetFile(matching: filename),
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
