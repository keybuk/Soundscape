//
//  SoundsetsList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct SoundsetsList: View {
    var category: SoundsetCategory

    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    @State var search: String = ""
    @State var isSearching: Bool = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Soundset.title, ascending: true)], predicate: NSPredicate(format: "categoryRawValue == %d", SoundsetCategory.fantasy.rawValue))
    var soundsets: FetchedResults<Soundset>

    var body: some View {
        List {
            NavigationLink(destination: SearchResultsView(search: SearchController(search: search, context: managedObjectContext)), isActive: $isSearching) {
                TextField("Search", text: $search, onCommit: {
                    self.isSearching = true
                })
            }
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
            SoundsetsList(category: .fantasy)
        }
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
