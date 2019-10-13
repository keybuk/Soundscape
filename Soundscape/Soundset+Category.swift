//
//  Soundset+Category.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

enum SoundsetCategory: Int16, CaseIterable, CustomStringConvertible {
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

extension Soundset {
    var category: SoundsetCategory {
        get { SoundsetCategory(rawValue: categoryRawValue)! }
        set { categoryRawValue = newValue.rawValue }
    }
}
