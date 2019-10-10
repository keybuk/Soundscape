//
//  NowPlayingView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var stage: Stage

    var groupedElements: [Soundset: [Element]] {
        .init(grouping: stage.elements) {
            $0.soundset!
        }
    }

    var body: some View {
        List {
            ForEach(groupedElements.keys.sorted { $0.title! < $1.title! }) { soundset in
                Section(header: Text("\(soundset.title!)")) {
                    ForEach(self.groupedElements[soundset]!.sorted(by: { $0.kind.rawValue < $1.kind.rawValue }).filter({ $0.kind != .oneshot })) { element in
                        ElementRow(element: element)
                    }
                }
            }

            AirPlayRoutePicker()
        }
        .navigationBarTitle("Now Playing")
    }
}

#if DEBUG
struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NowPlayingView()
        }
        .environmentObject(Stage())
    }
}
#endif
