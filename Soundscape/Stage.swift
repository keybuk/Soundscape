//
//  Stage.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import Combine

final class Stage: ObservableObject {
    struct StagePlayer {
        weak var player: Player? = nil
        var subscriber: AnyCancellable? = nil
    }

    private var players: [StagePlayer] = []

    var audio: AudioManager

    var playlists: [Playlist] {
        players
            .filter { $0.player?.isPlaying ?? false }
            .compactMap { $0.player?.playlist }
            .sorted {
                if $0.soundset != $1.soundset {
                    return $0.soundset!.title! < $1.soundset!.title!
                } else {
                    return $0.kind < $1.kind
                }
        }
    }

    init(audio: AudioManager) {
        self.audio = audio
    }

    func playerForPlaylist(_ playlist: Playlist) -> Player {
        playerForPlaylist(playlist, creating: true)!
    }

    func playerForPlaylist(_ playlist: Playlist, creating: Bool) -> Player? {
        players.removeAll(where: { $0.player == nil })

        if let stagePlayer = players.first(where: { $0.player?.playlist == playlist }) {
            return stagePlayer.player!
        } else if (creating) {
            objectWillChange.send()
            let player = Player(playlist: playlist, audio: audio)

            var stagePlayer = StagePlayer()
            stagePlayer.player = player
            stagePlayer.subscriber = player.objectWillChange.sink {
                self.objectWillChange.send()
            }
            players.append(stagePlayer)
            return player
        } else {
            return nil
        }
    }

    func playMood(_ mood: Mood) {
        let moodParameters = mood.playlists! as! Set<PlaylistParameter>
        for parameters in moodParameters {
            if let player = playerForPlaylist(parameters.playlist!, creating: parameters.isPlaying) {
                if parameters.isPlaying {
                    player.play(withStartDelay: true)
                } else {
                    player.stop(fadeOut: true)
                }
            }
        }
    }

    func stopMood(_ mood: Mood) {
        let moodParameters = mood.playlists! as! Set<PlaylistParameter>
        for parameters in moodParameters {
            if let player = playerForPlaylist(parameters.playlist!, creating: false) {
                if parameters.isPlaying {
                    player.stop(fadeOut: true)
                }
            }
        }
    }

    func isPlayingMood(_ mood: Mood) -> Bool {
        let playingPlaylists = Set(players.filter { $0.player?.isPlaying ?? false }.compactMap { $0.player?.playlist })
        let moodPlaylists = Set(mood.playlists! as! Set<PlaylistParameter>)

        // If any playlists the mood wants stopped are playing, the mood is not playing.
        let stopPlaylists = Set(moodPlaylists.filter { !$0.isPlaying }.map { $0.playlist! })
        if !stopPlaylists.isDisjoint(with: playingPlaylists) {
            return false
        }

        // Otherwise filter the set of playing playlists by those that are always playing, and
        // if those are all still playing the moood is playing.
        let playPlaylists = Set(moodPlaylists
            .filter { $0.isPlaying }
            .map { $0.playlist! }
            .filter { $0.isRepeating || $0.kind != .oneShot })
        if playPlaylists.isSubset(of: playingPlaylists) {
            return true
        } else {
            return false
        }
    }

    func stop() {
        let nowPlaying = players
            .compactMap({ $0.player })
            .filter { $0.isPlaying }

        for player in nowPlaying {
            player.stop(fadeOut: true)
        }
    }
}
