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

    @State var search: String = ""

    var body: some View {
        List {
            VStack {
                Picker(selection: $controller.category, label: Text("Category")) {
                    ForEach(Soundset.Category.allCases, id: \.self) { category in
                        Text("\(category.description)").tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $search, onCommit: {
                        self.controller.search = self.search
                    })
                    .foregroundColor(.primary)
                    if !search.isEmpty {
                        // Not a button because we're in a List.
                        Image(systemName: "xmark.circle.fill")
                            .onTapGesture {
                                self.search = ""
                                self.controller.search = self.search
                            }
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                .foregroundColor(.secondary)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)
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
