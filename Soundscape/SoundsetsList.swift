//
//  SoundsetsList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetsList: View {
    var category: SoundsetCategory

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Soundset.title, ascending: true)], predicate: NSPredicate(format: "categoryRawValue == %d", SoundsetCategory.fantasy.rawValue))
    var soundsets: FetchedResults<Soundset>

    var body: some View {
        List(soundsets) { soundset in
            NavigationLink(destination: SoundsetView(soundset: soundset)) {
                SoundsetRow(soundset: soundset)
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
