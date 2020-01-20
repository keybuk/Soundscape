//
//  MoodGrid.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct MoodGrid: View {
    @FetchRequest
    var moods: FetchedResults<Mood>

    init(fetchRequest: NSFetchRequest<Mood>) {
        _moods = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        Grid(moods, compactColumns: 1, regularColumns: 2) { mood in
            MoodButton(mood: mood)
        }
    }
}

#if DEBUG
struct MoodGrid_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                MoodGrid(fetchRequest: previewContent.soundsets[0].fetchRequestForMoods())
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .previewDevice("iPhone 11 Pro")

            ScrollView {
                MoodGrid(fetchRequest: previewContent.soundsets[0].fetchRequestForMoods())
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
