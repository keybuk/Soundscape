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
    private var players: [WeakBox<Player>] = []

    var elements: [Element] { players.compactMap { $0.value?.element } }

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

    func playMood(_ mood: Mood, audio: AudioManager) {
        let elementParameters = mood.elementParameters! as! Set<ElementParameter>
        let playingElementParameters = elementParameters.filter({ $0.isPlaying })
        let playingElements = playingElementParameters.map({ $0.element! })

        // Stop any player not in the current mood.
        for player in players.compactMap({ $0.value }) {
            if !playingElements.contains(player.element) {
                if case .stopped = player.status.value { continue }
                player.stop()
            }
        }

        // Start the rest of the players.
        for elementParameter in playingElementParameters {
            let player = playerForElement(elementParameter.element!, audio: audio)
            player.volume = elementParameter.volume

            if case .stopped = player.status.value {
                player.play(withStartDelay: true)
            }
        }
    }
}
