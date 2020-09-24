//
//  CampaignRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/23/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, _ defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                source.wrappedValue = newValue
        })
    }
}

struct CampaignRow: View {
    @ObservedObject var campaign: Campaign

    var body: some View {
        if campaign.isInserted {
            TextField("Title", text: Binding($campaign.title, ""), onCommit:  {
                campaign.managedObjectContext!.performAndWait {
                    try! campaign.managedObjectContext!.save()
                }
            })
        } else {
            Label("\(campaign.title!)", systemImage: "flame")
        }
    }
}

#if DEBUG
struct CampaignRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewContent.campaigns) { campaign in
            CampaignRow(campaign: campaign)
        }
    }
}
#endif

