//
//  Soundset+Properties.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Soundset {
    /// Returns `true` if the soundset is available.
    var isActive: Bool { downloadedDate != nil }
}

