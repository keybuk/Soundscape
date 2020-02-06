//
//  NowPlayingMoodList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 2/5/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct NowPlayingMoodList: View {
    @EnvironmentObject var stage: Stage

    @FetchRequest
    var moods: FetchedResults<Mood>

    init(fetchRequest: NSFetchRequest<Mood>) {
        _moods = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        ForEach(moods) { mood in
            if self.stage.isPlayingMood(mood) {
                MoodButton(mood: mood)
            }
        }
    }
}

#if DEBUG
struct NowPlayingMoodList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                NowPlayingMoodList(fetchRequest: previewContent.soundsets[0].fetchRequestForMoods())
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .previewDevice("iPhone 11 Pro")

            ScrollView {
                NowPlayingMoodList(fetchRequest: previewContent.soundsets[0].fetchRequestForMoods())
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .previewDevice("iPad Air (3rd generation)")
        }
        .environmentObject(Stage(audio: AudioManager()))
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
