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

//    var groupedElements: [Soundset: [Element]] {
//        .init(grouping: stage.elements) {
//            $0.soundset!
//        }
//    }

    var body: some View {
        List {
//            ForEach(groupedElements.keys.sorted { $0.title! < $1.title! }) { soundset in
//                Section(header: Text("\(soundset.title!)")) {
//                    ForEach(self.groupedElements[soundset]!.sorted(by: { $0.kind.rawValue < $1.kind.rawValue }).filter({ $0.kind != .oneshot })) { element in

            ForEach(stage.elements.sorted(by: { $0.kind < $1.kind }).filter({ $0.kind != .oneshot })) { element in

                        if element.kind == .music {
                            HStack {
                                ElementRow(element: element)

                                if self.stage.lockedElement == element {
                                    Image(systemName: "lock")
                                        .padding()
                                        .onTapGesture {
                                            self.stage.lockedElement = nil
                                        }
                                } else {
                                    Image(systemName: "lock.open")
                                        .padding()
                                        .onTapGesture {
                                            self.stage.lockedElement = element
                                        }
                                }
                            }
                        } else {
                            ElementRow(element: element)
                        }
                    }
//                }
//            }

            AirPlayRoutePicker()
        }
        .navigationBarTitle("Now Playing")
        .navigationBarItems(trailing: Button(action: stage.stop) { Text("Stop") })
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
