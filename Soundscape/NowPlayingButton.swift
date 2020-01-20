//
//  NowPlayingButton.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct NowPlayingButton: View {
    @EnvironmentObject var stage: Stage

    @State var isNowPlayingPresented: Bool = false

    var body: some View {
        Button(action: { self.isNowPlayingPresented = true }) { Text("Now Playing") }
            .sheet(isPresented: $isNowPlayingPresented) {
                NavigationView {
                    NowPlayingView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(self.stage)
            }
    }
}

struct NowPlayingButton_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingButton()
            .environmentObject(Stage(audio: AudioManager()))
    }
}
