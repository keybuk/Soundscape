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
        ( "Alfriston Town", Playlist.Kind.music, -5, ["MUS_80_Zuldazar_Dazaralor_Bazaar_01"]),
        ( "Alfriston Region", Playlist.Kind.music, -5, ["MUS_80_Zuldazar_Dazaralor_Bazaar_02"]),
        ( "Dungeon Delve", Playlist.Kind.musicLoop, 0, ["BGM_EX3_Dan_D03"]),
        ( "The Aron-Kai", Playlist.Kind.music, 0, ["BGM_EX3_Field_Rak_Day"]),
        ( "Alfriston Battle", Playlist.Kind.music, -5, [
            "MUS_80_StormsongValley_ShrineofStorms_01",
            "MUS_80_StormsongValley_ShrineofStorms_02",
            "MUS_80_StormsongValley_ShrineofStorms_03",
            "MUS_80_StormsongValley_ShrineofStorms_04"
        ])
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
                let soundsetFetchRequest: NSFetchRequest<SoundsetManagedObject> = SoundsetManagedObject.fetchRequest()
                soundsetFetchRequest.predicate = NSPredicate(format: "slug == %@", soundsetSlug)

                let soundset: SoundsetManagedObject
                do {
                    let results = try soundsetFetchRequest.execute()
                    soundset = results.first ?? SoundsetManagedObject(context: self.managedObjectContext)
                } catch let error {
                    print("Failed to fetch soundset \(soundsetSlug): \(error.localizedDescription)")
                    return
                }

                soundset.categoryRawValue = Soundset.Category.fantasy.rawValue
                soundset.slug = soundsetSlug
                soundset.title = soundsetTitle
                soundset.schemaVersion = SoundsetManagedObject.currentSchemaVersion

                var newElements: [ElementManagedObject] = []
                for (elementTitle, elementKind, sampleGap, sampleList) in soundsetData {
                    let elementSlug = "xx-\(elementTitle)"
                    let elementFetchRequest: NSFetchRequest<ElementManagedObject> = ElementManagedObject.fetchRequest()
                    elementFetchRequest.predicate = NSPredicate(format: "soundset == %@ AND slug == %@", soundset, elementSlug)

                    let element: ElementManagedObject
                    do {
                        let results = try elementFetchRequest.execute()
                        element = results.first ?? ElementManagedObject(context: self.managedObjectContext)
                    } catch let error {
                        print("Failed to fetch element for \(elementSlug): \(error.localizedDescription)")
                        return
                    }

                    element.kindRawValue = elementKind.rawValue
                    element.slug = elementSlug
                    element.title = elementTitle
                    element.orderRawValue = Playlist.Order.shuffled.rawValue
                    element.isRepeating = true
                    element.initialVolume = 1 / 3
                    element.minSampleGap = Double(sampleGap)
                    element.maxSampleGap = Double(sampleGap)

                    var newPlaylistEntries: [PlaylistEntryManagedObject] = []
                    for sampleTitle in sampleList {
                        let sampleUUID = "xx-\(sampleTitle)"
                        let sampleFetchRequest: NSFetchRequest<SampleManagedObject> = SampleManagedObject.fetchRequest()
                        sampleFetchRequest.predicate = NSPredicate(format: "uuid == %@", sampleUUID)

                        let sample: SampleManagedObject
                        do {
                            let results = try sampleFetchRequest.execute()
                            sample = results.first ?? SampleManagedObject(context: self.managedObjectContext)
                        } catch let error {
                            print("Failed to fetch sample for \(sampleUUID): \(error.localizedDescription)")
                            return
                        }

                        sample.uuid = sampleUUID
                        sample.title = sampleTitle
                        sample.url = URL(string: "https://netsplit.com/_hidden/\(sampleTitle).ogg")!


                        let playlistEntryFetchRequest: NSFetchRequest<PlaylistEntryManagedObject> = PlaylistEntryManagedObject.fetchRequest()
                        playlistEntryFetchRequest.predicate = NSPredicate(format: "element == %@ AND sample.uuid == %@", element, sampleUUID)

                        var playlistEntry: PlaylistEntryManagedObject?
                        do {
                            let results = try playlistEntryFetchRequest.execute()
                            playlistEntry = results.first
                        } catch let error {
                            print("Failed to fetch playlist entry: \(error.localizedDescription)")
                            return
                        }

                        if playlistEntry == nil {
                            playlistEntry = PlaylistEntryManagedObject(context: self.managedObjectContext)
                            playlistEntry!.sample = sample
                        }

                        newPlaylistEntries.append(playlistEntry!)
                    }

                    element.playlistEntries = NSOrderedSet(array: newPlaylistEntries)
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
                for clientChapter in chaptersClient.chapters {
                    SoundsetManagedObject.createFrom(clientChapter, category: category, context: self.managedObjectContext)
                }
            case .failure(let error):
                print("Failed to download \(category): \(error.localizedDescription)")
            }

            self.syncNextCategory(iterator: categoryIterator)
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
