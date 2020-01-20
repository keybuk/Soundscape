//
//  Collection+Chunked.swift
//  Soundscape
//
//  Created by Scott James Remnant on 1/19/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Foundation

extension Collection {
    // FIXME: this is probably the least efficient way to do this.
    func chunked(into size: Int) -> [SubSequence] {
        var chunks: [SubSequence] = [], i = startIndex, j = i
        while j != endIndex {
            let _ = formIndex(&j, offsetBy: size, limitedBy: endIndex)
            chunks.append(self[i..<j])
            i = j
        }
        return chunks
    }
}
