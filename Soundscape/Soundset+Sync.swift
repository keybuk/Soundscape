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
    static let currentSchemaVersion: Int16 = 1

    static func createFrom(_ clientChapter: SyrinscapeChaptersClient.ChapterOptions, category: SoundsetCategory, context managedObjectContext: NSManagedObjectContext) {
        guard clientChapter.isBundled || clientChapter.isPurchased,
            let slug = clientChapter.slug,
            let title = clientChapter.title,
            let manifestURL = clientChapter.manifestURL,
            let downloadUpdatedDate = clientChapter.downloadUpdatedDate
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
        if let sku = clientChapter.sku, customMoodsSKUs.contains(sku) {
            return
        }

        let fetchRequest: NSFetchRequest<Soundset> = Soundset.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "slug == %@", slug)

        managedObjectContext.perform {
            let soundset: Soundset
            do {
                let results = try fetchRequest.execute()
                soundset = results.first ?? Soundset(context: managedObjectContext)
            } catch let error {
                print("Failed to fetch soundset \(slug): \(error.localizedDescription)")
                return
            }

            soundset.category = category
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

            if soundset.imageData == nil, let url = clientChapter.backgroundImageURL {
                soundset.downloadImage(url: url, property: \.imageData)
            }

            if soundset.inactiveImageData == nil, let url = clientChapter.inactiveBackgroundImageURL {
                soundset.downloadImage(url: url, property: \.inactiveImageData)
            }
        }
    }

    func downloadImage(url: URL, property: ReferenceWritableKeyPath<Soundset, Data?>) {
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
}
