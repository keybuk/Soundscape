//
//  ElementParameter+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension ElementParameterManagedObject {
    static func createFrom(_ clientElementParameter: SyrinscapeChapterClient.ElementParameter, mood: MoodManagedObject, context managedObjectContext: NSManagedObjectContext) -> ElementParameterManagedObject? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let elementSlug = clientElementParameter.elementSlug
            else { return nil }

        let fetchRequest: NSFetchRequest<ElementParameterManagedObject> = ElementParameterManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mood == %@ AND element.slug == %@", mood, elementSlug)

        var elementParameter: ElementParameterManagedObject?
        do {
            let results = try fetchRequest.execute()
            elementParameter = results.first
        } catch let error {
            print("Failed to fetch element parameter: \(error.localizedDescription)")
            return nil
        }

        if elementParameter == nil {
            let elementFetchRequest: NSFetchRequest<ElementManagedObject> = ElementManagedObject.fetchRequest()
            elementFetchRequest.predicate = NSPredicate(format: "slug == %@", elementSlug)

            let element: ElementManagedObject?
            do {
                let elementResults = try elementFetchRequest.execute()
                element = elementResults.first
            } catch let error {
                print("Failed to fetch element \(elementSlug): \(error.localizedDescription)")
                return nil
            }

            if element == nil {
                print("Missing element: \(elementSlug) for playlist entry")
                return nil
            }

            elementParameter = ElementParameterManagedObject(context: managedObjectContext)
            elementParameter!.element = element
        }

        elementParameter!.isPlaying = clientElementParameter.plays
        elementParameter!.volume = clientElementParameter.volume ?? 1

        return elementParameter
    }
}
