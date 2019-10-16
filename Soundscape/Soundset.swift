//
//  Soundset.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

final class Soundset: Identifiable, Hashable, ObservableObject {
    @Published var id: String
    @Published var category: Category
    @Published var title: String
    @Published var url: URL?
    @Published var updatedDate: Date?
    @Published var downloadedDate: Date?

    @Published var activeImageData: Data?
    @Published var inactiveImageData: Data?

    @Published var allElements: [Element]
    @Published var musicElements: [Element]
    @Published var effectElements: [Element]
    @Published var oneshotElements: [Element]

    @Published var moods: [Mood]

    enum Category: Int16, CaseIterable, CustomStringConvertible {
        case fantasy
        case sciFi
        case boardgame

        var urlComponent: String {
            switch self {
            case .fantasy: return "fantasy"
            case .sciFi: return "sci-fi"
            case .boardgame: return "boardgame"
            }
        }

        var description: String {
            switch self {
            case .fantasy: return "Fantasy"
            case .sciFi: return "Sci-Fi"
            case .boardgame: return "Board Game"
            }
        }
    }

    init(managedObject: SoundsetManagedObject) {
        id = managedObject.slug!
        category = Category(rawValue: managedObject.categoryRawValue)!
        title = managedObject.title!
        url = managedObject.url
        updatedDate = managedObject.updatedDate
        downloadedDate = managedObject.downloadedDate

        allElements = []
        musicElements = []
        effectElements = []
        oneshotElements = []

        moods = []

        if let elementObjects = managedObject.elements {
            for case let elementObject as ElementManagedObject in elementObjects {
                let element = Element(managedObject: elementObject)
                allElements.append(element)

                switch element.kind {
                case .music: musicElements.append(element)
                case .effect: effectElements.append(element)
                case .oneshot: oneshotElements.append(element)
                }
            }
        }

        if let moodObjects = managedObject.moods {
            for case let moodObject as MoodManagedObject in moodObjects {
                let mood = Mood(managedObject: moodObject, soundset: self)
                moods.append(mood)
            }
        }
    }

    static func == (lhs: Soundset, rhs: Soundset) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
