//
//  Stage.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

struct WeakBox<T> where T: AnyObject {
    weak var value: T? = nil
}

final class Stage: ObservableObject {
    var players: [WeakBox<Player>] = []

    func playerForElement(_ element: Element, audio: AudioManager) -> Player {
        players.removeAll(where: { $0.value == nil })

        if let player = players.first(where: { $0.value?.element == element }) {
            return player.value!

        } else {
            let player = Player(element: element, audio: audio)
            players.append(WeakBox(value: player))
            return player
        }
    }
}
