//
//  SoundsetsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetsView: View {
    @State var category: Soundset.Category = .fantasy
    @State var search: String = ""

    var body: some View {
        List {
            VStack {
                SoundsetCategoryPicker(category: $category)
                SearchField(search: $search)
            }

            SoundsetList(fetchRequest: Soundset.fetchRequestSorted(category: category, matching: search))
        }
        .navigationBarTitle("Soundsets")
    }
}

#if DEBUG
struct SoundsetsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SoundsetsView()
            }

            NavigationView {
                SoundsetsView()
            }
            .environment(\.colorScheme, .dark)
        }
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
