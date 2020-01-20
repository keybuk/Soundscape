//
//  SoundsetCategoryPicker.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/18/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import SwiftUI

struct SoundsetCategoryPicker: View {
    @Binding var category: Soundset.Category

    var body: some View {
        Picker(selection: $category, label: Text("Category")) {
            ForEach(Soundset.Category.allCases) { categoryCase in
                Text("\(categoryCase.description)")
                    .tag(categoryCase)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

#if DEBUG
struct SoundsetCategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        SoundsetCategoryPicker(category: .constant(.fantasy))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

