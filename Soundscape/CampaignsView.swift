//
//  CampaignsView.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/23/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct CampaignsView: View {
    var body: some View {
        List {
            CampaignList(fetchRequest: Campaign.fetchRequestSorted())
        }
        .navigationBarTitle("Campaigns")
        .listStyle(SidebarListStyle())
    }
}

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
