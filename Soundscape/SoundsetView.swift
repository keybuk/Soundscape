//
//  SoundsetView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetView: View {
    var soundset: Soundset

    var body: some View {
        List {
            Section(header: SoundsetViewHeaderImage(image: soundset.image)) {
                EmptyView()
            }
            
            Section(header: Text("Moods").font(.headline)) {
                Text("Test")
                Text("Another Test")
            }

            Section(header: Text("Elements").font(.headline)) {
                Text("Test")
                Text("Another Test")
            }

        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("\(soundset.title!)", displayMode: .automatic)
    }
}

struct SoundsetViewHeaderImage: View {
    var image: Image

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxHeight: 240)
            .cornerRadius(8)
    }
}

#if DEBUG
struct SoundsetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SoundsetView(soundset: previewContent.soundsets[0])
        }
    }
}
#endif
