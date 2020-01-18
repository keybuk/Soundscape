//
//  SyrinscapeSync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

final class SyrinscapeSync {
    let managedObjectContext: NSManagedObjectContext

    init(context managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func syncChapters() {
        let categoryIterator = Soundset.Category.allCases.makeIterator()
        syncNextCategory(iterator: categoryIterator)
    }

    func syncNextCategory(iterator categoryIterator: Soundset.Category.AllCases.Iterator) {
        var categoryIterator = categoryIterator
        guard let category = categoryIterator.next() else {
            syncSoundsets()
            return
        }

        let chaptersClient = SyrinscapeChaptersClient()
        chaptersClient.download(category: category) { result in
            switch result {
            case .success(_):
                var currentSlugs: [String] = []
                for clientChapter in chaptersClient.chapters {
                    guard let slug = clientChapter.slug else { continue }
                    SoundsetManagedObject.createFrom(clientChapter, category: category, context: self.managedObjectContext)
                    currentSlugs.append(slug)
                }

                self.cleanupCategory(category, keep: currentSlugs)
            case .failure(let error):
                print("Failed to download \(category): \(error.localizedDescription)")
            }

            self.syncNextCategory(iterator: categoryIterator)
        }
    }

    func cleanupCategory(_ category: Soundset.Category, keep currentSlugs: [String]) {
        let fetchRequest: NSFetchRequest<SoundsetManagedObject> = SoundsetManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryRawValue == %d AND NOT (slug IN %@)", category.rawValue, currentSlugs)

        managedObjectContext.perform {
            do {
                let results = try fetchRequest.execute()
                if !results.isEmpty {
                    for soundset in results {
                        print("Deleting \(soundset.slug!)")
                        self.managedObjectContext.delete(soundset)
                    }

                    try self.managedObjectContext.save()
                }
            } catch let error {
                print("Cleanup failed: \(error.localizedDescription)")
            }
        }
    }

    func syncSoundsets() {
        let fetchRequest: NSFetchRequest<SoundsetManagedObject> = SoundsetManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "downloadedDate == nil OR downloadedDate < updatedDate OR schemaVersion != %d", SoundsetManagedObject.currentSchemaVersion)

        managedObjectContext.perform {
            do {
                let results = try fetchRequest.execute()
                let soundsetIterator = results.makeIterator()
                self.syncNextSoundset(iterator: soundsetIterator)
            } catch let error {
                print("Out of date check failed: \(error.localizedDescription)")
            }
        }
    }

    func syncNextSoundset(iterator soundsetIterator: Array<SoundsetManagedObject>.Iterator) {
        var soundsetIterator = soundsetIterator
        guard let soundset = soundsetIterator.next() else {
            print("Sync complete")
            return
        }

        soundset.updateFromServer(context: managedObjectContext) {
            self.syncNextSoundset(iterator: soundsetIterator)
        }
    }
}
