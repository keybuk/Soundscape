//
//  Playlist.swift
//  PlayerTest
//
//  Created by Scott James Remnant on 9/2/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

final class Player: ObservableObject {
    var playlist: Playlist
    var audio: AudioManager
    var environment: AVAudioEnvironmentNode?
    private var dummyPlayer: AVAudioPlayerNode?

    @Published private var _setVolume: Float
    var volume: Float {
        get { environment?.volume ?? _setVolume }
        set {
            _setVolume = newValue
            environment?.volume = _setVolume
        }
    }

    @Published var isPlaying: Bool = false
    @Published var isDownloading: Bool = false

    var progressSubject = CurrentValueSubject<Double, Never>(0)

    struct Playing {
        var downMixer: AVAudioMixerNode?
        var player: AVAudioPlayerNode
        var length: AVAudioFramePosition
        var delay: AVAudioFramePosition

        var changes: [LinearChange] = []
    }

    enum Property {
        case volume
        case pan
    }

    struct LinearChange {
        // FIXME: ReferenceWritableKeyPath<Player.Playing, Float>
        var property: Property
        var over: Range<AVAudioFramePosition>
        var startValue: Float
        var endValue: Float
    }

    var playing: [Playing] = []

    private var playlistIterator: Playlist.PlaylistIterator?

    private var resumeAction: (() -> Void)?

    init(playlist: Playlist, audio: AudioManager) {
        self.playlist = playlist
        self.audio = audio
        _setVolume = playlist.initialVolume
    }

    func createEnvironmentAndAttach() {
        guard environment == nil else { return }

        NotificationCenter.default.addObserver(forName: AudioManager.configurationChangeNotification,
                                               object: audio, queue: nil, using: configurationChange)
        NotificationCenter.default.addObserver(forName: AudioManager.engineResetNotification,
                                               object: audio, queue: nil, using: engineReset)

        environment = AVAudioEnvironmentNode()
        environment!.volume = _setVolume
        environment!.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment!.listenerAngularOrientation = AVAudio3DAngularOrientation(yaw: 0, pitch: 0, roll: 0)
        // TODO: reverb

        audio.engine.attach(environment!)

        dummyPlayer = AVAudioPlayerNode()
        audio.engine.attach(dummyPlayer!)

        connectEnvironment()
    }

    func connectEnvironment() {
        guard let environment = environment else { return }

        let mainMixer = audio.engine.mainMixerNode
        audio.engine.connect(environment, to: mainMixer,
                             fromBus: 0, toBus: mainMixer.nextAvailableInputBus,
                             format: mainMixer.outputFormat(forBus: 0))

        // nextAvailableInputBus ignores connected mixers without players attached
        audio.engine.connect(dummyPlayer!, to: environment,
                             fromBus: 0, toBus: environment.nextAvailableInputBus,
                             format: mainMixer.outputFormat(forBus: 0))
    }

    func configurationChange(_ notification: Notification) {
        // This is not called on the main thread.
        guard let _ = environment else { return }

        connectEnvironment()

        if let resumeAction = resumeAction {
            self.resumeAction = nil

            startEngine()
            // Normally we schedule on the main queue, but we don't access anything from Core Data
            // here so this is fine.
            resumeAction()
        }
    }

    func engineReset(_ notification: Notification) {
        // This is not called on the main thread.
        guard let _ = environment else { return }

        environment = nil
        dummyPlayer = nil
        createEnvironmentAndAttach()

        if let resumeAction = resumeAction {
            self.resumeAction = nil

            startEngine()
            // Normally we schedule on the main queue, but we don't access anything from Core Data
            // here so this is fine.
            resumeAction()
        }
    }

    func startEngine() {
        guard !audio.engine.isRunning else { return }

        do {
            try audio.engine.start()
        } catch let error {
            print("Engine failed to start: \(error.localizedDescription)")
        }
    }

    func play(withStartDelay: Bool = false) {
        createEnvironmentAndAttach()
        startEngine()

        if playlistIterator == nil {
            playlistIterator = playlist.makePlaylistIterator()
        }

        let delay = withStartDelay ? .random(in: playlist.startDelay) : 0
        wantFile(in: delay, isFirst: true)
    }

    func scheduleFile(_ file: OggVorbisFile, volume: Float, delay: Double) {
        guard let environment = environment else { preconditionFailure("Scheduled sample without environment") }

        let player = AVAudioPlayerNode()
        audio.engine.attach(player)

        // If we're doing 3D Positioning we use a mixer after the player to down-mix the file
        // to mono so it can be positioned. A separate mixer per file is required since the position
        // applies to the input of the environment, ie. the mixer.
        let downMixer: AVAudioMixerNode?
        if playlist.is3D && file.processingFormat.channelCount > 1 {
            let outputFormat = AVAudioFormat(commonFormat: file.processingFormat.commonFormat,
                                             sampleRate: file.processingFormat.sampleRate,
                                             channels: 1, interleaved: false)

            downMixer = AVAudioMixerNode()
            audio.engine.attach(downMixer!)

            audio.engine.connect(player, to: downMixer!,
                                 fromBus: 0, toBus: downMixer!.nextAvailableInputBus,
                                 format: file.processingFormat)
            audio.engine.connect(downMixer!, to: environment,
                                 fromBus: 0, toBus: environment.nextAvailableInputBus,
                                 format: outputFormat)
        } else {
            downMixer = nil

            audio.engine.connect(player, to: environment,
                                 fromBus: 0, toBus: environment.nextAvailableInputBus,
                                 format: file.processingFormat)
        }

        player.volume = volume

        if playlist.is3D {
            let angle = Float.random(in: playlist.angle)
            let distance = Float.random(in: playlist.distance)

            let mixing: AVAudio3DMixing = downMixer ?? player
            mixing.position = AVAudio3DPoint(x: sin(angle * .pi / 180) * distance,
                                             y: cos(angle * .pi / 180) * distance,
                                             z: 0)
        }

        guard let lastRenderSampleTime = player.lastRenderTime?.sampleTime else {
            // Engine is unexpectedly not available, likely due to an in-progress configuration
            // change, or reset. Set an action to retry playing this file when engine is restored.
            assert(resumeAction == nil, "Unexpectedly backed up multiple resume actions")

            let unavailableStart = Date()
            resumeAction = {
                // Subtract the amount of time the reset took from the delay.
                let unavailableDuration = unavailableStart.distance(to: Date())
                let adjustedDelay = max(0, delay - unavailableDuration)

                self.scheduleFile(file, volume: volume, delay: adjustedDelay)
            }

            print("Engine not available!")
            audio.engine.detach(player)
            if let downMixer = downMixer { audio.engine.detach(downMixer) }
            return
        }

        // Calculate the play time of this sample based on the delay given.
        let sampleRate = file.processingFormat.sampleRate
        let delaySamples = AVAudioFramePosition(delay * sampleRate)
        let startTime = AVAudioTime(sampleTime: lastRenderSampleTime + delaySamples, atRate: sampleRate)

        // Calculate the delay for the next sample.
        let delayBeforeNext: Double = .random(in: playlist.sampleGap)

        player.scheduleFile(file, startHandler: {
            DispatchQueue.main.async {
                // If the next sample overlaps, we have to schedule it as soon we're playing the
                // current sample. We add the sample length to the delay to obtain the play time
                // from the current start. For overlapping samples we always treat the delay as
                // based from the start time.
                if delayBeforeNext < 0 {
                    let adjustedDelay = delayBeforeNext + Double(file.length) / file.processingFormat.sampleRate
                    self.wantFile(in: adjustedDelay)
                } else if self.playlist.isOverlapping {
                    self.wantFile(in: delayBeforeNext)
                }
            }
        }) {
            DispatchQueue.main.async {
                self.audio.engine.detach(player)
                if let downMixer = downMixer { self.audio.engine.detach(downMixer) }
                self.playing = self.playing.filter({ $0.player != player })

                // If the next sample doesn't overlap, schedule it.
                if delayBeforeNext >= 0 && !self.playlist.isOverlapping {
                    self.wantFile(in: delayBeforeNext)
                }
            }
        }
        player.play(at: startTime)

        // Save key values for progress calculation.
        playing.append(Playing(downMixer: downMixer, player: player, length: file.length, delay: delaySamples))
        progressUpdater.isPaused = false
    }

    func wantFile(in delay: Double, isFirst: Bool = false) {
        if playlist.kind == .oneshot && !isFirst {
            // Don't queue additional files for oneshots, but keep the iterator for next time.
            progressUpdater.isPaused = true
            updateStatus()
        } else if let playlistEntry = playlistIterator?.next() {
            // Queue up the next file.
            print("Want next file in \(delay)s")
            updateStatus()

            let sample = playlistEntry.sample
            let volume = Float.random(in: playlistEntry.volume)
            let downloadStart = Date()

            sample.openFile(downloadingHandler: {
                isDownloading = true
                updateStatus()
            }) { result in
                // Subtract the amount of time the potential download took from the delay.
                let downloadDuration = downloadStart.distance(to: Date())
                let adjustedDelay = max(0, delay - downloadDuration)

                switch result {
                case let .success(file):
                    print("Playing \(sample.title) in \(adjustedDelay)s")
                    self.isDownloading = false
                    self.scheduleFile(file, volume: volume, delay: adjustedDelay)
                case let .failure(error):
                    print("Failed to open sample file: \(error.localizedDescription)")
                    self.wantFile(in: adjustedDelay, isFirst: isFirst)
                }
            }
        } else {
            // Reached the end of the playlist.
            playlistIterator = nil
            progressUpdater.isPaused = true
            updateStatus()
        }
    }

    func stop() {
        playlistIterator = nil

        for playingMember in self.playing {
            playingMember.player.stop()
        }
        self.playing.removeAll()
    }

    lazy var progressUpdater: CADisplayLink = {
        let progressUpdater = CADisplayLink(target: self, selector: #selector(progressUpdate))
        progressUpdater.add(to: RunLoop.main, forMode: .default)
        progressUpdater.isPaused = true
        return progressUpdater
    }()

    @objc
    func progressUpdate() {
        for playingMember in playing {
            guard let lastRenderTime = playingMember.player.lastRenderTime,
                let playerTime = playingMember.player.playerTime(forNodeTime: lastRenderTime) else { continue }

            for change in playingMember.changes {
                guard change.over.contains(playerTime.sampleTime) else { continue }

                let progress = Float(playerTime.sampleTime - change.over.lowerBound) / Float(change.over.upperBound - change.over.lowerBound)
                let value = change.startValue + (change.endValue - change.startValue) * progress

                switch change.property {
                case .volume: playingMember.player.volume = value
                case .pan: playingMember.player.pan = value
                }
            }
        }

        updateStatus()
    }

    func updateStatus() {
        if let playingMember = playing.first,
            let lastRenderTime = playingMember.player.lastRenderTime,
            let playerTime = playingMember.player.playerTime(forNodeTime: lastRenderTime)
        {
            // Current player means we're playing, or have a sample queued. Be careful not to push an update.
            if !isPlaying { isPlaying = true }

            if playerTime.sampleTime < 0 {
                progressSubject.send(-Double(-playerTime.sampleTime) / Double(playingMember.delay))
            } else {
                progressSubject.send(Double(playerTime.sampleTime) / Double(playingMember.length))
            }
        } else if isDownloading {
            // Still downloading the next file.
            progressSubject.send(0)
        } else {
            // No iterator means we're stopped.
            isPlaying = false
            progressSubject.send(0)
        }
    }
}
