//
//  CampaignList.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/23/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct CampaignList: View {
    @FetchRequest
    var campaigns: FetchedResults<Campaign>

    init(fetchRequest: NSFetchRequest<Campaign>) {
        _campaigns = FetchRequest(fetchRequest: fetchRequest)
    }

    var body: some View {
        ForEach(campaigns) { campaign in
            NavigationLink(destination: Text("\(campaign.title!)")) {
                CampaignRow(campaign: campaign)
            }
        }
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CampaignList(fetchRequest:
                Campaign.fetchRequestSorted())
                .environment(\.managedObjectContext, previewContent.managedObjectContext)
        }
    }
}
