//
//  Sample.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

struct Sample: Identifiable, Hashable {
    var id: String
    var title: String
    var url: URL

    init(managedObject: SampleManagedObject) {
        id = managedObject.uuid!
        title = managedObject.title!
        url = managedObject.url!
    }

    static func == (lhs: Sample, rhs: Sample) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
