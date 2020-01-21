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

    var showCancelButton: Bool

    @State var searchText: String = ""

    init(search: Binding<String>, isSearching: Binding<Bool>? = nil) {
        _search = search
        _isSearching = isSearching ?? .constant(false)
        showCancelButton = isSearching != nil

        _searchText = State(initialValue: search.wrappedValue)
    }

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("Search", text: $searchText,
                          onEditingChanged: textFieldEditingChanged,
                          onCommit: textFieldCommit)
                    .foregroundColor(.primary)

                if !search.isEmpty {
                    // Not a button in case we're in a List.
                    Image(systemName: "xmark.circle.fill")
                        .onTapGesture(perform: clearSearch)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)

            if isSearching && showCancelButton {
                Button("Cancel", action: cancelSearch)
            }
        }
    }

    func textFieldEditingChanged(_ isEditing: Bool) {
        if isEditing {
            isSearching = true
        }
    }

    func textFieldCommit() {
        search = searchText
    }

    func clearSearch() {
        searchText = ""
        search = searchText
    }

    func cancelSearch() {
        UIApplication.shared.endEditing(force: true)
        isSearching = false
        clearSearch()
    }
}

extension UIApplication {
    func endEditing(force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

#if DEBUG
struct SearchField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchField(search: .constant(""))
            SearchField(search: .constant("Foo"))
            SearchField(search: .constant("Bar"), isSearching: .constant(true))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
