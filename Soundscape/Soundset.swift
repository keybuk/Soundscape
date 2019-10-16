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

    private var _allPlaylists: [Playlist]?
    var allPlaylists: [Playlist] {
        if let allPlaylists = _allPlaylists { return allPlaylists }

        updatePlaylists()
        return _allPlaylists!
    }

    private var _musicPlaylists: [Playlist]?
    var musicPlaylists: [Playlist] {
        if let musicPlaylists = _musicPlaylists { return musicPlaylists }

        updatePlaylists()
        return _musicPlaylists!
    }

    private var _effectPlaylists: [Playlist]?
    var effectPlaylists: [Playlist] {
        if let effectPlaylists = _effectPlaylists { return effectPlaylists }

        updatePlaylists()
        return _effectPlaylists!
    }

    private var _oneshotPlaylists: [Playlist]?
    var oneshotPlaylists: [Playlist] {
        if let oneshotPlaylists = _oneshotPlaylists { return oneshotPlaylists }

        updatePlaylists()
        return _oneshotPlaylists!
    }

    private func updatePlaylists() {
        _allPlaylists = []
        _musicPlaylists = []
        _effectPlaylists = []
        _oneshotPlaylists = []

        guard let elementObjects = managedObject.elements else { return }

        for case let elementObject as ElementManagedObject in elementObjects {
            let playlist = Playlist(managedObject: elementObject)
            _allPlaylists!.append(playlist)

            switch playlist.kind {
            case .music: _musicPlaylists!.append(playlist)
            case .effect: _effectPlaylists!.append(playlist)
            case .oneshot: _oneshotPlaylists!.append(playlist)
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
