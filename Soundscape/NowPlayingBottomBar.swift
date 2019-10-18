//
//  NowPlayingBottomBar.swift
//  Soundscape
//
//  Created by Scott James Remnant on 10/17/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct NowPlayingBottomBar: View {
    var body: some View {
        AirPlayRoutePicker()
            .padding(4)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
    }
}

#if DEBUG
struct NowPlayingBottomBar_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingBottomBar()
    }
}
#endif
