//
//  SyrinscapeCategory.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

enum SyrinscapeCategory: Int16, CaseIterable {
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
}
