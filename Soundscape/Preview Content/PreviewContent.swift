//
//  PreviewContent.swift
//  Soundscape
//
//  Created by Scott James Remnant on 8/31/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

#if DEBUG
import Foundation
import CoreData
import UIKit

struct PreviewContent {

    let persistentContainer: NSPersistentContainer
    var managedObjectContext: NSManagedObjectContext { persistentContainer.viewContext }

    var soundsetObjects: [SoundsetManagedObject]
    var soundsets: [Soundset]

    init() {
        persistentContainer = NSPersistentContainer(name: "Soundscape")
        persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error { fatalError("\(error.localizedDescription)") }
        }

        soundsetObjects = []
        soundsets = []

        var soundset = SoundsetManagedObject(context: managedObjectContext)
        soundset.categoryRawValue = Soundset.Category.fantasy.rawValue
        soundset.slug = "battle-for-lake-town"
        soundset.title = "Battle for Lake Town"
        soundset.url = URL(string: "https://netsplit.com/nosuchfile")
        soundset.updatedDate = Date()
        soundset.downloadedDate = soundset.updatedDate
        soundset.imageData = UIImage(named: "LakeTown")?.jpegData(compressionQuality: 1.0)
        soundsetObjects.append(soundset)

        var mood = MoodManagedObject(context: managedObjectContext)
        mood.title = "Drinking Time"
        soundset.addToMoods(mood)

        mood = MoodManagedObject(context: managedObjectContext)
        mood.title = "Fighting Time"
        soundset.addToMoods(mood)

        // Tavern Music
        var element = ElementManagedObject(context: managedObjectContext)
        element.kindRawValue = Element.Kind.music.rawValue
        element.slug = "tavern-music"
        element.title = "Tavern Music"
        element.minStartDelay = 3
        element.maxStartDelay = 6
        element.minSampleGap = 3
        element.maxSampleGap = 6
        element.orderRawValue = Element.Order.shuffled.rawValue
        soundset.addToElements(element)

        var elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = true
        elementParameter.volume = 0.4
        (soundset.moods!.array[0] as! MoodManagedObject).addToElementParameters(elementParameter)

        elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = false
        (soundset.moods!.array[1] as! MoodManagedObject).addToElementParameters(elementParameter)

        var sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "bf94ecc2-c07a-11e2-926a-f23c9170c08b"
        sample.title = "Druche"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/wagon-journey-highlands/download/files/9571140a37ac11e6852ff23c9170c08b/a/bf94ecc2-c07a-11e2-926a-f23c9170c08b.syrin")

        var playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "00404c4e-c07b-11e2-926a-f23c9170c08b"
        sample.title = "Harp song"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/brindol-town/download/files/62016cace58e11e59ce7f23c9170c08b/a/00404c4e-c07b-11e2-926a-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "4120a9d4-c07b-11e2-926a-f23c9170c08b"
        sample.title = "Lute song"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/wagon-journey-highlands/download/files/9571140a37ac11e6852ff23c9170c08b/a/4120a9d4-c07b-11e2-926a-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "c1beef42-c07b-11e2-926a-f23c9170c08b"
        sample.title = "Whistle and lute"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/brindol-town/download/files/62016cace58e11e59ce7f23c9170c08b/a/c1beef42-c07b-11e2-926a-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "69c23096-c07c-11e2-926a-f23c9170c08b"
        sample.title = "Typhenae dir"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/D6suS%3A7bd6e14d7994cfff1fb605cdb0d0987906359b73/dd%252Fsoundsample%252Ffile%252F3977915e590e759f000c6bd7e3ac7f61.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)


        // Tavern Brawl Music
        element = ElementManagedObject(context: managedObjectContext)
        element.kindRawValue = Element.Kind.music.rawValue
        element.slug = "tavern-brawl-music"
        element.title = "Tavern Brawl Music"
        element.minStartDelay = 1
        element.maxStartDelay = 1
        element.minSampleGap = 5
        element.maxSampleGap = 10
        element.orderRawValue = Element.Order.shuffled.rawValue
        soundset.addToElements(element)

        elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = false
        (soundset.moods!.array[0] as! MoodManagedObject).addToElementParameters(elementParameter)

        elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = true
        elementParameter.volume = 0.6
        (soundset.moods!.array[1] as! MoodManagedObject).addToElementParameters(elementParameter)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "5c41b8ae-9c0e-415c-9c74-e2e65f42ccf3"
        sample.title = "Tavernbrawlmusic - Dusty Windowsills"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-corbin-village-imported-2016-11-07-071209/download/files/a8262086a61011e69e36f23c9170c08b/a/5c41b8ae-9c0e-415c-9c74-e2e65f42ccf3.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "a31d2007-cafe-4428-bf8b-899d10c272d5"
        sample.title = "Tavernbrawlmusic - Four and a half sided gig"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-corbin-village-imported-2016-11-07-071209/download/files/a8262086a61011e69e36f23c9170c08b/a/a31d2007-cafe-4428-bf8b-899d10c272d5.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "76f6e710-cd69-410a-81d3-0d245ed89adb"
        sample.title = "Tavernbrawlmusic - Phry jig"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-corbin-village-imported-2016-11-07-071209/download/files/a8262086a61011e69e36f23c9170c08b/a/76f6e710-cd69-410a-81d3-0d245ed89adb.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "930f944b-80b1-4baa-85d1-8fce7c354384"
        sample.title = "Tavernbrawlmusic - The gold ring"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-corbin-village-imported-2016-11-07-071209/download/files/a8262086a61011e69e36f23c9170c08b/a/930f944b-80b1-4baa-85d1-8fce7c354384.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "014a24e6-5046-4015-b3ef-696c6a26b0fc"
        sample.title = "Tavernbrawlmusic - Lift him up and throw him down"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-corbin-village-imported-2016-11-07-071209/download/files/a8262086a61011e69e36f23c9170c08b/a/014a24e6-5046-4015-b3ef-696c6a26b0fc.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        // Barghest Roar
        element = ElementManagedObject(context: managedObjectContext)
        element.kindRawValue = Element.Kind.effect.rawValue
        element.slug = "barghest-roar"
        element.title = "Barghest Roar"
        element.minStartDelay = 3
        element.maxStartDelay = 3
        element.minSampleGap = 3
        element.maxSampleGap = 6
        element.orderRawValue = Element.Order.shuffled.rawValue
        soundset.addToElements(element)

        elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = false
        (soundset.moods!.array[0] as! MoodManagedObject).addToElementParameters(elementParameter)

        elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = true
        elementParameter.volume = 0.8
        (soundset.moods!.array[1] as! MoodManagedObject).addToElementParameters(elementParameter)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "ff0a9876-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 8 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/ff0a9876-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "fbcf2ed8-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 7 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/fbcf2ed8-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "fa9d9d10-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 6 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/fa9d9d10-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "f8a2e7e0-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 5 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/f8a2e7e0-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "f59fb2f8-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 4 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/f59fb2f8-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "f12ca91a-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 2 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/f12ca91a-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "f2881092-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 3 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/f2881092-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "ee33ea34-8d5b-11e3-bdff-f23c9170c08b"
        sample.title = "Big Monster Howl 1 - Growl"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tsd-part-2-imported-2016-06-29-121925/download/files/054acf66997b11e6b8e0f23c9170c08b/a/ee33ea34-8d5b-11e3-bdff-f23c9170c08b.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        // Weapon Impacts
        element = ElementManagedObject(context: managedObjectContext)
        element.kindRawValue = Element.Kind.effect.rawValue
        element.slug = "weapon-impacts"
        element.title = "Weapon Impacts"
        element.minStartDelay = 2.5
        element.maxStartDelay = 2.5
        element.minSampleGap = -1
        element.maxSampleGap = 2
        element.initialVolume = 0.5
        element.orderRawValue = Element.Order.shuffled.rawValue
        soundset.addToElements(element)

        elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = false
        (soundset.moods!.array[0] as! MoodManagedObject).addToElementParameters(elementParameter)

        elementParameter = ElementParameterManagedObject(context: managedObjectContext)
        elementParameter.element = element
        elementParameter.isPlaying = true
        elementParameter.volume = 1.0
        (soundset.moods!.array[1] as! MoodManagedObject).addToElementParameters(elementParameter)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "5c7bc590-891a-4f7e-9501-0bc5c375c01c"
        sample.title = "Heavy Sword Blow On Chainmail 3"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/5c7bc590-891a-4f7e-9501-0bc5c375c01c.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "877364d8-b523-4c12-aa3e-750813290322"
        sample.title = "Heavy Sword Blow On Chainmail 2"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/877364d8-b523-4c12-aa3e-750813290322.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "5061b2eb-6e11-4786-832b-e4d6f4305777"
        sample.title = "Heavy Sword Blow On Chainmail 1"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/5061b2eb-6e11-4786-832b-e4d6f4305777.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "bcf43c2f-68f6-488f-b541-95ff959fbd95"
        sample.title = "Axe Blow On Chainmail 4"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/bcf43c2f-68f6-488f-b541-95ff959fbd95.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "9548045b-6f41-46e3-be4a-e070bc1d9a06"
        sample.title = "Axe Blow On Chainmail 3"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/9548045b-6f41-46e3-be4a-e070bc1d9a06.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "31cef1ef-1efa-40eb-8b5c-96b8b3e76305"
        sample.title = "Axe Blow On Chainmail 2"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/31cef1ef-1efa-40eb-8b5c-96b8b3e76305.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "824a7218-be90-47e2-ab14-2f204af3fd5d"
        sample.title = "Axe Blow On Chainmail 1"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/824a7218-be90-47e2-ab14-2f204af3fd5d.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "ca5f489f-33cb-481c-8438-33bd870f3336"
        sample.title = "Sword Swoosh"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/ca5f489f-33cb-481c-8438-33bd870f3336.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "19d47a45-0e02-4976-8d33-d972cbdb7b93"
        sample.title = "Sword Clang"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/19d47a45-0e02-4976-8d33-d972cbdb7b93.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "85f21afb-234f-4b3d-83de-b52d9158cf92"
        sample.title = "Sword Clang 2"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/85f21afb-234f-4b3d-83de-b52d9158cf92.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "c4cb6d45-3025-40f0-b4f3-a6e380b87de1"
        sample.title = "Shield Block"
        sample.url = URL(string: "https://www.syrinscape.com/account/chapters/tota1-in-the-cave-imported-2016-11-07-124319/download/files/ab37518ca61011e69e36f23c9170c08b/a/c4cb6d45-3025-40f0-b4f3-a6e380b87de1.syrin")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        // Waterdhavians
        element = ElementManagedObject(context: managedObjectContext)
        element.kindRawValue = Element.Kind.oneshot.rawValue
        element.slug = "waterdhavians"
        element.title = "Waterdhavians"
        element.orderRawValue = Element.Order.random.rawValue
        element.isRepeating = false
        soundset.addToElements(element)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "86801293-9114-434d-8de0-f96a3c0c1130"
        sample.title = "Water deep voices - Brandon Hunt_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Rr8Tv%3A7de51f92f4053f06366f1673534252f7a029ab3f/dd%252Fsoundsample%252Ffile%252F580b42d1cba301e9c360e88fc6848109.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "343d39cb-63c7-4f21-959a-ecab089e7e59"
        sample.title = "Water deep voices - Brandon Hunt_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/CQyp1%3Ad4bc2595c330ae1d5be83b788fed57836e362bfc/dd%252Fsoundsample%252Ffile%252F9cfb048a781b5ffcc5c084b256b56f0c.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "2833f215-0a97-43cd-9284-1285346e6d99"
        sample.title = "Water deep voices - Brandon Hunt_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/oVcxe%3Ad29e9bfb40cf7ff1ce1a47e761f654805b3968f5/dd%252Fsoundsample%252Ffile%252Fcf4bf4a37fe0bdf59a0227179529ff51.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "ab91003e-5bcb-4738-ab78-99d391cc9862"
        sample.title = "Water deep voices - Brandon Hunt_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/CGgey%3Adfded03dbd36efa24e2c383bc8b594ee4d27734c/dd%252Fsoundsample%252Ffile%252F0f4b31bbd4aabbe51d72370b2ec562fc.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "6c2862f7-9533-48eb-895d-d3efe019f9a9"
        sample.title = "Water deep voices - Brandon Hunt_05"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/B0VIp%3Ab05bce596a638bcc10b81e935b60f79ec9dfeec0/dd%252Fsoundsample%252Ffile%252F760f0af4e6da4affdcc00a1a3bd4f7e6.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "edfa2769-dce5-4445-9670-585194377103"
        sample.title = "Water deep voices - Brandon Hunt_06"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/1AslB%3A0c012d8746b54eb192c1cd486d0d3e42dc2d29f4/dd%252Fsoundsample%252Ffile%252Fddecaf5211406f4e3c000cae50d1d0f6.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "174776c9-a2c0-4186-96e5-4a7a954bb980"
        sample.title = "Water deep voices - Brandon Hunt_07"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/PNQCI%3A61c0401e7f944da65d51effb9e349f00238d8d1d/dd%252Fsoundsample%252Ffile%252F74b6e41f7a039b1b778c3c1d9a1b5dbf.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "0fac698a-86ed-4e7c-a9c4-9aa44570d224"
        sample.title = "Water deep voices - Brandon Hunt_08"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/ujedd%3Acc9fb0da46bd02e2d963de7840817a4f14a01f06/dd%252Fsoundsample%252Ffile%252F8c7682502f695d233740c1804128d8c8.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "810fdb8d-2c8a-4460-a651-238650fc8f67"
        sample.title = "Water deep voices - Brandon Hunt_09"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/h3Tqp%3A2cad5dfb4f816663b42c7377faf7d72fdb630c59/dd%252Fsoundsample%252Ffile%252F680f4953458004d663f5a49a624a0281.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "04e9c7e1-d9b2-4363-94d7-eb7727eb2e1a"
        sample.title = "Water deep voices - Brandon Hunt_10"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/N0PDc%3Adad523802c4417004476f92016b1393684b4249f/dd%252Fsoundsample%252Ffile%252Fdad8e2ddd3fdbb15347ee657a20f0428.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "defcb4fa-5a2a-4e47-be58-85de5bf9d07f"
        sample.title = "Water deep voices - Brandon Hunt_11"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/01iRK%3Ada4a4f4c9a9a439cfd503efc3fee172d60b309e8/dd%252Fsoundsample%252Ffile%252F3ffc7eb3ff4c67f58745bda009e0edcb.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "3bfa1b39-dcbe-4509-8001-8812ab81cf32"
        sample.title = "Water deep voices - Brandon Hunt_12"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/HbuPX%3A2d473636ca556886ca0c00503993408571973a5a/dd%252Fsoundsample%252Ffile%252Fdd160884806071bf48643993e7557951.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "f29f9b67-a115-478a-94ba-629e903032f4"
        sample.title = "Water deep voices - Brandon Hunt_13"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/N0QOA%3Ad60f0890f246f0f3bfc7cd4984829589641a2979/dd%252Fsoundsample%252Ffile%252Fc52a8a5b17eb23dba1bfc18953adb0ac.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "208f8e5d-241b-4a15-8bae-1d70da3555a6"
        sample.title = "Water deep voices - Brandon Hunt_14"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/wnR6Q%3A2d3b4decaeb73beb004c7910946afbb9e6bdff60/dd%252Fsoundsample%252Ffile%252F96809fe08918a3381afa1443c92add04.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "4c8505f8-b7a4-49c7-8fae-ca38a5b8331b"
        sample.title = "Water deep voices - James Nettum_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/mcDkU%3Aa0695df7cdc8f30d0d1cfd674513819ce886403a/dd%252Fsoundsample%252Ffile%252F8621d9a3f48205c2598f77b50dd28b40.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "b6d928a6-4e4c-4de8-ab73-0c5f67b623d8"
        sample.title = "Water deep voices - James Nettum_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/gQJJs%3A4ab53ab48213285d80e8180f532ec10744ebc0c7/dd%252Fsoundsample%252Ffile%252F8348ababd12d1b9ed5e997f13fad6ab8.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "0b88cc65-e74e-4206-9daa-c06caa2adfb6"
        sample.title = "Water deep voices - James Nettum_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/rXMFY%3Ad7968aa04ce5ad323cb7463420d3d4f298b6e31b/dd%252Fsoundsample%252Ffile%252Ff27c4aefd714dcf666df5ebc684b9e16.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "4cc3c4e0-d00a-4cf1-b468-aaf195f8775c"
        sample.title = "Water deep voices - Layla Edi_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/YyGEs%3Ae37e302904fbf351533235dc03f58d2ce3ec0d0e/dd%252Fsoundsample%252Ffile%252F3ce2731708e6f1a5b304d7804546f42e.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "0c2175fc-60f3-4bea-98b3-d66c178bed42"
        sample.title = "Water deep voices - Layla Edi_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/MO9LM%3A443514d714e9b0771140c311b93a5187b5f9ebb1/dd%252Fsoundsample%252Ffile%252F434a82d83472b6a58ca79e4547b89ad7.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "1aec447f-34b7-4ad1-8da2-780f29c70348"
        sample.title = "Water deep voices - Layla Edi_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/aXyP9%3A4ad762841858026ea0d9819ef8f80898f1eb098b/dd%252Fsoundsample%252Ffile%252Fff745464aef71f09e226283e3a457a96.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "5f154c43-6811-47b8-aa77-124483c77ece"
        sample.title = "Water deep voices - Ryan Lynch_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/s109L%3A208503b42f953528a45ba377b300f2e4dc054ae3/dd%252Fsoundsample%252Ffile%252Fa9635757b2f53517393a60f0af520370.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "b5fe7c14-b22f-4ed6-b634-26bd592493d2"
        sample.title = "Water deep voices - Ryan Lynch_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/LopTR%3Ac22088ac5ff3f79be44e64d457ff35301fb982d2/dd%252Fsoundsample%252Ffile%252Fc67003bd0bed77dc8b6f00cdb432d09a.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "044120f5-9d81-404e-a3d2-645231d6eb0f"
        sample.title = "Water deep voices - Ryan Lynch_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/583re%3A47be8839866835e8cea867dde85d9d47bae05c70/dd%252Fsoundsample%252Ffile%252Fd6a2f8ed03a0cf32b9e51f53f0505d0f.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "a99ea2f2-ff79-41fb-9f78-e2df66a55a57"
        sample.title = "Water deep voices - Ryan Lynch_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/MQTZQ%3Ac4b71396cf3de54259978b078772c1db43cc8302/dd%252Fsoundsample%252Ffile%252Ffc8fc582d11e0980b2183ba08c885421.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "fef4882b-7d53-4a97-85c3-8e92a47840d3"
        sample.title = "Waterdeep voices - Allen G Martinez_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/PHrzX%3A6c5be6ac76f8b673ccb824ce5c0afdbadb3df1fa/dd%252Fsoundsample%252Ffile%252Fa9feaf16f7015153d0a42d792a720aed.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "63496e6e-9460-4a96-8e86-a9fe32351e7a"
        sample.title = "Waterdeep voices - Del Yakes_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/qDJSc%3A01baebd9d8e0925088401134d5403d0deb7e2c33/dd%252Fsoundsample%252Ffile%252F801b63acc39712eb700a71b0b5111e25.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "9310f0ba-8529-435f-84c7-8d5f8aa8d3d8"
        sample.title = "Waterdeep voices - Del Yakes_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/olBUT%3A483938e4734e8534b6607c594b939a8064ccec45/dd%252Fsoundsample%252Ffile%252Ff3f7ae17c420851b48a85f726d864131.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e5bcc773-a3a8-453d-82a1-29a4e10dd5ef"
        sample.title = "Waterdeep voices - Del Yakes_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/WPKPL%3A15add01bdf5bc8b226ec04e4b2473a74f488bafd/dd%252Fsoundsample%252Ffile%252F189293800c512767b35fd606c811efc4.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e808d788-a681-4e2d-869e-aa579b1084b6"
        sample.title = "Waterdeep voices - Del Yakes_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/3Dxce%3A05ea53780d6bde31c03ba8dd3dfdf73dd7430e68/dd%252Fsoundsample%252Ffile%252Fc6a570154516989ccc23b3a819f28740.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "6b662002-6042-4c15-a4b0-f76a65342261"
        sample.title = "Waterdeep voices - Emily Pressler_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/AOc2E%3Ac5fc6e0ff589bc43cf3d492fe8e1e54e093806b0/dd%252Fsoundsample%252Ffile%252Fb2775a7dd1135dcc193be48947248b04.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "b51d1902-db0f-4dfa-9eb2-83a64682baf0"
        sample.title = "Waterdeep voices - Fred Blaydes_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/hf7Tw%3A8115a6b5dd3434e5eefc9e070988692639a943ec/dd%252Fsoundsample%252Ffile%252F9cfbed91103dac26e51f257eec895ecf.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "07b6fa0e-6770-4f67-91e2-66cf7f219675"
        sample.title = "Waterdeep voices - Fred Blaydes_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/oavKP%3A8c141ba9b51158210e89d644383a04aab697a952/dd%252Fsoundsample%252Ffile%252Fcf7b2ddd0cfda761d4b2640f63414215.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "3feeb3bd-7788-425d-b150-47c0d9b39acc"
        sample.title = "Waterdeep voices - Fred Blaydes_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/I6jrR%3A13caaf4a734a40986b3090cfd86031133f1a0d6f/dd%252Fsoundsample%252Ffile%252Fccd0b58be035ddd6d7b8d807458235fb.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "bb505af9-94ef-4058-948d-387a4080e6d3"
        sample.title = "Waterdeep voices - Fred Blaydes_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/vfZHs%3A36f74c7c842ddb4717521024853b5f268e581b29/dd%252Fsoundsample%252Ffile%252Fec91ec4a7b36159cf83f64d297abedfa.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "7ac50d40-db12-4f41-b7fa-2e7fc1960219"
        sample.title = "Waterdeep voices - Howard Stockwell_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/M79Ef%3A76cb8c55fee5d8248000630cd969d4b81c918bbc/dd%252Fsoundsample%252Ffile%252F9cfef2b5adbcd5d32c48a46cbb9e86d6.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "cf7b8ecc-b431-4ea3-809d-a677ba5c2abd"
        sample.title = "Waterdeep voices - Howard Stockwell_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/fkwAZ%3A8c04dc0e0617fc441fd2adedbe950beeffa3e39d/dd%252Fsoundsample%252Ffile%252Fefa7c950a7f223e35fdb77d4f7c4a6de.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "24ce5384-3c8e-4d88-8fe8-698595e30acc"
        sample.title = "Waterdeep voices - Howard Stockwell_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/eNSPw%3Ad6e8ba51cea09395f1486aff504ea5fb6de29e3d/dd%252Fsoundsample%252Ffile%252Fe6b3d3ddd28747fd18d394602fefcc62.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "9fcfa2a0-9549-4553-b342-8ad417a08e1d"
        sample.title = "Waterdeep voices - Howard Stockwell_05"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Crw8e%3Ae0e604ed6ea453de8eb499cf5847e05764026686/dd%252Fsoundsample%252Ffile%252F13bfa2802063a6085f5454b016f98881.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "cf766171-04b9-4036-9729-762c1047d05d"
        sample.title = "Waterdeep voices - Howard Stockwell_06"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/85h3P%3Aeffdf000c84cd36ea116bda455ad98efe77e73e5/dd%252Fsoundsample%252Ffile%252Fead679f865640f222791415006f1ad52.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "dcc6c480-ec93-4f02-9be7-5c3a67ee11f8"
        sample.title = "Waterdeep voices - Howard Stockwell_07"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/eQoKw%3Aece4779e2a15d6d454cc765686955307e69f302b/dd%252Fsoundsample%252Ffile%252Fb330efd00e940f6c5dc778834bc709eb.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "421c329e-ab0e-47b2-9f2e-07fac65b3347"
        sample.title = "Waterdeep voices - Howard Stockwell_08"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/HZtIB%3A7c89011193cdf01e2716d87384c608679248719f/dd%252Fsoundsample%252Ffile%252F625c33c5701c557565db08de1f748499.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "dd22138f-35f5-49c0-8634-cb2df193a534"
        sample.title = "Waterdeep voices - Howard Stockwell_09"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/6iAiK%3Af19eaf3bd2847383eb3f61ce33e83b6f4248a95a/dd%252Fsoundsample%252Ffile%252Fb37fe098f47f21357b1f1483356c6f0c.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "1b58a734-52a3-49aa-8ce1-00eba6bd2659"
        sample.title = "Waterdeep voices - Howard Stockwell_10"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/mxHhQ%3A952dc42f5a690b3eb8ea1ef9cdf50d93fcb92fc1/dd%252Fsoundsample%252Ffile%252Fe5f3db081b380de17c948d3f822eef1a.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "c2f45308-ee62-4400-97d7-677584277ae9"
        sample.title = "Waterdeep voices - J.R Green_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Kdnee%3A38de963c7a476d451d3acee566cb9ece9a55d3fc/dd%252Fsoundsample%252Ffile%252Fe4b3d64c91fb3a595bbb5e47f34a35c1.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e01a9f06-f9b6-4124-bfae-2efe445a8524"
        sample.title = "Waterdeep voices - J.R Green_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/AZJN4%3A661441fc45a6b4b1d05f8c6387aae4b7d8a6847c/dd%252Fsoundsample%252Ffile%252Fed8ca80eb190f10501a9bb167a39ae24.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e4a1cd60-80d2-435f-bee9-9f231f6d4049"
        sample.title = "Waterdeep voices - J.R Green_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/GsQ5z%3Aa6683f2b0a8ee3566fd8bcd4c188e630648f918d/dd%252Fsoundsample%252Ffile%252F14492cb0bcd258b46aed0a12ffcdcf44.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e200adba-137d-4f5b-9098-83e800ed8662"
        sample.title = "Waterdeep voices - J.R Green_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/MwjuN%3A5ff3521aa93f003d8bcd5a6fdc8b83d62ced855c/dd%252Fsoundsample%252Ffile%252F8124ac6549ed85acc822812646f749d2.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "b09ff2cf-7656-4e71-8f27-40e01af22dd3"
        sample.title = "Waterdeep voices - Janice Wedge_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/8Gb59%3Aac3d450e452768723380a82e455217d1d255c764/dd%252Fsoundsample%252Ffile%252F6cfb9dd77cb76bc2051551685ed94caa.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "a7fb391a-e16c-40a3-88c7-db2c858b8695"
        sample.title = "Waterdeep voices - Janice Wedge_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/NAKOD%3A856fb3285595b43027deed8c5805469e6754905d/dd%252Fsoundsample%252Ffile%252F6d7d48afb3b39d92d37b5ddd60892601.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "be906339-cb81-49a3-90d6-3687f8dbd6ca"
        sample.title = "Waterdeep voices - Jason Mackenzie_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/PVhWY%3Ad9d4bea847ac114186a147d0e223f5abcc9b2ac3/dd%252Fsoundsample%252Ffile%252Fb7017808a1b8c33e2e859eb1f4debd5c.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "61b5351e-e702-45d5-b04d-f6d925ff8888"
        sample.title = "Waterdeep voices - Jason Mackenzie_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/WT4WX%3A8cd70c1c20ba24d036362cda762ea9f05a47cc26/dd%252Fsoundsample%252Ffile%252Fb5dc6e883190f8d0f076a545c4847e53.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "4c403a01-72fa-436c-9de6-0a81c821312d"
        sample.title = "Waterdeep voices - Jason Mackenzie_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/NDrjO%3Ad93c687ef9cf02a940e382f7c85e350af7ee32bf/dd%252Fsoundsample%252Ffile%252Fbe92d68c394055e98e23baa906a96a9b.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "63dc5da7-97fe-4f20-a07d-5b7812991b91"
        sample.title = "Waterdeep voices - Jason Mackenzie_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/rRGMi%3A9777114cba76216a31a5566086497b102b08cd37/dd%252Fsoundsample%252Ffile%252F4bfe9ce9878c8386e5d7ca31baae54a3.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "afa9a883-53d6-4ed1-af9d-91a53ba566d5"
        sample.title = "Waterdeep voices - Lyz Liddell_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/EOaTt%3A2af5edb25218e453eafbca3494afd1c2ab323686/dd%252Fsoundsample%252Ffile%252F520e4db095ebb4fe27006445da920d23.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "426a0a54-9dad-4b47-a741-99e666b1a4d8"
        sample.title = "Waterdeep voices - Michelle Cross_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Rv92d%3Ab438ef3960f54794a101cea4683604c0f05d05bf/dd%252Fsoundsample%252Ffile%252F5881960f9d941d5cab3b4ab25d6b7e64.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "0ff135ac-bb2a-4f46-9ad0-ff5eb15fbbfe"
        sample.title = "Waterdeep voices - Nick Murphy_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/sNYq4%3Af8e99968c0c437784f03ce29558f8c7b068ada4b/dd%252Fsoundsample%252Ffile%252Fa80ccddbfb91589579292d36355355f3.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "dd19776d-7d55-494e-8688-0230bbdd0a02"
        sample.title = "Waterdeep voices - Nick Murphy_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/qUNkf%3A60ee213172a0abd109881480645f30c285034ced/dd%252Fsoundsample%252Ffile%252Fac68b277e7ad8ffe3365287391a0e040.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "8a331600-4e74-465c-aa6d-ed4a75f1e22f"
        sample.title = "Waterdeep voices - Nick Murphy_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/ZnTRF%3Af79f1fe9745066b25e4155ec41a4245bca061fe1/dd%252Fsoundsample%252Ffile%252F5767bedc440ef82ec7ac60a999e0c6f1.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "31aebe97-3a03-40ea-9b8f-a3bc9f8acc1b"
        sample.title = "Waterdeep voices - Nick Murphy_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/3zfBs%3A25500c91636704e922baaf78b0bab01bc7a313fc/dd%252Fsoundsample%252Ffile%252F54dfb6391e25159133a0417af68754e0.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "ef248ccb-c524-4734-94ca-86fbf953143b"
        sample.title = "Waterdeep voices - Nick Murphy_05"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Bbe3N%3A82162a4cc46a896bae6ee7ec16d3565fc0f4aa95/dd%252Fsoundsample%252Ffile%252Fa36cd72aa075ce61f8993f4520579315.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "c0be4b24-f049-47eb-9d89-fe60f7fcb4d9"
        sample.title = "Waterdeep voices - Nick Murphy_06"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/F3Txe%3A6db689aabe641a074c0ba98495cbffd91666a1eb/dd%252Fsoundsample%252Ffile%252Fc5204a862e126499c3069e5329577cc1.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e2c40a46-1054-4eac-a9a0-c5472a2d6964"
        sample.title = "Waterdeep voices - Nick Murphy_07"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/umzrU%3A6f5cdba0709405e160f4adf7f756df4ae3170473/dd%252Fsoundsample%252Ffile%252F58035e7b07ca28458276a0a94e06f311.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "efc23661-e2cb-4c6d-975a-6b2fb3026adc"
        sample.title = "Waterdeep voices - Nick Murphy_08"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/HoVbw%3A8b4727607d774ad77075f76a52bb6f065cc91faf/dd%252Fsoundsample%252Ffile%252Fc9ba1da91155bd378c14d89371d2b659.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e5fdc1fa-afea-496c-bd9b-6a0dd2a8fb5d"
        sample.title = "Waterdeep voices - Steve Hurovitz_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/fJZER%3A872a2251d9d193cc113962b272be84afc7a25469/dd%252Fsoundsample%252Ffile%252F41bc389abdaec58d05e1a25ffc847cf2.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "bf6fc38a-c53f-4e3d-9968-e69dd36cf9eb"
        sample.title = "Waterdeep voices - Steve Hurovitz_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/EyqB9%3Ad73a4426be555c87f05173b6263d4cf08599ea17/dd%252Fsoundsample%252Ffile%252Fc3bcb21f040e3f63d54905454fc0ec3c.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "c4936ed4-874e-4583-b049-9f9f89875c2f"
        sample.title = "Waterdeep voices - Steve Hurovitz_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/krrRy%3A483f8c91a7335b778e285902fbe12e680f0a0d86/dd%252Fsoundsample%252Ffile%252F6451639e5c0178282cc5ba3eca6d180a.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "f183ffd1-094c-4e9a-be36-0c1d1994ce92"
        sample.title = "Waterdeep voices - Steve Hurovitz_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/DsLSC%3A07f706cd0bf6f21f1213304292960fb005d21eb1/dd%252Fsoundsample%252Ffile%252Fd9b04bcf36446ebf06778db9246de0e2.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "595bec20-a524-49c5-b766-3ae4d0679f52"
        sample.title = "Waterdeep voices - Steve Hurovitz_05"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/ZCRZe%3Ab78bdfc64c7b400b8803fb3260297f5db4f6dc97/dd%252Fsoundsample%252Ffile%252Fb8face5ab760acd98e09fe5f74bd8923.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "b3441c1c-9f4b-4b03-96fc-8f8298e1a599"
        sample.title = "Waterdeep voices - Steve Hurovitz_06"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/S0l19%3A46a1fe883d288d5824ca0577fe02c6bbf00390a6/dd%252Fsoundsample%252Ffile%252F7f42f2db10268eaaacd7f0a34f11ac52.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "9e497110-7c6d-4210-8e20-76c0128ac098"
        sample.title = "Waterdeep voices - Steve Hurovitz_07"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/KovTr%3Aedac8a74ccfe54d5bc20e7f501372b8a78b6416a/dd%252Fsoundsample%252Ffile%252Fd8ea81a0c587d281aa4e4976d0061cdc.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "373a4183-8047-4548-825d-c3161e2d10cd"
        sample.title = "Waterdeep voices - Wayne Halsey_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/9QNhd%3A53a6e959cef6f3cc2d508f507d7f6ee2aa232828/dd%252Fsoundsample%252Ffile%252F669602056687331b35c47048b775a0ef.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "a829d77b-30d2-4cd4-9cd0-be606d6b1e66"
        sample.title = "Waterdeep voices - Zachary Drake_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/utlbR%3Ab8ed0676848cc2f783d687be0137ab6485a5c1a6/dd%252Fsoundsample%252Ffile%252Fbd373e8c8a4984d93125dfc2ccf2c49c.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "7c8b037b-c952-482a-9ddb-1e07bd5645a3"
        sample.title = "Waterdeep voices - Zachary Drake_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/p8suB%3A4ace183388781dacf573bd63224f931457860717/dd%252Fsoundsample%252Ffile%252Ff53823f232518840a013843256939f83.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "19a0f690-0b54-43bf-afa3-9f4e61e49fa4"
        sample.title = "Waterdeep voices - Zachary Drake_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Dk4xG%3Af247a44db9812d6c1fdc86744db5380bd059f199/dd%252Fsoundsample%252Ffile%252Fbfedf6f63f35212f2d01cd110b8201aa.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "d95131c0-2393-4dff-9e6f-4359c666855c"
        sample.title = "Waterdeep voices -Mikel Mecham_06"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/cc96e%3A619bbcca265337ed5fd117855b0e6d8ae6175614/dd%252Fsoundsample%252Ffile%252F01881aca1456cb3365ef081fcee13275.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "83596ef5-2a45-4ac6-ae43-a6075c6aa621"
        sample.title = "Waterdeep voices -Mikel Mecham_07"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/EqgRJ%3A5beba159e3cd93eb818ba37a01a8f2db4f54b846/dd%252Fsoundsample%252Ffile%252F201bd14e67231e32520239e08f6990a8.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "108874e6-b3bb-4805-863c-0b4f4f255ffd"
        sample.title = "Waterdeep voices -Mikel Mecham_08"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/FMUJR%3A35d296dece299c3f2412c233f979d72444cee11c/dd%252Fsoundsample%252Ffile%252F3b1f108c8c26e35bb0da3b1b2c164910.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "78bb0dad-79d5-42b3-82f8-b4d06dc9567a"
        sample.title = "Waterdeep voices -Mikel Mecham_09"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/KH0i8%3Ad73943b044578695c17266759bcc36fcb0975f51/dd%252Fsoundsample%252Ffile%252F939888a745d8ccdf81cd114e4a19e0e5.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "0df6f5d1-6a84-48ef-9424-6a27af67db8d"
        sample.title = "Waterdeep voices -Mikel Mecham_12"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/o4Is2%3Ae582770fbde1168b49a2ea50d58b25da92a75399/dd%252Fsoundsample%252Ffile%252Fcceb3cd564e7980cbea8a9af39f21391.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "78b7d62e-f5fd-4255-b9aa-2d5d388c6841"
        sample.title = "Waterdeep voices -Mikel Mecham_18"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/pROla%3A356d77367dd6a406db8140985d81b4777c5641c7/dd%252Fsoundsample%252Ffile%252F46e86865931328a694bcda48537eb123.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "137c71a1-1bcc-4015-a016-e236a069980c"
        sample.title = "Waterdeep voices - Samuel Shipe_09"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/On1RB%3A1032fa0b73c3a3681327907d8343b9c9095d140e/dd%252Fsoundsample%252Ffile%252F3df4f734aa32cb72c1c286de033f7b2c.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "5c8771e5-7d54-4f06-bfc3-dbac40ab8b25"
        sample.title = "Waterdeep voices - Samuel Shipe_10"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/FrxEB%3Aad4eb2e5f9668204fba976a44f3e50074659132b/dd%252Fsoundsample%252Ffile%252F09828df89310e6f71268ae677c04cefb.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "bf806e9c-c87e-4a57-b310-5623cd76a7cc"
        sample.title = "Waterdeep voices - Samuel Shipe_11"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/d6gtW%3Ab814389c1afd80a542be20edf3512d33857779da/dd%252Fsoundsample%252Ffile%252F6494610fc5b24f4a53b84fc45c1c4438.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "1be5cbc9-8889-4ba1-a7dd-ebaddc248e1b"
        sample.title = "Waterdeep voices - Samuel Shipe_12"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/oTnGO%3Ab24ad5b8572d75bc74b72d4c7fe1a15c8cbf92a6/dd%252Fsoundsample%252Ffile%252Fc28188710dbbe52a1ff5dd5524d91a94.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "a8b7e2c4-6cf7-44f2-ba08-4fa725dd601f"
        sample.title = "Waterdeep voices - Samuel Shipe_15"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/iFMpm%3Aa19ac6323872156f468e3e1a11877923f60944ae/dd%252Fsoundsample%252Ffile%252Fdfdb439478db48c30f0d59e8bbe6fe48.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "d1332487-632e-487f-95ab-e84642da2ac0"
        sample.title = "Waterdeep voices 0- Jenny Kwiatek_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/s8hi8%3A86b692d9cd3e9f580dcf09df2d3bafbe6ecfc725/dd%252Fsoundsample%252Ffile%252Fd765a011f80221e714ee66645761f6a2.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "dd320659-48c0-47e6-acb7-791335ef8f35"
        sample.title = "Waterdeep voices 0- rhonda seymour_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/9UrA7%3A6f0a44d216155c89cb93e2ce3afc9af96d8b5fbf/dd%252Fsoundsample%252Ffile%252Fe2b6eaac24938b9d234f8aad9de0ba2d.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "3456d780-d860-4705-a8dc-1628b8c84e85"
        sample.title = "Waterdeep voices 0- rhonda seymour_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/ibaQr%3Ac61df8e8c82fc7f14b868e60fa431d1593bfc025/dd%252Fsoundsample%252Ffile%252Fc72074d48ad4632257418682bbec0c4f.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "4ec97cfa-0552-4a66-ba6f-0ed5684c49d1"
        sample.title = "Waterdeep voices 0- rhonda seymour_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Vz6zq%3Ae715c9374429a4741379fb2031ce7c0a8c26bcf5/dd%252Fsoundsample%252Ffile%252Fb6e6c004802b520b7363f0e73ef6786c.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "9a883642-6039-4003-8714-56d42a3055e5"
        sample.title = "Waterdeep voices 0- rhonda seymour_05"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/q0DHD%3Ac82aebce08003fee226a84c97ec77a98746798cb/dd%252Fsoundsample%252Ffile%252Facee7aca72ce3eaf74d84f81d647f565.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "9889c69b-0b2e-4380-87fd-41fc1f9a5931"
        sample.title = "Waterdeep voices - Jonathan Lowen_05"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/2kb4U%3A3a09fc17bbaaa588360aa95b83def6865449976f/dd%252Fsoundsample%252Ffile%252Fc9aebd36942ca61d86ea9020bfaa07b4.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "9a201b86-82a0-428f-965f-56ea92eacf23"
        sample.title = "Waterdeep voices - Jonathan Lowen_06"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/tTIye%3Afafe23a9ddd5fd160409cd890ef47eb3e9d44528/dd%252Fsoundsample%252Ffile%252F88074a250a07b5f1bfbc60dcb533f201.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "c775afc7-b7be-414a-a957-35634b88974f"
        sample.title = "Waterdeep voices - Jonathan Lowen_07"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/C9fZS%3A54afaf2aa7659744f714d03b5e7759beba251eb1/dd%252Fsoundsample%252Ffile%252F2eeecd1152d371066c37a54aebbe9aff.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "b2d6c6aa-1bef-47fb-aed0-8b900b9b57a4"
        sample.title = "Waterdeep voices - Nicholas Orlando Perez_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/7Bu7t%3Af1eb5b085456d7867e059335b12d4b7ab0aa8212/dd%252Fsoundsample%252Ffile%252F70b6189ce4d1e7637ab2dffdb9cf4d41.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "cefd6de6-9a23-4261-b2d0-d23b4398a0fa"
        sample.title = "Waterdeep voices - Nicholas Orlando Perez_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/wScz1%3A2cf319952a6fe8bcdf368be6de968e9d1536156f/dd%252Fsoundsample%252Ffile%252Ffbd6cd5f9f1107c46c2a07c6f1b27ff7.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "7c93cf48-d222-4183-b3db-51cc3997cdd1"
        sample.title = "Waterdeep voices - Nicholas Orlando Perez_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Xd1iM%3Ae4072488d4919c614d2e978a1498420af385a1cd/dd%252Fsoundsample%252Ffile%252Ff6f95cb124a3c09408dcb02a77a4ff07.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "faf3d8d0-9958-4ec4-9bd0-f16f986abbd2"
        sample.title = "Waterdeep voices - Samuel Shipe_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/rVp1g%3Aebb0f1feeac8942f59057e06477fcbec339b370d/dd%252Fsoundsample%252Ffile%252Fb8205145ac587e5f7fb943941ff213e9.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "f2409d3b-1f52-4c52-9342-19091b4eea7a"
        sample.title = "Waterdeep voices - Samuel Shipe_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/PotPM%3A15b2600e99f5c99a3cb75bafeba0e66f654a3022/dd%252Fsoundsample%252Ffile%252F7518a96577082656eab846f9dd1f0776.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "e4c946be-791a-4b09-b6fd-db8e05f0d7e1"
        sample.title = "Waterdeep voices - Samuel Shipe_06"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/RxxRC%3Ab0869a451b7dfb2b6106815f21f7df011576c7bb/dd%252Fsoundsample%252Ffile%252Fe5909bbc5d698acd2b63257b2685d10a.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "921c195c-151d-489b-b94e-98c5f8d1c778"
        sample.title = "Waterdeep voices - Samuel Shipe_08"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/SUfRn%3Ab1b99f68a4c50675634464219e985869a50c1b53/dd%252Fsoundsample%252Ffile%252Fdd45034a98a3544276b7455754a107f0.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "c712b8d0-f796-4ed5-8256-37ad072698f0"
        sample.title = "Waterdeep voices - Benjamin Skirvin_07"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/OGlFQ%3A38e2dca3841817435884f2e0d83fcb6eae8656c0/dd%252Fsoundsample%252Ffile%252F732a61474130d6ba56c8af20cacc2026.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "43f2a3c5-4f8f-4841-b162-660ccfcba6f3"
        sample.title = "Waterdeep voices - Benjamin Skirvin_08"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/MGoIJ%3Af45b7d3ec194606a24fd9be0980836ca8c055be8/dd%252Fsoundsample%252Ffile%252Fb81b1a11b59edb9fa669c59730bb2067.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "be742ff3-7016-4eb3-ab0b-c302ef79e416"
        sample.title = "Waterdeep voices - Jamie McConnell_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Suy0D%3Ab291899665109fa3aa9fba50bd9e44c9f3b7851a/dd%252Fsoundsample%252Ffile%252F6bff675924ad5fdaae7c666d2f16ada0.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "6cfc60e1-7366-41cf-894e-b2c93e1fae1e"
        sample.title = "Waterdeep voices - Jamie McConnell_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/lHpXW%3Ab961c8de24ef8b44c173ce40a8a78654cd6191f2/dd%252Fsoundsample%252Ffile%252Faba016aa8b7f53e681f67a73c420ffb3.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "37ddd0cb-a3ce-47db-aa7e-11bdb9eb354e"
        sample.title = "Waterdeep voices - Jonathan Lowen_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/C9hci%3A9b4b8fa41e26b73afa5b9592f610cd79fd559ae8/dd%252Fsoundsample%252Ffile%252Fd51be4f73187b2ecb5e296ecdc30acc2.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "2b2ca4d1-5299-4454-aa43-67041643b325"
        sample.title = "Waterdeep voices - Jonathan Lowen_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/Pwo4U%3A8b6fc072a4d4233f24ea71c5174019f80d145e2d/dd%252Fsoundsample%252Ffile%252Ff9bcd08449e710d3f90233fa46ce5de0.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "3559fd6e-642b-4f35-ade2-dc720e555897"
        sample.title = "Waterdeep voices - Jonathan Lowen_03"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/O023C%3Abd78ad14f889c17033bc0c8fbb5d5cd15d75b2bc/dd%252Fsoundsample%252Ffile%252Fec1532297cdbba13caea48071c177ab9.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "3728f489-816e-4142-a16a-8d9d6d572f9e"
        sample.title = "Waterdeep voices - Benjamin Skirvin_01"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/HaQjj%3Acd4351ebbe25affb3c599729fab4eb2bc05de657/dd%252Fsoundsample%252Ffile%252F9a4b991c3dee102ce6f915c1288d3092.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "76167b96-59ec-41fd-8eea-46232c269b31"
        sample.title = "Waterdeep voices - Benjamin Skirvin_02"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/sxE2N%3A01b722c7df94d2223e6d1a9e1b1582f98d7dbf54/dd%252Fsoundsample%252Ffile%252F9a5c18af09291eb5a8b17be0fe3ae5ef.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        sample = SampleManagedObject(context: managedObjectContext)
        sample.uuid = "3f4655ce-a6d2-4b9e-96ee-909dedb410b6"
        sample.title = "Waterdeep voices - Benjamin Skirvin_04"
        sample.url = URL(string: "https://www.syrinscape.com/permalink/01OgS%3A1a064e6e1a8ab244ec48c75565e94e36ea1cf21f/dd%252Fsoundsample%252Ffile%252F5b860c6061fd2d6c93cde6c167d40679.ogg/")

        playlistEntry = PlaylistEntryManagedObject(context: managedObjectContext)
        playlistEntry.sample = sample
        element.addToPlaylistEntries(playlistEntry)

        soundset = SoundsetManagedObject(context: managedObjectContext)
        soundset.categoryRawValue = Soundset.Category.fantasy.rawValue
        soundset.slug = "dance-of-dragons"
        soundset.title = "Dance of Dragons"
        soundset.url = URL(string: "https://netsplit.com/nosuchfile")
        soundset.updatedDate = Date()
        soundset.downloadedDate = soundset.updatedDate
        soundset.imageData = UIImage(named: "RiseTiamat")?.jpegData(compressionQuality: 1.0)
        soundsetObjects.append(soundset)

        soundset = SoundsetManagedObject(context: managedObjectContext)
        soundset.categoryRawValue = Soundset.Category.fantasy.rawValue
        soundset.slug = "eye-of-the-beholder"
        soundset.title = "Eye of the Beholder"
        soundset.url = URL(string: "https://netsplit.com/nosuchfile")
        soundset.updatedDate = Date()
        soundset.downloadedDate = soundset.updatedDate
        soundset.imageData = UIImage(named: "Beholder")?.jpegData(compressionQuality: 1.0)
        soundsetObjects.append(soundset)

        try! managedObjectContext.save()

        soundsets = soundsetObjects.map { Soundset(managedObject: $0) }
    }

}

let previewContent = PreviewContent()

#endif
