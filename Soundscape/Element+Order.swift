//
//  Element+Order.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

enum ElementOrder: Int16 {
    case inOrder
    case shuffle
    case random
}

extension Element {
    var order: ElementOrder {
        get { ElementOrder(rawValue: orderRawValue)! }
        set { orderRawValue = newValue.rawValue }
    }
}
