//
//  Element+Range.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Element {
    var startDelay: ClosedRange<Double> {
        get { minStartDelay...maxStartDelay }
        set {
            minStartDelay = newValue.lowerBound
            maxStartDelay = newValue.upperBound
        }
    }

    var sampleGap: ClosedRange<Double> {
        get { minSampleGap...maxSampleGap }
        set {
            minSampleGap = newValue.lowerBound
            maxSampleGap = newValue.upperBound
        }
    }
}
