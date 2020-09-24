//
//  CampaignsButton.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/23/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI
import CoreData

struct CampaignsButton: View {
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext

    @FetchRequest(fetchRequest: Campaign.fetchRequestSorted())
    var campaigns: FetchedResults<Campaign>

    @ObservedObject var soundset: Soundset

    var body: some View {
        Menu {
            ForEach(campaigns) { campaign in
                if soundset.campaigns!.contains(campaign) {
                    Button(action: {
                        managedObjectContext.performAndWait {
                            soundset.removeFromCampaigns(campaign)
                            try! managedObjectContext.save()
                        }
                    }, label: {
                        HStack {
                            Text("\(campaign.title!)")
                            Image(systemName: "checkmark")
                        }
                    })
                } else {
                    Button(action: {
                        managedObjectContext.performAndWait {
                            soundset.addToCampaigns(campaign)
                            try! managedObjectContext.save()
                        }
                    }, label: {
                        Text("\(campaign.title!)")
                    })
                }
            }
        } label: {
            Text("Campaigns")
        }
    }
}

struct CampaignsButton_Previews: PreviewProvider {
    static var previews: some View {
        CampaignsButton(soundset: previewContent.soundsets[0])
            .environment(\.managedObjectContext, previewContent.managedObjectContext)
    }
}
