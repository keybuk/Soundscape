//
//  Soundset.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import SwiftUI
import CoreGraphics

final class Soundset: Identifiable, Hashable, ObservableObject {
    @Published var id: String
    @Published var category: Category
    @Published var title: String
    @Published var url: URL?
    @Published var updatedDate: Date?
    @Published var downloadedDate: Date?

    @Published private var activeImageData: Data?
    @Published private var inactiveImageData: Data?

    private var managedObject: SoundsetManagedObject

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

    var image: Image { updatedDate == nil || downloadedDate != nil ? activeImage : inactiveImage }

    private var _activeImage: Image?
    var activeImage: Image {
        if let activeImage = _activeImage { return activeImage }

        if let imageData = activeImageData,
            let dataProvider = CGDataProvider(data: imageData as CFData),
            let cgImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        {
            _activeImage = Image(decorative: cgImage, scale: 1.0)
            return _activeImage!
        } else {
            _activeImage = Image("SoundsetImagePlaceholder")
            return _activeImage!
        }
    }

    private var _inactiveImage: Image?
    var inactiveImage: Image {
        if let inactiveImage = _inactiveImage { return inactiveImage }

        if let imageData = inactiveImageData,
            let dataProvider = CGDataProvider(data: imageData as CFData),
            let cgImage = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        {
            _inactiveImage = Image(decorative: cgImage, scale: 1.0)
            return _inactiveImage!
        } else {
            _inactiveImage = Image("SoundsetInactiveImagePlaceholder")
            return _inactiveImage!
        }
    }

    private var _allElements: [Element]?
    var allElements: [Element] {
        if let allElements = _allElements { return allElements }

        updateElements()
        return _allElements!
    }

    private var _musicElements: [Element]?
    var musicElements: [Element] {
        if let musicElements = _musicElements { return musicElements }

        updateElements()
        return _musicElements!
    }

    private var _effectElements: [Element]?
    var effectElements: [Element] {
        if let effectElements = _effectElements { return effectElements }

        updateElements()
        return _effectElements!
    }

    private var _oneshotElements: [Element]?
    var oneshotElements: [Element] {
        if let oneshotElements = _oneshotElements { return oneshotElements }

        updateElements()
        return _oneshotElements!
    }

    private func updateElements() {
        _allElements = []
        _musicElements = []
        _effectElements = []
        _oneshotElements = []

        guard let elementObjects = managedObject.elements else { return }

        for case let elementObject as ElementManagedObject in elementObjects {
            let element = Element(managedObject: elementObject)
            _allElements!.append(element)

            switch element.kind {
            case .music: _musicElements!.append(element)
            case .effect: _effectElements!.append(element)
            case .oneshot: _oneshotElements!.append(element)
            }
        }
    }

    private var _moods: [Mood]?
    var moods: [Mood] {
        if let moods = _moods { return moods }

        _moods = []

        guard let moodObjects = managedObject.moods else { return _moods! }

        for case let moodObject as MoodManagedObject in moodObjects {
            let mood = Mood(managedObject: moodObject, soundset: self)
            _moods!.append(mood)
        }

        return _moods!
    }


    init(managedObject: SoundsetManagedObject) {
        id = managedObject.slug!
        category = Category(rawValue: managedObject.categoryRawValue)!
        title = managedObject.title!
        url = managedObject.url
        updatedDate = managedObject.updatedDate
        downloadedDate = managedObject.downloadedDate

        self.managedObject = managedObject
    }

    static func == (lhs: Soundset, rhs: Soundset) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
