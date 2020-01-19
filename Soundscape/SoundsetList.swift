//
//  SoundsetList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct SoundsetList: View {
    @FetchRequest
    var soundsets: FetchedResults<Soundset>

    init(fetchRequest: NSFetchRequest<Soundset>) {
        _soundsets = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        ForEach(soundsets) { soundset in
            NavigationLink(destination: SoundsetView(soundset: soundset)) {
                SoundsetRow(soundset: soundset)
            }
        }
    }
}

#if DEBUG
struct SoundsetList_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SoundsetList(fetchRequest:
                Soundset.fetchRequestSorted())
                .environment(\.managedObjectContext, previewContent.managedObjectContext)
        }
    }
}
#endif
