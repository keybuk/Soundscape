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

extension Playlist {
    var isLockable: Bool { kind == .music || kind == .musicLoop }
}

final class Stage: ObservableObject {
    private var players: [WeakBox<Player>] = []

    var audio: AudioManager
    @Published var mood: Mood? = nil

    var playlists: [Playlist] {
        players
            .compactMap { $0.value }
            .filter { $0.isPlaying }
            .map { $0.playlist }
    }

    var playlistsBySoundset: [ArraySlice<Playlist>] {
        playlists.split(between: { $0.soundset != $1.soundset })
    }

    @Published var lockedPlaylist: Playlist? = nil

    init(audio: AudioManager) {
        self.audio = audio
    }

    func playerForPlaylist(_ playlist: Playlist) -> Player {
        players.removeAll(where: { $0.value == nil })

        if let player = players.first(where: { $0.value?.playlist == playlist }) {
            return player.value!
        } else {
            defer { objectWillChange.send() }
            let player = Player(playlist: playlist, audio: audio)
            players.append(WeakBox(value: player))
            return player
        }
    }

    func playMood(_ mood: Mood) {
        // Stop any player not in the current mood.
        let playing = Set(mood.playlists.filter { $0.isPlaying }.map { $0.playlist })
        for player in players.compactMap({ $0.value }) {
            if !playing.contains(player.playlist) && lockedPlaylist != player.playlist {
                if !player.isPlaying { continue }
                player.stop()
            }
        }

        // Start the rest of the players.
        for parameters in mood.playlists {
            guard parameters.isPlaying else { continue }

            let player = playerForPlaylist(parameters.playlist)
            player.volume = parameters.volume

            if !player.isPlaying && (!player.playlist.isLockable || lockedPlaylist == nil) {
                player.play(withStartDelay: true)
            }
        }

        self.mood = mood
    }

    func stop() {
        for player in players.compactMap({ $0.value }) {
            if player.playlist == lockedPlaylist { continue }
            if !player.isPlaying { continue }
            player.stop()
        }

        mood = nil
    }
}
