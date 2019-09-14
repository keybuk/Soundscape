//
//  AirPlayRoutePicker.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import SwiftUI
import AVKit

struct AirPlayRoutePicker: UIViewRepresentable {
    var routeDetector = AVRouteDetector()

    func makeUIView(context: UIViewRepresentableContext<AirPlayRoutePicker>) -> AVRoutePickerView {
        return AVRoutePickerView()
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: UIViewRepresentableContext<AirPlayRoutePicker>) {
        routeDetector.isRouteDetectionEnabled = true
    }
}

#if DEBUG
struct AirPlayRoutePicker_Previews: PreviewProvider {
    static var previews: some View {
        AirPlayRoutePicker()
    }
}
#endif

