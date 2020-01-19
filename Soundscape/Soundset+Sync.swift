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
    static let currentSchemaVersion: Int16 = 3

    static func createFrom(_ client: SyrinscapeChaptersClient.ChapterOptions, category: Soundset.Category, context managedObjectContext: NSManagedObjectContext) {
        guard client.isBundled || client.isPurchased,
            let slug = client.slug,
            let title = client.title,
            let manifestURL = client.manifestURL,
            let downloadUpdatedDate = client.downloadUpdatedDate
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
        if let sku = client.sku, customMoodsSKUs.contains(sku) {
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

            if soundset.activeImageData == nil, let url = client.backgroundImageURL {
                soundset.downloadImage(url: url, property: \.activeImageData)
            }

            if soundset.inactiveImageData == nil, let url = client.inactiveBackgroundImageURL {
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

    var isUpdatePending: Bool {
        downloadedDate == nil || downloadedDate! < updatedDate! || schemaVersion != Self.currentSchemaVersion
    }

    func updateFromServer(context managedObjectContext: NSManagedObjectContext, completionHander: (() -> Void)? = nil) {
        guard let url = url else {
            completionHander?()
            return
        }

        let manifest = SyrinscapeManifestClient()
        manifest.download(fromURL: url) { result in
            switch result {
            case .success(_):
                if let chapterFile = manifest.soundsetFile(matching: "chapter.xml"),
                    let chapterURL = chapterFile.url
                {
                    let client = SyrinscapeChapterClient()
                    client.download(fromURL: chapterURL) { result in
                        switch result {
                        case .success(_):
                            managedObjectContext.perform {
                                let soundset = managedObjectContext.object(with: self.objectID) as! Soundset
                                soundset.updateFrom(client, manifest: manifest)
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

    func updateFrom(_ client: SyrinscapeChapterClient, manifest: SyrinscapeManifestClient) {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        print("Updating \(slug!)")
        for sample in client.samples {
            Sample.createFrom(sample, manifest: manifest, context: managedObjectContext!)
        }

        let oldPlaylists = playlists!
        var newPlaylists: [Playlist] = []
        newPlaylists.append(contentsOf: client.musicElements.compactMap {
            Playlist.createFrom($0, kind: .music, soundset: self, context: managedObjectContext!)
        })
        newPlaylists.append(contentsOf: client.sfxElements.compactMap {
            Playlist.createFrom($0, kind: .effect, soundset: self, context: managedObjectContext!)
        })
        newPlaylists.append(contentsOf: client.oneShotElements.compactMap {
            Playlist.createFrom($0, kind: .oneShot, soundset: self, context: managedObjectContext!)
        })
        playlists = NSOrderedSet(array: newPlaylists)

        for case let .remove(offset: _, element: removed as Playlist, associatedWith: _) in playlists!.difference(from: oldPlaylists) {
            print("Removed element \(removed.slug!) from soundset \(slug!)")
            managedObjectContext!.delete(removed)
        }

        let oldMoods = moods!
        var newMoods: [Mood] = []
        newMoods.append(contentsOf: client.moods.compactMap {
            Mood.createFrom($0, soundset: self, context: managedObjectContext!)
        })
        moods = NSOrderedSet(array: newMoods)

        for case let .remove(offset: _, element: removed as Mood, associatedWith: _) in moods!.difference(from: oldMoods) {
            print("Removed mood \(removed.title!) from soundset \(slug!)")
            managedObjectContext!.delete(removed)
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
