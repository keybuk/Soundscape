//
//  OneShotsButton.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct OneShotsButton: View {
    @EnvironmentObject var stage: Stage
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext

    @ObservedObject var soundset: Soundset

    @State var isOneShotsPresented: Bool = false

    var body: some View {
        Button(action: { self.isOneShotsPresented = true }) { Text("One Shots") }
            .sheet(isPresented: $isOneShotsPresented) {
                NavigationView {
                    OneShotsView(soundset: self.soundset)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(self.stage)
                .environment(\.managedObjectContext, self.managedObjectContext)
            }
    }
}

#if DEBUG
struct OneShotsButton_Previews: PreviewProvider {
    static var previews: some View {
        OneShotsButton(soundset: previewContent.soundsets[0])
            .environmentObject(Stage(audio: AudioManager()))
            .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif

