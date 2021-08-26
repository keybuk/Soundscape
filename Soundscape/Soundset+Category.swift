//
//  Soundset+Category.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Soundset {
    /// Category of the soundset.
    var category: Category {
        get { Category(rawValue: categoryRawValue)! }
        set { categoryRawValue = newValue.rawValue }
    }

    enum Category: Int16, CaseIterable, Identifiable, CustomStringConvertible {
        case fantasy
        case sciFi
        case boardgame
        case homebrew

        /// Returns the Syrinscape URL component for the category or `nil`.
        private var urlComponent: String {
            switch self {
            case .fantasy: return "fantasy"
            case .sciFi: return "sci-fi"
            case .boardgame: return "boardgame"
            case .homebrew: preconditionFailure("No URL component for \(self)")
            }
        }

        /// Returns the URL from which the category can be downloaded.
        var url: URL {
            switch self {
            case .homebrew: return URL(string: "https://netsplit.com/soundscape/chapters.xml")!
            default: return URL(string: "https://www.syrinscape.com/account/chapters/\(urlComponent)/1.2.1/")!
            }
        }

        var id: Category { self }

        var description: String {
            switch self {
            case .fantasy: return "Fantasy"
            case .sciFi: return "Sci-Fi"
            case .boardgame: return "Board Game"
            case .homebrew: return "Homebrew"
            }
        }
    }
}
