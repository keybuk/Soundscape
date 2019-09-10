//
//  SyrinscapeDownloadError.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

enum SyrinscapeDownloadError: Error {
    case invalidServerResponse(URLResponse?)
    case badServerResponse(Int)
    case incorrectMimeType(String?)
    case unknownParseError
}
