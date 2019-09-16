//
//  Element+Kind.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

enum ElementKind: Int16 {
    case music
    case effect
    case oneshot
}

extension Element {
    var kind: ElementKind {
        get { ElementKind(rawValue: kindRawValue)! }
        set { kindRawValue = newValue.rawValue }
    }
}
