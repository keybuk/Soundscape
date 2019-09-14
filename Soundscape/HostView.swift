//
//  HostView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct HostView: View {
    var body: some View {
        NavigationView {
            SoundsetsList(category: .fantasy)
        }
    }
}

#if DEBUG
struct HostView_Previews: PreviewProvider {
    static var previews: some View {
        HostView()
            .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif