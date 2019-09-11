//
//  Soundset+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Soundset {
    static func syncFrom(_ chapterOptions: SyrinscapeChaptersClient.ChapterOptions, category: SoundsetCategory, on managedObjectContext: NSManagedObjectContext) {
        guard chapterOptions.isBundled || chapterOptions.isPurchased,
            let slug = chapterOptions.slug,
            let _ = chapterOptions.title,
            let _ = chapterOptions.manifestURL,
            let _ = chapterOptions.downloadUpdatedDate
            else { return }

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
        if let sku = chapterOptions.sku, customMoodsSKUs.contains(sku) {
            return
        }

        let fetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "slug == %@", slug)

        managedObjectContext.perform {
            do {
                let results = try fetchRequest.execute()
                if let soundset = results.first {
                    soundset.updateFrom(chapterOptions, category: category, on: managedObjectContext)
                } else {
                    let soundset = Soundset(context: managedObjectContext)
                    soundset.updateFrom(chapterOptions, category: category, on: managedObjectContext)
                }
            } catch let error {
                print("Failed to fetch soundset for \(slug): \(error.localizedDescription)")
            }
        }
    }

    func updateFrom(_ chapterOptions: SyrinscapeChaptersClient.ChapterOptions, category: SoundsetCategory, on managedObjectContext: NSManagedObjectContext) {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        if updatedDate == nil || updatedDate! != chapterOptions.downloadUpdatedDate! {
            // These are verified as present by syncChapter()
            self.category = category
            slug = chapterOptions.slug!
            title = chapterOptions.title!
            url = chapterOptions.manifestURL!
            updatedDate = chapterOptions.downloadUpdatedDate!

            if hasChanges {
                do {
                    try managedObjectContext.save()
                } catch let error {
                    print("Failed to save context for \(slug!): \(error.localizedDescription)")
                    return
                }
            }
        }

        if imageData == nil, let url = chapterOptions.backgroundImageURL {
            downloadImage(url: url, property: \.imageData, on: managedObjectContext)
        }

        if inactiveImageData == nil, let url = chapterOptions.inactiveBackgroundImageURL {
            downloadImage(url: url, property: \.inactiveImageData, on: managedObjectContext)
        }
    }

    func downloadImage(url: URL, property: WritableKeyPath<Soundset, Data?>, on managedObjectContext: NSManagedObjectContext) {
        downloadImage(url: url) { result in
            switch result {
            case let .success(imageData):
                managedObjectContext.perform {
                    var soundset = managedObjectContext.object(with: self.objectID) as! Soundset
                    soundset[keyPath: property] = imageData

                    do {
                        try managedObjectContext.save()
                    } catch let error {
                        print("Failed to save context for \(soundset.slug!) inactive image: \(error.localizedDescription)")
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
}
