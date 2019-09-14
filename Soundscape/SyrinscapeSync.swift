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
        let categoryIterator = SoundsetCategory.allCases.makeIterator()
        syncNextCategory(iterator: categoryIterator)
    }

    func syncNextCategory(iterator categoryIterator: SoundsetCategory.AllCases.Iterator) {
        var categoryIterator = categoryIterator
        guard let category = categoryIterator.next() else { return }

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
}
