//
//  CampaignRow.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/23/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct CampaignRow: View {
    @ObservedObject var campaign: Campaign

    var body: some View {
        HStack {
            Image(systemName: "flame")
            Text("\(campaign.title!)")
        }
    }
}

struct CampaignRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewContent.campaigns) { campaign in
            CampaignRow(campaign: campaign)
        }
    }
}
