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

    let container: NSPersistentContainer
    var managedObjectContext: NSManagedObjectContext { container.viewContext }

    var soundsets: [Soundset]

    init() {
        container = NSPersistentContainer(name: "Soundscape")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error { fatalError("\(error.localizedDescription)") }
        }

        soundsets = []

        var soundset = Soundset(context: managedObjectContext)
        soundset.category = .fantasy
        soundset.slug = "battle-for-lake-town"
        soundset.title = "Battle for Lake Town"
        soundset.url = URL(string: "https://netsplit.com/nosuchfile")
        soundset.updatedDate = Date()
        soundset.downloadedDate = soundset.updatedDate
        soundset.imageData = UIImage(named: "LakeTown")?.jpegData(compressionQuality: 1.0)
        soundsets.append(soundset)

        soundset = Soundset(context: managedObjectContext)
        soundset.category = .fantasy
        soundset.slug = "dance-of-dragons"
        soundset.title = "Dance of Dragons"
        soundset.url = URL(string: "https://netsplit.com/nosuchfile")
        soundset.updatedDate = Date()
        soundset.downloadedDate = soundset.updatedDate
        soundset.imageData = UIImage(named: "RiseTiamat")?.jpegData(compressionQuality: 1.0)
        soundsets.append(soundset)

        soundset = Soundset(context: managedObjectContext)
        soundset.category = .fantasy
        soundset.slug = "eye-of-the-beholder"
        soundset.title = "Eye of the Beholder"
        soundset.url = URL(string: "https://netsplit.com/nosuchfile")
        soundset.updatedDate = Date()
        soundset.downloadedDate = soundset.updatedDate
        soundset.imageData = UIImage(named: "Beholder")?.jpegData(compressionQuality: 1.0)
        soundsets.append(soundset)

        try! managedObjectContext.save()
    }

}

let previewContent = PreviewContent()

#endif
