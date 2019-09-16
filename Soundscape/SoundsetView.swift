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
    @EnvironmentObject var audio: AudioManager

    var body: some View {
        List {
            Section(header: SoundsetViewHeaderImage(image: soundset.image)) {
                EmptyView()
            }

            Section(header: Text("Moods").font(.headline)) {
                ForEach(soundset.moods!.array as! [Mood]) { mood in
                    Text("\(mood.title!)")
                }
            }
            
            Section(header: Text("Elements").font(.headline)) {
                ForEach((soundset.elements!.array as! [Element]).filter({ $0.kind != .oneshot })) { element in
                    PlayerView(player: Player(element: element, audio: self.audio))
                }
            }

            Section(header: Text("Sounds").font(.headline)) {
                ForEach((soundset.elements!.array as! [Element]).filter({ $0.kind == .oneshot })) { element in
                    PlayerView(player: Player(element: element, audio: self.audio))
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("\(soundset.title!)", displayMode: .automatic)
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
    }
}
#endif
