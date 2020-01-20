//
//  SectionedList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SectionedList<Data, ID, Content>: View
where Data: RandomAccessCollection, ID: Hashable, Content: View {
    var data: Data
    var id: KeyPath<Data.Element, ID>
    var content: (Data.SubSequence) -> Content

    private var sectionData: [Data.SubSequence] {
        data.split(between: {
            $0[keyPath: id] != $1[keyPath: id]
        })
    }

    private var sectionKeyPath: KeyPath<Data.SubSequence, ID> {
        (\Data.SubSequence.first.unsafelyUnwrapped).appending(path: id)
    }

    var spacing: CGFloat

    init(_ data: Data, id: KeyPath<Data.Element, ID>,
         spacing: CGFloat = 12,
         @ViewBuilder content: @escaping (Data.SubSequence) -> Content)
    {
        self.data = data
        self.id = id
        self.content = content

        self.spacing = spacing
    }

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(sectionData, id: sectionKeyPath) { items in
                self.content(items)
            }
        }
    }
}

#if DEBUG
struct SectionedList_TestData {
    var section: String
    var data: String
}

struct SectionedList_Previews: PreviewProvider {
    static var testData = [
        SectionedList_TestData(section: "Section One", data: "One"),
        SectionedList_TestData(section: "Section One", data: "Two"),
        SectionedList_TestData(section: "Section One", data: "Three"),
        SectionedList_TestData(section: "Section Two", data: "One"),
        SectionedList_TestData(section: "Section Two", data: "Two"),
        SectionedList_TestData(section: "Section Two", data: "Three"),
        SectionedList_TestData(section: "Section Two", data: "Four"),
        SectionedList_TestData(section: "Section Two", data: "Five"),
        SectionedList_TestData(section: "Section Three", data: "One"),
    ]

    static var previews: some View {
        SectionedList(testData, id: \.section) { items in
            VStack(spacing: 8) {
                Text("\(items.first!.section)")
                    .font(.headline)

                ForEach(items, id: \.data) { item in
                    Text("\(item.data)")
                }
            }
        }
    }
}
#endif
