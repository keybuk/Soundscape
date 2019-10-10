//
//  SyrinscapeSync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

let staticData = [
    "Arundor": [
        ( "Alfriston Town", "MUS_80_Zuldazar_Dazaralor_Bazaar_01", "https://netsplit.com/_hidden/MUS_80_Zuldazar_Dazaralor_Bazaar_01.ogg" ),
        ( "Alfriston Region", "MUS_80_Zuldazar_Dazaralor_Bazaar_02", "https://netsplit.com/_hidden/MUS_80_Zuldazar_Dazaralor_Bazaar_02.ogg" )
    ]
]

final class SyrinscapeSync {
    let managedObjectContext: NSManagedObjectContext

    init(context managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func syncStaticData() {
        managedObjectContext.perform {
            for (soundsetTitle, soundsetData) in staticData {
                let soundsetSlug = "xx-\(soundsetTitle)"
                let soundsetFetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()
                soundsetFetchRequest.predicate = NSPredicate(format: "slug == %@", soundsetSlug)

                let soundset: Soundset
                do {
                    let results = try soundsetFetchRequest.execute()
                    soundset = results.first ?? Soundset(context: self.managedObjectContext)
                } catch let error {
                    print("Failed to fetch soundset \(soundsetSlug): \(error.localizedDescription)")
                    return
                }

                soundset.category = .fantasy
                soundset.slug = soundsetSlug
                soundset.title = soundsetTitle

                var newElements: [Element] = []
                for (elementTitle, sampleTitle, sampleURL) in soundsetData {
                    let elementSlug = "xx-\(elementTitle)"
                    let elementFetchRequest: NSFetchRequest<Element> = Element.fetchRequest()
                    elementFetchRequest.predicate = NSPredicate(format: "soundset == %@ AND slug == %@", soundset, elementSlug)

                    let element: Element
                    do {
                        let results = try elementFetchRequest.execute()
                        element = results.first ?? Element(context: self.managedObjectContext)
                    } catch let error {
                        print("Failed to fetch element for \(elementSlug): \(error.localizedDescription)")
                        return
                    }

                    element.kind = .music
                    element.slug = elementSlug
                    element.title = elementTitle
                    element.isRepeating = true

                    let sampleUUID = "xx-\(sampleTitle)"
                    let sampleFetchRequest: NSFetchRequest<Sample> = Sample.fetchRequest()
                    sampleFetchRequest.predicate = NSPredicate(format: "uuid == %@", sampleUUID)

                    let sample: Sample
                    do {
                        let results = try sampleFetchRequest.execute()
                        sample = results.first ?? Sample(context: self.managedObjectContext)
                    } catch let error {
                        print("Failed to fetch sample for \(sampleUUID): \(error.localizedDescription)")
                        return
                    }

                    sample.uuid = sampleUUID
                    sample.title = sampleTitle
                    sample.url = URL(string: sampleURL)!

                    for case let playlistEntry as NSManagedObject in element.playlistEntries! {
                        self.managedObjectContext.delete(playlistEntry)
                    }


                    let playlistEntry = PlaylistEntry(context: self.managedObjectContext)
                    playlistEntry.sample = sample

                    element.playlistEntries = NSOrderedSet(array: [playlistEntry])
                    newElements.append(element)
                }

                soundset.elements = NSOrderedSet(array: newElements)
            }

            do {
                try self.managedObjectContext.save()
            } catch let error {
                print("Failed to save changes to static data: \(error.localizedDescription)")
                return
            }
        }
    }

    func syncChapters() {
        let categoryIterator = SoundsetCategory.allCases.makeIterator()
        syncNextCategory(iterator: categoryIterator)
    }

    func syncNextCategory(iterator categoryIterator: SoundsetCategory.AllCases.Iterator) {
        var categoryIterator = categoryIterator
        guard let category = categoryIterator.next() else {
            syncSoundsets()
            return
        }

        let chaptersClient = SyrinscapeChaptersClient()
        chaptersClient.download(category: category) { result in
            switch result {
            case .success(_):
                for clientChapter in chaptersClient.chapters {
                    Soundset.createFrom(clientChapter, category: category, context: self.managedObjectContext)
                }
            case .failure(let error):
                print("Failed to download \(category): \(error.localizedDescription)")
            }

            self.syncNextCategory(iterator: categoryIterator)
        }
    }

    func syncSoundsets() {
        let fetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "downloadedDate == nil OR downloadedDate < updatedDate")

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

    func syncNextSoundset(iterator soundsetIterator: Array<Soundset>.Iterator) {
        var soundsetIterator = soundsetIterator
        guard let soundset = soundsetIterator.next() else { return }

        soundset.updateFromServer(context: managedObjectContext) {
            self.syncNextSoundset(iterator: soundsetIterator)
        }
    }
}
