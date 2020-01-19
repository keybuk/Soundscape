//
//  HostView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct HostView: View {
    var body: some View {
        NavigationView {
            SoundsetsView()
        }
    }
}

#if DEBUG
struct HostView_Previews: PreviewProvider {
    static var previews: some View {
        HostView()
            .environmentObject(SoundsetListController())
            .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
