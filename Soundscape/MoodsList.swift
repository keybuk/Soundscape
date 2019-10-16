//
//  MoodsList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/12/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

extension Array {
    func chunked(into size: Int) -> [SubSequence] {
        stride(from: startIndex, to: endIndex, by: size).map {
            self[$0..<(index($0, offsetBy: size, limitedBy: endIndex) ?? endIndex)]
        }
    }
}

struct MoodsList: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    var moods: [Mood]
    
    var numberOfColumns: Int { horizontalSizeClass == .compact ? 1 : 2 }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(moods.chunked(into: numberOfColumns), id: \.self) { moodRow in
                HStack(spacing: 8) {
                    ForEach(moodRow) { mood in
                        MoodButton(mood: mood)
                    }

                    if moodRow.count != self.numberOfColumns {
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct MoodsList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                MoodsList(moods: previewContent.soundsets[0].moods!.array as! [Mood])
            }
            .background(Color(UIColor.systemGroupedBackground))
            .previewDevice("iPhone 11 Pro")

            ScrollView {
                MoodsList(moods: previewContent.soundsets[0].moods!.array as! [Mood])
            }
            .background(Color(UIColor.systemGroupedBackground))
            .colorScheme(.dark)
            .previewDevice("iPhone 11 Pro")

            ScrollView {
                MoodsList(moods: previewContent.soundsets[0].moods!.array as! [Mood])
            }
            .background(Color(UIColor.systemGroupedBackground))
            .previewDevice("iPad Air (3rd generation)")
        }
        .environmentObject(AudioManager())
        .environmentObject(Stage())
    }
}
#endif
