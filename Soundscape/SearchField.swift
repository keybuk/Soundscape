//
//  SearchField.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SearchField: View {
    @Binding var search: String
    @Binding var isSearching: Bool

    @State var searchText: String

    init(search: Binding<String>, isSearching: Binding<Bool>? = nil) {
        _search = search
        _isSearching = isSearching ?? .constant(false)

        _searchText = State(initialValue: search.wrappedValue)
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchText,
                      onEditingChanged: { _ in self.isSearching = true },
                      onCommit: { self.search = self.searchText })
                .foregroundColor(.primary)
            if !search.isEmpty {
                // Not a button in case we're in a List.
                Image(systemName: "xmark.circle.fill")
                    .onTapGesture {
                        self.searchText = ""
                        self.search = self.searchText
                    }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
    }
}

#if DEBUG
struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchField(search: .constant(""))
            SearchField(search: .constant("Foo"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
