//
//  URL+Syrinscape.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension URL {

    func authenticatedForSyrinscape() -> URL? {
        guard
            var components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let (uuid, key) = SyrinscapeAuth.shared.getUUIDAndKey()
            else { return nil }

        components.queryItems = [
            URLQueryItem(name: "key", value: key),
            URLQueryItem(name: "uuid", value: uuid)
        ]
        return components.url
    }

}
