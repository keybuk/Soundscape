//
//  SoundsetsList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetsList: View {
    @ObservedObject var soundsets: SoundsetListController

    var body: some View {
        List {
//            NavigationLink(destination: SearchResultsView(search: SearchController(search: search, context: managedObjectContext)), isActive: $isSearching) {
//                HStack {
//                    Image(systemName: "magnifyingglass")
//                    TextField("Search", text: $search, onCommit: {
//                        self.isSearching = true
//                    })
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                }
//            }

            ForEach(soundsets) { soundset in
                NavigationLink(destination: SoundsetView(soundset: soundset)) {
                    SoundsetRow(soundset: soundset)
                }
            }
        }
        .navigationBarTitle("Soundsets")
    }
}

#if DEBUG
struct SoundsetsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SoundsetsList(soundsets: SoundsetListController(managedObjectContext: previewContent.managedObjectContext))
        }
    }
}
#endif
