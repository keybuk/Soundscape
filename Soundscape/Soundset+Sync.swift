//
//  Soundset+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension SoundsetManagedObject {
    static let currentSchemaVersion: Int16 = 2

    static func createFrom(_ chapterClient: SyrinscapeChaptersClient.ChapterOptions, category: Soundset.Category, context managedObjectContext: NSManagedObjectContext) {
        guard chapterClient.isBundled || chapterClient.isPurchased,
            let slug = chapterClient.slug,
            let title = chapterClient.title,
            let manifestURL = chapterClient.manifestURL,
            let downloadUpdatedDate = chapterClient.downloadUpdatedDate
            else { return }

        // Ignore the "Custom Moods" soundsets.
        let customMoodsSKUs = [
            // Fantasy
            "5d6d7750244411e58461f23c9170c08b",
            "698b015e726011e6a63bf23c9170c08b",
            "786df12c726011e6afb8f23c9170c08b",
            // Sci-Fi
            "8b56b392248611e5a8aaf23c9170c08b",
            "395c553a943b11e69f2cf23c9170c08b",
            "46506e2a943b11e6ad9ff23c9170c08b"
        ]
        if let sku = chapterClient.sku, customMoodsSKUs.contains(sku) {
            return
        }

        let fetchRequest: NSFetchRequest<SoundsetManagedObject> = SoundsetManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "slug == %@", slug)

        managedObjectContext.perform {
            let soundset: SoundsetManagedObject
            do {
                let results = try fetchRequest.execute()
                soundset = results.first ?? SoundsetManagedObject(context: managedObjectContext)
            } catch let error {
                print("Failed to fetch soundset \(slug): \(error.localizedDescription)")
                return
            }

            soundset.categoryRawValue = category.rawValue
            soundset.slug = slug
            soundset.title = title
            soundset.url = manifestURL
            soundset.updatedDate = downloadUpdatedDate

            do {
                if soundset.hasChanges {
                    try managedObjectContext.save()
                }
            } catch let error {
                print("Failed to save changes to soundset \(slug): \(error.localizedDescription)")
                return
            }

            if soundset.imageData == nil, let url = chapterClient.backgroundImageURL {
                soundset.downloadImage(url: url, property: \.imageData)
            }

            if soundset.inactiveImageData == nil, let url = chapterClient.inactiveBackgroundImageURL {
                soundset.downloadImage(url: url, property: \.inactiveImageData)
            }
        }
    }

    func downloadImage(url: URL, property: ReferenceWritableKeyPath<SoundsetManagedObject, Data?>) {
        downloadImage(url: url) { result in
            switch result {
            case let .success(imageData):
                self.managedObjectContext?.perform {
                    self[keyPath: property] = imageData

                    do {
                        try self.managedObjectContext?.save()
                    } catch let error {
                        print("Failed to save context for \(self.slug!) inactive image: \(error.localizedDescription)")
                        return
                    }
                }
            case let .failure(error):
                print("Failed to download image \(url): \(error.localizedDescription)")
            }
        }
    }

    func downloadImage(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url.authenticatedForSyrinscape() ?? url) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completionHandler(.failure(SyrinscapeDownloadError.invalidServerResponse(response)))
                return
            }

            guard httpResponse.statusCode == 200 else {
                completionHandler(.failure(SyrinscapeDownloadError.badServerResponse(httpResponse.statusCode)))
                return
            }

            guard httpResponse.mimeType == "image/jpeg" else {
                completionHandler(.failure(SyrinscapeDownloadError.incorrectMimeType(httpResponse.mimeType)))
                return
            }

            completionHandler(.success(data))
        }
        task.resume()
    }

    var isUpdatePending: Bool {
        downloadedDate == nil || downloadedDate! < updatedDate! || schemaVersion != Self.currentSchemaVersion
    }

    func updateFromServer(context managedObjectContext: NSManagedObjectContext, completionHander: (() -> Void)? = nil) {
        guard let url = url else {
            completionHander?()
            return
        }

        let manifestClient = SyrinscapeManifestClient()
        manifestClient.download(fromURL: url) { result in
            switch result {
            case .success(_):
                if let chapterFile = manifestClient.soundsetFile(matching: "chapter.xml"),
                    let chapterURL = chapterFile.url
                {
                    let chapterClient = SyrinscapeChapterClient()
                    chapterClient.download(fromURL: chapterURL) { result in
                        switch result {
                        case .success(_):
                            managedObjectContext.perform {
                                let soundset = managedObjectContext.object(with: self.objectID) as! SoundsetManagedObject
                                print("Updating \(soundset.slug!)")
                                soundset.updateFrom(chapterClient, manifestClient: manifestClient)
                                print("Done!")
                            }
                            completionHander?()
                        case let .failure(error):
                            print("Failed to download chapter from \(chapterURL): \(error.localizedDescription)")
                            completionHander?()
                            return
                        }
                    }
                } else {
                    print("Missing chapter file from \(self.url!)")
                    completionHander?()
                    return
                }
            case let .failure(error):
                print("Failed to download manifest from \(self.url!): \(error.localizedDescription)")
                completionHander?()
                return
            }
        }
    }

    func updateFrom(_ chapterClient: SyrinscapeChapterClient, manifestClient: SyrinscapeManifestClient) {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        for sample in chapterClient.samples {
            SampleManagedObject.createFrom(sample, manifestClient: manifestClient, context: managedObjectContext!)
        }

        let oldElements = elements!
        var newElements: [ElementManagedObject] = []
        newElements.append(contentsOf: chapterClient.musicElements.compactMap {
            ElementManagedObject.createFrom($0, kind: .music, soundset: self, context: managedObjectContext!)
        })
        newElements.append(contentsOf: chapterClient.sfxElements.compactMap {
            ElementManagedObject.createFrom($0, kind: .effect, soundset: self, context: managedObjectContext!)
        })
        newElements.append(contentsOf: chapterClient.oneShotElements.compactMap {
            ElementManagedObject.createFrom($0, kind: .oneShot, soundset: self, context: managedObjectContext!)
        })
        elements = NSOrderedSet(array: newElements)

        for case let .remove(offset: _, element: removed, associatedWith: _) in elements!.difference(from: oldElements) {
            let removedElement = removed as! ElementManagedObject
            print("Removed element \(removedElement.slug!) from soundset \(slug!)")
            managedObjectContext!.delete(removedElement)
        }

        let oldMoods = moods!
        var newMoods: [MoodManagedObject] = []
        newMoods.append(contentsOf: chapterClient.moods.compactMap {
            MoodManagedObject.createFrom($0, soundset: self, context: managedObjectContext!)
        })
        moods = NSOrderedSet(array: newMoods)

        for case let .remove(offset: _, element: removed, associatedWith: _) in moods!.difference(from: oldMoods) {
            let removedMood = removed as! MoodManagedObject
            print("Removed mood \(removedMood.title!) from soundset \(slug!)")
            managedObjectContext!.delete(removedMood)
        }

        downloadedDate = updatedDate
        schemaVersion = Self.currentSchemaVersion

        do {
            if hasChanges {
                try managedObjectContext?.save()
            }
        } catch let error {
            print("Failed to save changes to soundset \(slug!): \(error.localizedDescription)")
        }
    }
}
