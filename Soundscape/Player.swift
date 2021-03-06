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

    var nowPlaying: Playing? { playing.first { $0.stopAt == nil } }

    var isPlaying: Bool {
        nowPlaying != nil || isDownloading
    }
    var isDownloading: Bool { !downloading.isEmpty }

    var progressSubject = CurrentValueSubject<Double, Never>(0)

    struct Playing {
        var downMixer: AVAudioMixerNode?
        var player: AVAudioPlayerNode
        var length: AVAudioFramePosition
        var loop: ClosedRange<AVAudioFramePosition>?
        var delay: AVAudioFramePosition
        var stopAt: AVAudioFramePosition?

        var animations: [Animation] = []
    }

    struct Animation {
        enum Property {
            case volume(start: Float, end: Float)
            case position(startAngle: Float, startDistance: Float, endAngle: Float, endDistance: Float)
        }

        var property: Property
        var over: Range<AVAudioFramePosition>
    }

    var animations: [Animation] = []

    @Published var playing: [Playing] = []
    @Published private var downloading: [URLSessionDataTask] = []

    private var playlistIterator: Playlist.PlaylistIterator?

    private var resumeAction: (() -> Void)?

    init(playlist: Playlist, audio: AudioManager) {
        self.playlist = playlist
        self.audio = audio
        _setVolume = playlist.initialVolume
    }

    func createEnvironmentAndAttach() {
        guard environment == nil else { return }

        audio.start()

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
        guard let engine = audio.engine, !engine.isRunning else { return }

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

        let delay: Double = withStartDelay ? .random(in: playlist.startDelay) : 0
        wantFile(in: delay, isFirst: true)
    }

    func changeVolume(_ volume: Float) {
        let animatableVolumeThreshold: Float = 0.05
        let animationLength = 2

        // FIXME? This immediately changes the volume if there's nothing playing,
        // otherwise begins changing it immediately which means it's changed
        // across a download or sample delay.
        if abs(self.volume - volume) >= animatableVolumeThreshold,
            let lastRenderTime = environment?.lastRenderTime,
            let format = environment?.outputFormat(forBus: 0)
        {
            let startTime = lastRenderTime.sampleTime
            let endTime = startTime + AVAudioFramePosition(animationLength) * AVAudioFramePosition(format.sampleRate)

            animations.append(Animation(property: .volume(start: self.volume, end: volume),
                                        over: startTime..<endTime))
        } else {
            self.volume = volume
        }
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
            let angle: Float = .random(in: playlist.angle)
            let distance: Float = .random(in: playlist.distance)

            let mixing: AVAudio3DMixing = downMixer ?? player
            mixing.renderingAlgorithm = .auto
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

        player.scheduleFile(file, looping: playlist.isLooping, startHandler: {
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
                // Pause the progress updater and send one last progress update
                // before removing the last playing sample; this ensures we
                // send a 100% progress update.
                if self.playing.count == 1 {
                    self.progressUpdater.isPaused = true
                    self.sendProgressUpdate()
                }

                // Remove the playing member before detaching the player and
                // down mixer from the audio engine, this avoids the progress
                // updater (unpaused in the case of overlapping samples) trying
                // to get the lastRenderTime of a detached node.
                self.playing.removeAll { $0.player == player }
                self.audio.engine.detach(player)
                if let downMixer = downMixer { self.audio.engine.detach(downMixer) }

                // If the next sample doesn't overlap, schedule it.
                if delayBeforeNext >= 0 && !self.playlist.isOverlapping {
                    self.wantFile(in: delayBeforeNext)
                }

                // If we're not playing anything then we need to send a 0%
                // progress update, as the updater is not currently running.
                if self.nowPlaying == nil {
                    self.sendProgressUpdate()
                }
            }
        }
        player.play(at: startTime)

        // Save key values for progress calculation.
        playing.append(Playing(downMixer: downMixer, player: player, length: file.length, loop: file.loop, delay: delaySamples))
        progressUpdater.isPaused = false
    }

    func wantFile(in delay: Double, isFirst: Bool = false) {
        if playlist.kind == .oneShot && !isFirst {
            // Don't queue additional files for one shots, but keep the iterator for next time.
        } else if let playlistEntry = playlistIterator?.next() {
            // Queue up the next file.
            let sample = playlistEntry.sample!
            let volume: Float = .random(in: playlistEntry.volume)

            if sample.isCached,
                let file = try? OggVorbisFile(forReading: sample.cacheURL)
            {
                print("Playing \(sample.title!) in \(delay)s")
                self.scheduleFile(file, volume: volume, delay: delay)
            } else {
                let downloadStart = Date()
                var downloadTask: URLSessionDataTask? = nil

                print("Downloading \(sample.url!)")
                downloadTask = sample.downloadFromSyrinscape { result in
                    DispatchQueue.main.async {
                        self.downloading.removeAll { $0 == downloadTask }

                        // Subtract the amount of time the download took from the delay.
                        let downloadDuration = downloadStart.distance(to: Date())
                        let adjustedDelay = max(0, delay - downloadDuration)

                        switch result {
                        case .success:
                            let file: OggVorbisFile
                            do {
                                file = try OggVorbisFile(forReading: sample.cacheURL)
                            } catch let error {
                                print("Failed to open sample file: \(error.localizedDescription)")
                                self.wantFile(in: adjustedDelay, isFirst: isFirst)
                                return
                            }

                            print("Playing \(sample.title!) in \(adjustedDelay)s")
                            self.scheduleFile(file, volume: volume, delay: adjustedDelay)
                        case let .failure(error as NSError)
                            where error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled:
                            // Cancelled; do nothing.
                            break
                        case let .failure(error):
                            print("Failed to download sample file: \(error.localizedDescription)")
                            self.wantFile(in: adjustedDelay, isFirst: isFirst)
                        }
                    }
                }

                downloading.append(downloadTask!)
            }
        } else if playlistIterator != nil {
            // Reached the end of the playlist.
            playlistIterator = nil
        }
    }

    func stop(fadeOut: Bool = true) {
        playlistIterator = nil

        // Always cancel downloads.
        downloading.forEach { $0.cancel() }

        // Iterate over the playing elements to figure out which to stop, and
        // which to fade out.
        let fadeOutLength = 2
        let lastRenderTime = environment?.lastRenderTime
        playing = playing.map {
            if let lastRenderTime = lastRenderTime,
                let playerTime = $0.player.playerTime(forNodeTime: lastRenderTime),
                playerTime.sampleTime > 0 && fadeOut
            {
                let format = $0.player.outputFormat(forBus: 0)
                let startTime = playerTime.sampleTime
                let endTime = startTime + AVAudioFramePosition(fadeOutLength) * AVAudioFramePosition(format.sampleRate)

                var newPlaying = $0
                newPlaying.stopAt = endTime
                newPlaying.animations.append(Animation(property: .volume(start: $0.player.volume, end: 0),
                                                       over: startTime..<endTime))
                return newPlaying
            } else {
                $0.player.stop()
                return $0
            }
        }
    }

    lazy var progressUpdater: CADisplayLink = {
        let progressUpdater = CADisplayLink(target: self, selector: #selector(progressUpdate))
        progressUpdater.isPaused = true
        progressUpdater.add(to: RunLoop.main, forMode: .default)
        return progressUpdater
    }()

    @objc
    func progressUpdate() {
        sendProgressUpdate()

        guard let lastRenderTime = environment?.lastRenderTime else { return }
        for animation in animations {
            guard animation.over.contains(lastRenderTime.sampleTime) else { continue }

            let progress = Float(lastRenderTime.sampleTime - animation.over.lowerBound) / Float(animation.over.upperBound - animation.over.lowerBound)

            switch animation.property {
            case let .volume(start, end):
                volume = start + (end - start) * progress
            default:
                assertionFailure("Invalid property for environment animation: \(animation.property)")
            }
        }

        animations.removeAll { $0.over.upperBound <= lastRenderTime.sampleTime }

        for playingMember in playing {
            guard let playerTime = playingMember.player.playerTime(forNodeTime: lastRenderTime) else { continue }

            if let stopAt = playingMember.stopAt, stopAt <= playerTime.sampleTime {
                playingMember.player.stop()
            }

            for animation in playingMember.animations {
                guard animation.over.contains(playerTime.sampleTime) else { continue }

                let progress = Float(playerTime.sampleTime - animation.over.lowerBound) / Float(animation.over.upperBound - animation.over.lowerBound)

                switch animation.property {
                case let .volume(start, end):
                    playingMember.player.volume = start + (end - start) * progress
                case let .position(startAngle, startDistance, endAngle, endDistance):
                    let angle = startAngle + (endAngle - startAngle) * progress
                    let distance = startDistance + (endDistance - startDistance) * progress

                    let mixing: AVAudio3DMixing = playingMember.downMixer ?? playingMember.player
                    mixing.position = AVAudio3DPoint(x: sin(angle * .pi / 180) * distance,
                                                     y: cos(angle * .pi / 180) * distance,
                                                     z: 0)
                }
            }
        }
    }

    func sendProgressUpdate() {
        if let playingMember = nowPlaying,
            let lastRenderTime = playingMember.player.lastRenderTime,
            let playerTime = playingMember.player.playerTime(forNodeTime: lastRenderTime)
        {
            if playerTime.sampleTime < 0 {
                progressSubject.send(-Double(-playerTime.sampleTime) / Double(playingMember.delay))
            } else if playlist.isLooping, let loop = playingMember.loop {
                if playerTime.sampleTime <= loop.upperBound {
                    progressSubject.send(Double(playerTime.sampleTime) / Double(loop.upperBound))
                } else {
                    let loopTime = (playerTime.sampleTime - loop.upperBound) % loop.length
                    progressSubject.send(Double(loopTime) / Double(loop.length))
                }
            } else {
                progressSubject.send(Double(playerTime.sampleTime) / Double(playingMember.length))
            }
        } else {
            progressSubject.send(0)
        }
    }
}
