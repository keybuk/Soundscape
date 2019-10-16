//
//  MoodButton.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct MoodButton: View {
    @EnvironmentObject var stage: Stage

    var mood: Mood

    var isActive: Bool { stage.mood == mood }

    var body: some View {
        Button(action: self.play) {
            Text("\(mood.title)")
                .lineLimit(1)
                .padding()
                .foregroundColor(isActive ? Color("ActiveMoodLabelColor") : Color(UIColor.label))
                .frame(maxWidth: .infinity)
                .background(isActive ? Color("ActiveMoodBackgroundColor") : Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(8)
        }
    }

    func play() {
        stage.playMood(mood)
    }
}

#if DEBUG
struct MoodButton_Previews: PreviewProvider {
    static var previews: some View {
        MoodButton(mood: previewContent.soundsets[0].moods[0])
            .environmentObject(Stage(audio: AudioManager()))
    }
}
#endif
