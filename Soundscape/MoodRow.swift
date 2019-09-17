//
//  MoodRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct MoodRow: View {
    @ObservedObject var mood: Mood
    @EnvironmentObject var audio: AudioManager
    @EnvironmentObject var stage: Stage

    var body: some View {
        Button(action: playMood) {
            Text("\(mood.title!)")
        }
    }

    func playMood() {
        stage.playMood(mood, audio: audio)
    }
}

#if DEBUG
struct MoodRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewContent.soundsets[0].moods!.array as! [Mood]) { mood in
            MoodRow(mood: mood)
        }
        .environmentObject(AudioManager())
        .environmentObject(Stage())
    }
}
#endif
