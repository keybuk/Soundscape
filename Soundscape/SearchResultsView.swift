//
//  SearchResultsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/20/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var search: SearchController

    var body: some View {
        List {
            Section(header: Text("Soundsets")
                .font(.title)
                .fontWeight(.bold))
            {
                ForEach(search.soundsets) { soundset in
                    SoundsetRow(soundset: soundset)
                }
            }

            Section(header: Text("Moods")
                .font(.title)
                .fontWeight(.bold))
            {
                ForEach(search.moods) { mood in
                    MoodRow(mood: mood)
                }
            }

            Section(header: Text("Elements")
                .font(.title)
                .fontWeight(.bold))
            {
                ForEach(search.elements) { element in
                    ElementRow(element: element)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Search results")
    }
}

#if DEBUG
struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SearchResultsView(search: SearchController(search: "battle", context: previewContent.managedObjectContext))
        }
    }
}
#endif
