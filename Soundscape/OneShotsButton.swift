//
//  OneShotsButton.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct OneShotsButton: View {
    @EnvironmentObject var stage: Stage
    @EnvironmentObject var oneShotSearchController: OneShotSearchController

    @ObservedObject var soundset: Soundset

    @State var isOneShotsPresented: Bool = false

    var body: some View {
        Button(action: { self.isOneShotsPresented = true }) { Text("One Shots") }
            .sheet(isPresented: $isOneShotsPresented) {
                NavigationView {
                    OneShotsList(soundset: self.soundset)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(self.stage)
                .environmentObject(self.oneShotSearchController)
            }
    }
}

#if DEBUG
struct OneShotsButton_Previews: PreviewProvider {
    static var previews: some View {
        OneShotsButton(soundset: previewContent.soundsets[0])
            .environmentObject(Stage(audio: AudioManager()))
            .environmentObject(OneShotSearchController(managedObjectContext: previewContent.managedObjectContext))
    }
}
#endif

