//
//  CampaignsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/23/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct CampaignsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext

    var body: some View {
        List {
            NavigationLink(destination: SoundsetsView()) {
                Label("All Soundsets", systemImage: "")
            }

            CampaignList(fetchRequest: Campaign.fetchRequestSorted())

            Button(action: {
                managedObjectContext.performAndWait {
                    let _ = Campaign(context: managedObjectContext)
                }
            }) {
                Label("Add Campaign", systemImage: "plus.circle")
            }
        }
        .navigationBarTitle("Campaigns")
    }
}

#if DEBUG
struct CampaignsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                CampaignsView()
            }

            NavigationView {
                CampaignsView()
            }
            .environment(\.colorScheme, .dark)
        }
        .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
#endif

