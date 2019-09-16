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
    var element: Element
    var audio: AudioManager
    var mixer: AVAudioMixerNode?

    @Published private var _setVolume: Float
    var volume: Float {
        get { mixer?.volume ?? _setVolume }
        set {
            _setVolume = newValue
            mixer?.volume = _setVolume
        }
    }

    enum Status {
        case stopped
        case waiting(Double)
        case playing(Double)
    }

    var status = CurrentValueSubject<Status, Never>(.stopped)

    private var playlistIterator: Element.PlaylistIterator?

    private var currentPlayer: AVAudioPlayerNode?
    private var currentSampleLength: AVAudioFramePosition?
    private var currentDelay: AVAudioFramePosition?

    private var resumeAction: (() -> Void)?

    init(element: Element, audio: AudioManager) {
        self.element = element
        self.audio = audio
        _setVolume = element.initialVolume
    }

    func createMixerAndAttach() {
        guard mixer == nil else { return }

        NotificationCenter.default.addObserver(forName: AudioManager.configurationChangeNotification,
                                               object: audio, queue: nil, using: configurationChange)
        NotificationCenter.default.addObserver(forName: AudioManager.engineResetNotification,
                                               object: audio, queue: nil, using: engineReset)

        mixer = AVAudioMixerNode()
        mixer!.volume = _setVolume
        // TODO: reverb

        audio.engine.attach(mixer!)
        connectMixer()
    }

    func connectMixer() {
        guard let mixer = mixer else { return }

        let mainMixer = audio.engine.mainMixerNode
        audio.engine.connect(mixer, to: mainMixer,
                             fromBus: 0, toBus: mainMixer.nextAvailableInputBus,
                             format: mainMixer.outputFormat(forBus: 0))
    }

    func configurationChange(_ notification: Notification) {
        // This is not called on the main thread.
        guard let _ = mixer else { return }

        connectMixer()

        if let resumeAction = resumeAction {
            self.resumeAction = nil

            startEngine()
            resumeAction()
        }
    }

    func engineReset(_ notification: Notification) {
        // This is not called on the main thread.
        guard let _ = mixer else { return }

        mixer = nil
        createMixerAndAttach()

        if let resumeAction = resumeAction {
            self.resumeAction = nil

            startEngine()
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
        createMixerAndAttach()
        startEngine()

        if playlistIterator == nil {
            playlistIterator = element.makePlaylistIterator()
        }

        let delay = withStartDelay ? .random(in: element.startDelay) : 0
        wantFile(in: delay, isFirst: true)
    }

    func scheduleFile(_ file: OggVorbisFile, volume: Float, delay: Double) {
        guard let mixer = mixer else { preconditionFailure("Scheduled sample without mixer") }

        let player = AVAudioPlayerNode()
        let bus = mixer.nextAvailableInputBus
        player.volume = volume
        audio.engine.attach(player)
        audio.engine.connect(player, to: mixer, fromBus: 0, toBus: bus, format: file.processingFormat)

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
            return
        }

        // Calculate the play time of this sample based on the delay given.
        let sampleRate = player.outputFormat(forBus: 0).sampleRate
        let delaySamples = AVAudioFramePosition(delay * sampleRate)
        let startTime = AVAudioTime(sampleTime: lastRenderSampleTime + delaySamples, atRate: sampleRate)

        // Calculate the delay for the next sample.
        var delayBeforeNext: Double = .random(in: element.sampleGap)

        player.scheduleFile(file, startHandler: {
            DispatchQueue.main.async {
                // If the next sample overlaps, we have to schedule it as soon we're playing the
                // current sample. We add the sample length to the delay to obtain the play time
                // from the current start. For overlapping samples we always treat the delay as
                // based from the start time.
                if delayBeforeNext < 0 {
                    delayBeforeNext += Double(file.length) / file.processingFormat.sampleRate
                    self.wantFile(in: delayBeforeNext)
                } else if self.element.isOverlapping {
                    self.wantFile(in: delayBeforeNext)
                }
            }
        }) {
            DispatchQueue.main.async {
                self.audio.engine.detach(player)
                if self.currentPlayer == player { self.currentPlayer = nil }

                // If the next sample doesn't overlap, schedule it.
                if delayBeforeNext >= 0 && !self.element.isOverlapping {
                    self.wantFile(in: delayBeforeNext)
                }
            }
        }
        player.play(at: startTime)

        // Save key values for progress calculation.
        currentPlayer = player
        currentSampleLength = file.length
        currentDelay = delaySamples
        progressUpdater.isPaused = false
    }

    func wantFile(in delay: Double, isFirst: Bool = false) {
        if element.kind == .oneshot && !isFirst {
            // Don't queue additional files for oneshot elements, but keep the iterator for next time.
            progressUpdater.isPaused = true
            status.send(.stopped)
        } else if let playlistEntry = playlistIterator?.next() {
            // Queue up the next file.
            print("Want next file in \(delay)s")

            let volume = Float.random(in: playlistEntry.volume)
            let downloadStart = Date()

            playlistEntry.openFile { result in
                // Subtract the amount of time the potential download took from the delay.
                let downloadDuration = downloadStart.distance(to: Date())
                let adjustedDelay = max(0, delay - downloadDuration)

                switch result {
                case let .success(file):
                    print("Playing \(playlistEntry.sample!.title!) in \(adjustedDelay)s")
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
            status.send(.stopped)
        }
    }

    func stop() {
        playlistIterator = nil
        if let currentPlayer = currentPlayer {
            currentPlayer.stop()
        }
    }

    lazy var progressUpdater: CADisplayLink = {
        let progressUpdater = CADisplayLink(target: self, selector: #selector(publishProgress))
        progressUpdater.add(to: RunLoop.main, forMode: .default)
        progressUpdater.isPaused = true
        return progressUpdater
    }()

    @objc
    func publishProgress() {
        guard let currentPlayer = currentPlayer,
            let lastRenderTime = currentPlayer.lastRenderTime,
            let playerTime = currentPlayer.playerTime(forNodeTime: lastRenderTime),
            let currentSampleLength = currentSampleLength,
            let currentDelay = currentDelay
            else { return }

        if playerTime.sampleTime < 0 {
            status.send(.waiting(Double(-playerTime.sampleTime) / Double(currentDelay)))
        } else {
            status.send(.playing(Double(playerTime.sampleTime) / Double(currentSampleLength)))
        }
    }
}
