//
//  SoundsetsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/11/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetsView: View {
    @EnvironmentObject var controller: SoundsetListController

    var body: some View {
        List {
            VStack {
                SoundsetCategoryPicker(category: $controller.category)
                SearchField(search: $controller.search)
            }

            SoundsetList(fetchRequest: controller.fetchRequest)
        }
        .navigationBarTitle("Soundsets")
    }
}

#if DEBUG
struct SoundsetsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SoundsetsView()
            }

            NavigationView {
                SoundsetsView()
            }
            .environment(\.colorScheme, .dark)
        }
        .environmentObject(SoundsetListController())
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif
