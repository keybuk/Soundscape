//
//  Sample.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/15/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

final class Sample: Identifiable, Hashable, ObservableObject {
    @Published var id: String
    @Published var title: String
    @Published var url: URL

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
