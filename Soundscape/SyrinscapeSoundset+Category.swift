//
//  SyrinscapeSoundset+Category.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension SyrinscapeSoundset {
    var category: SyrinscapeCategory {
        get { SyrinscapeCategory(rawValue: categoryRawValue)! }
        set { categoryRawValue = newValue.rawValue }
    }
}
