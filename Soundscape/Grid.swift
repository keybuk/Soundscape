//
//  Grid.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct Grid<Data, ID, Content>: View
where Data: RandomAccessCollection, ID: Hashable, Content: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    var data: Data
    var id: KeyPath<Data.Element, ID>
    var content: (Data.Element) -> Content

    // FIXME: in theory this is only used for diffing the rows, so it doesn't really matter what we put here as long as it's consistent. Verify that's actually true.
    private var chunkID: KeyPath<Data.SubSequence, ID> {
        (\Data.SubSequence.first.unsafelyUnwrapped).appending(path: id)
    }

    var compactColumns: Int
    var regularColumns: Int

    var rowSpacing: CGFloat
    var columnSpacing: CGFloat

    init(_ data: Data, id: KeyPath<Data.Element, ID>,
         compactColumns: Int = 2, regularColumns: Int = 3,
         rowSpacing: CGFloat = 8, columnSpacing: CGFloat = 8,
         @ViewBuilder content: @escaping (Data.Element) -> Content)
    {
        self.data = data
        self.id = id
        self.content = content

        self.compactColumns = compactColumns
        self.regularColumns = regularColumns

        self.rowSpacing = rowSpacing
        self.columnSpacing = columnSpacing
    }

    var body: some View {
        VStack(spacing: rowSpacing) {
            ForEach(data.chunked(into: numberOfColumns), id: chunkID) { row in
                HStack(spacing: self.columnSpacing) {
                    ForEach(row, id: self.id) { element in
                        self.content(element)
                            .frame(maxWidth: .infinity)
                    }

                    ForEach(row.count..<self.numberOfColumns, id: \.self) { _ in
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    var numberOfColumns: Int {
        horizontalSizeClass == .compact ? compactColumns : regularColumns
    }
}

extension Grid
where ID == Data.Element.ID, Data.Element: Identifiable {
    init(_ data: Data,
         compactColumns: Int = 2, regularColumns: Int = 3,
         rowSpacing: CGFloat = 8, columnSpacing: CGFloat = 8,
         @ViewBuilder content: @escaping (Data.Element) -> Content)
    {
        self.data = data
        self.id = \Data.Element.id
        self.content = content

        self.compactColumns = compactColumns
        self.regularColumns = regularColumns

        self.rowSpacing = rowSpacing
        self.columnSpacing = columnSpacing
    }
}

#if DEBUG
struct Grid_IdentifiableTest: Identifiable {
    var id: String
}

struct Grid_Previews: PreviewProvider {
    static var testData = ["One", "Two", "Three", "Four", "Five"]

    static var previews: some View {
        Group {
            ScrollView {
                Grid(testData, id: \.self) {
                    Text("\($0)")
                }
            }
            .previewDevice("iPhone 11 Pro")

            ScrollView {
                Grid(testData, id: \.self) {
                    Text("\($0)")
                }
            }
            .previewDevice("iPad Air (3rd generation)")

            ScrollView {
                Grid(testData.map { Grid_IdentifiableTest(id: $0) }) {
                    Text("\($0.id)")
                }
            }
        }
    }
}
#endif
