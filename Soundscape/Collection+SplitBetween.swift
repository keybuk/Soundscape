//
//  Collection+SplitBetween.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/22/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the subsequences of the collection, in order, where the subsequences are split
    /// between two elements satisfying the given predicate.
    ///
    /// Elements that are used to split the sequence are returned as the last and first elements
    /// of the subsequences either side of the split.
    ///
    /// The following example splits a sequence of integers at each point where an integer
    /// is smaller than the preceeding one:
    ///
    ///     let integers = [ 1, 2, 3, 2, 3, 4, 4, 3, 4, 5, 1, 1 ]
    ///     print(integers.split(between: { $1 < $0 }))
    ///     // Prints "[[1, 2, 3], [2, 3, 4, 4], [3, 4, 5], [1, 1]]
    ///
    /// - Parameter predicate: A predicate that returns `true` if the collection should be
    ///   split between its first and second arguments.
    /// - Returns: An array of subsequences, split from this collection's elements.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    func split(between predicate: (Element, Element) -> Bool) -> [SubSequence] {
        var parts: [SubSequence] = []

        var i = startIndex
        while i != endIndex {
            if let j = self[i...].indexOfAdjacent(where: predicate) {
                parts.append(self[i...j])
                i = index(after: j)
            } else {
                parts.append(self[i...])
                i = endIndex
            }
        }

        return parts
    }

    /// Returns the index of the first pair of adjacent collection elements matching given predicate.
    ///
    /// - Parameter predicate: A predicate that returns `true` for the matching adjacent elements.
    /// - Returns: Index in the collection where `predicate` returns `true` for the element at
    ///   that index, and its successor.
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    func indexOfAdjacent(where predicate: (Element, Element) -> Bool) -> Index? {
        return indices.first {
            let successor = index(after: $0)
            return successor != endIndex && predicate(self[$0], self[successor])
        }
    }

}
