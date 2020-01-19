//
//  SoundsetsList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetsList: View {
    @EnvironmentObject var controller: SoundsetListController

    var body: some View {
        List {
            VStack {
                Picker(selection: $controller.category, label: Text("Category")) {
                    ForEach(Soundset.Category.allCases, id: \.self) { category in
                        Text("\(category.description)").tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                SearchField(search: $controller.search)
            }

            ForEach(controller.soundsets) { soundset in
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
            SoundsetsList()
                .environmentObject(SoundsetListController(managedObjectContext: previewContent.managedObjectContext))
        }
    }
}
#endif
