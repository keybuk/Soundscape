//
//  Mood.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

final class Mood: Identifiable, Hashable, ObservableObject {
    @Published var id: URL
    @Published var title: String

    @Published var elements: [ElementParameter]

    struct ElementParameter {
        var element: Element
        var isPlaying: Bool
        var volume: Float
    }

    init(managedObject: MoodManagedObject, soundset: Soundset) {
        id = managedObject.objectID.uriRepresentation()
        title = managedObject.title!

        var elements: [ElementParameter] = []
        if let elementParameters = managedObject.elementParameters {
            for case let elementParameterObject as ElementParameterManagedObject in elementParameters {
                guard let element = soundset.allElements.first(where: { $0.id == elementParameterObject.element!.slug! }) else { continue }

                let elementParameter = ElementParameter(element: element, isPlaying: elementParameterObject.isPlaying, volume: elementParameterObject.volume)
                elements.append(elementParameter)
            }
        }
        self.elements = elements
    }

    static func == (lhs: Mood, rhs: Mood) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
