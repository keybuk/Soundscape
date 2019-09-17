//
//  Mood+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension Mood {
    @discardableResult
    static func createFrom(_ clientMood: SyrinscapeChapterClient.Mood, soundset: Soundset, context managedObjectContext: NSManagedObjectContext) -> Mood? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let title = clientMood.title
            else { return nil }

        let fetchRequest: NSFetchRequest<Mood> = Mood.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "soundset == %@ AND title == %@", soundset, title)

        let mood: Mood
        do {
            let results = try fetchRequest.execute()
            mood = results.first ?? Mood(context: managedObjectContext)
        } catch let error {
            print("Failed to fetch mood for \(title): \(error.localizedDescription)")
            return nil
        }

        mood.title = title

        let newElementParameters: [ElementParameter] = clientMood.elementParameters.compactMap {
            ElementParameter.createFrom($0, mood: mood, context: managedObjectContext)
        }
        mood.elementParameters = NSSet(array: newElementParameters)

        return mood
    }
}