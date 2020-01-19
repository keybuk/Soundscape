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
            ForEach(Soundset.Category.allCases, id: \.self) { category in
                Text("\(category.description)").tag(category)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

#if DEBUG
struct SoundsetCategoryPicker_Previews: PreviewProvider {
    @State static var category: Soundset.Category = .fantasy

    static var previews: some View {
        SoundsetCategoryPicker(category: $category)
    }
}
#endif

