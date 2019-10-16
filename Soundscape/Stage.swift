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

    @Published var mood: Mood? = nil

    var elements: [Element] {
        players
            .compactMap { $0.value }
            .filter { if case .stopped = $0.status { return false } else { return true } }
            .map { $0.element }
    }

    @Published var lockedElement: Element? = nil

    func playerForElement(_ element: Element, audio: AudioManager) -> Player {
        players.removeAll(where: { $0.value == nil })

        if let player = players.first(where: { $0.value?.element == element }) {
            return player.value!
        } else {
            defer { objectWillChange.send() }
            let player = Player(element: element, audio: audio)
            players.append(WeakBox(value: player))
            return player
        }
    }

    func playMood(_ mood: Mood, audio: AudioManager) {
        // Stop any player not in the current mood.
        let playingElements = Set(mood.elements.filter { $0.isPlaying }.map { $0.element })
        for player in players.compactMap({ $0.value }) {
            if !playingElements.contains(player.element) && lockedElement != player.element {
                if case .stopped = player.status { continue }
                player.stop()
            }
        }

        // Start the rest of the players.
        for elementParameter in mood.elements {
            guard elementParameter.isPlaying else { continue }

            let player = playerForElement(elementParameter.element, audio: audio)
            player.volume = elementParameter.volume

            if case .stopped = player.status,
                player.element.kind != .music || lockedElement == nil

            {
                player.play(withStartDelay: true)
            }
        }

        self.mood = mood
    }

    func stop() {
        for player in players.compactMap({ $0.value }) {
            if player.element == lockedElement { continue }
            if case .stopped = player.status { continue }
            player.stop()
        }

        mood = nil
    }
}
