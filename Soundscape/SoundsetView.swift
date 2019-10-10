//
//  SoundsetView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct SoundsetView: View {
    @ObservedObject var soundset: Soundset
    @EnvironmentObject var persistentContainer: NSPersistentContainer

    var body: some View {
        List {
            Section(header: SoundsetViewHeaderImage(image: soundset.image)) {
                EmptyView()
            }

            Section(header: Text("Moods").font(.headline)) {
                ForEach(soundset.moods!.array as! [Mood]) { mood in
                    MoodRow(mood: mood)
                }
            }
            
            Section(header: Text("Elements").font(.headline)) {
                ForEach((soundset.elements!.array as! [Element]).filter({ $0.kind != .oneshot })) { element in
                    ElementRow(element: element)
                }
            }

            Section(header: Text("Sounds").font(.headline)) {
                ForEach((soundset.elements!.array as! [Element]).filter({ $0.kind == .oneshot })) { element in
                    ElementRow(element: element)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("\(soundset.title!)", displayMode: .automatic)
        .navigationBarItems(trailing: NavigationLink(destination: NowPlayingView()) { Text("Now Playing") })
        .onAppear {
            if self.soundset.isUpdatePending {
                self.soundset.updateFromServer(context: self.persistentContainer.newBackgroundContext())
            }
        }
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
        .environmentObject(previewContent.persistentContainer)
        .environmentObject(AudioManager())
        .environmentObject(Stage())
    }
}
#endif
