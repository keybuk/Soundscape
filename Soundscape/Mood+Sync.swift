//
//  Mood+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension MoodManagedObject {
    static func createFrom(_ clientMood: SyrinscapeChapterClient.Mood, soundset: SoundsetManagedObject, context managedObjectContext: NSManagedObjectContext) -> MoodManagedObject? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let title = clientMood.title
            else { return nil }

        let fetchRequest: NSFetchRequest<MoodManagedObject> = MoodManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "soundset == %@ AND title == %@", soundset, title)

        let mood: MoodManagedObject
        do {
            let results = try fetchRequest.execute()
            mood = results.first ?? MoodManagedObject(context: managedObjectContext)
        } catch let error {
            print("Failed to fetch mood for \(title): \(error.localizedDescription)")
            return nil
        }

        mood.title = title

        let oldElementParameters: Set<ElementParameterManagedObject>  = mood.elementParameters! as! Set<ElementParameterManagedObject>
        let newElementParameters: [ElementParameterManagedObject] = clientMood.elementParameters.compactMap {
            ElementParameterManagedObject.createFrom($0, mood: mood, context: managedObjectContext)
        }
        mood.elementParameters = NSSet(array: newElementParameters)

        for removedParameter in oldElementParameters.subtracting(newElementParameters) {
            print("Removed element parameter from mood \(mood.title!)")
            managedObjectContext.delete(removedParameter)
        }

        return mood
    }
}
