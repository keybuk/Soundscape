//
//  AudioManager.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioManager {

    /// Notifies observers that the audio configuration has changed.
    ///
    /// Observers should reconnect nodes which may be affected by changes in sample format.
    static let configurationChangeNotification = NSNotification.Name("configurationChangeNotification")

    /// Notifies observers that the audio engine has been reset
    ///
    /// Observers must discard, recreate, reattach, and reconnect all nodes.
    static let engineResetNotification = NSNotification.Name("engineResetNotification")

    // Session settings that work with multiple AirPlay speaker playback.
    let category: AVAudioSession.Category = .playback
    let categoryOptions: AVAudioSession.CategoryOptions = []
    let mode: AVAudioSession.Mode = .default
    let routeSharingPolicy: AVAudioSession.RouteSharingPolicy = .longFormAudio

    var session: AVAudioSession { .sharedInstance() }
    var engine: AVAudioEngine!

    var isSessionInterrupted = false
    var isConfigChangePending = false

    func start() {
        if engine == nil {
            // Set observers; the documentation is clear that we never need to
            // re-register these, so it should be safe to
            NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification,
                                                   object: session, queue: nil, using: audioSessionInterruption)
            NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification,
                                                   object: session, queue: nil, using: audioSessionRouteChange)
            NotificationCenter.default.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification,
                                                   object: session, queue: nil, using: mediaServicesWereReset)

            setupAudioSession()
            createEngine()
        }
    }

    func setupAudioSession() {
        do {
            try session.setCategory(category, mode: mode, policy: routeSharingPolicy, options: categoryOptions)
        } catch let error as NSError {
            fatalError("Failed to set audio session category: \(error.localizedDescription)")
        }

        do {
            try session.setActive(true)
        } catch let error as NSError {
            fatalError("Failed to activate audio session: \(error.localizedDescription)")
        }
    }

    func createEngine() {
        engine = AVAudioEngine()

        NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange,
                                               object: engine, queue: nil, using: audioEngineConfigurationChange)
    }

    func audioSessionInterruption(_ notification: Notification) {
        guard let notificationAudioSession = notification.object as? AVAudioSession,
            notificationAudioSession == session,
            let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType
            else { fatalError("Invalid audio session interruption notification") }

        switch interruptionType {
        case .began:
            print("Audio session interruption began")
            isSessionInterrupted = true
        case .ended:
            print("Audio session interruption ended")
            let options = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions ?? []

            do {
                try session.setActive(true)
            } catch let error as NSError {
                print("Failed to activate audio session after interruption: \(error.localizedDescription)")
            }

            isSessionInterrupted = false
            if isConfigChangePending {
                print("Configuration changed while inactive")
                NotificationCenter.default.post(name: Self.configurationChangeNotification,
                                                object: self)

                isConfigChangePending = false
            }

            if (options.contains(.shouldResume)) {
                // FIXME: resume playback
                print("Should resume")
            }
        @unknown default:
            fatalError("Unknown interruption type: \(interruptionType)")
        }
    }

    func audioSessionRouteChange(_ notification: Notification) {
        guard let notificationAudioSession = notification.object as? AVAudioSession,
            notificationAudioSession == session
            else { fatalError("Invalid audio session route change notification") }

        print("Audio route changed:")
        if let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? AVAudioSession.RouteChangeReason {
            switch reason {
            case .newDeviceAvailable:
                print("  New device available")
            case .oldDeviceUnavailable:
                print("  Old device unavailable")
            case .categoryChange:
                print("  Category change, now: \(session.category)")
            case .override:
                print("  Override")
            case .wakeFromSleep:
                print("  Wake from sleep")
            case .noSuitableRouteForCategory:
                print("  No suitable route for category")
            case .routeConfigurationChange:
                print("  Route configuration changed")
            case .unknown:
                print("  Unknown reason")
            @unknown default:
                fatalError("Unknown route change reason: \(reason)")
            }
        }

        if let previousRoute = notification.userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
            print("  Previous route: \(previousRoute)")
        }
    }

    func mediaServicesWereReset(_ notification: Notification) {
        print("Media services were reset")

        do {
            try session.setCategory(category, mode: mode, policy: routeSharingPolicy, options: categoryOptions)
        } catch let error as NSError {
            print("Failed to set audio session category after reset: \(error.localizedDescription)")
        }

        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Failed to activate audio session after reset: \(error.localizedDescription)")
        }

        createEngine()

        NotificationCenter.default.post(name: Self.engineResetNotification,
                                        object: self)
    }

    func audioEngineConfigurationChange(_ notification: Notification) {
        print("Audio engine configuration changed")
        isConfigChangePending = true
        guard !isSessionInterrupted else {
            print("Session is currently interrupted, deferring changes")
            return
        }

        NotificationCenter.default.post(name: Self.configurationChangeNotification,
                                        object: self)
    }
}
