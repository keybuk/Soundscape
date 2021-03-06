//
//  AVAudioPlayerNode+OggVorbis.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import AVFoundation

extension ClosedRange where Bound == AVAudioFramePosition {
    var length: AVAudioFramePosition {
        AVAudioFramePosition(truncatingIfNeeded: count)
    }
}

extension AVAudioPlayerNode {
    func scheduleFile(_ file: OggVorbisFile, looping: Bool = false, at when: AVAudioTime? = nil, startHandler: AVAudioNodeCompletionHandler? = nil, completionHandler: AVAudioNodeCompletionHandler? = nil) {
        let loop = looping ? file.loop : nil

        // FIXME: this limits our play time to around 13 hours... oh no.
        let frames = AVAudioFrameCount(truncatingIfNeeded: loop?.lowerBound ?? file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.fileFormat, frameCapacity: frames) else {
            print("Failed to allocate buffer")
            completionHandler?()
            return
        }

        do {
            try file.read(into: buffer, frameCount: frames)
        } catch let error {
            print("Failed to read into buffer: \(error.localizedDescription)")
            completionHandler?()
            return
        }

        // Load the looping portion.
        let loopBuffer: AVAudioPCMBuffer?
        if let loop = loop {
            let loopFrames = AVAudioFrameCount(truncatingIfNeeded: loop.length)
            loopBuffer = AVAudioPCMBuffer(pcmFormat: file.fileFormat, frameCapacity: loopFrames)
            guard loopBuffer != nil else {
                print("Failed to allocate loop buffer")
                completionHandler?()
                return
            }

            do {
                try file.read(into: loopBuffer!, frameCount: loopFrames)
            } catch let error {
                print("Failed to read into loop buffer: \(error.localizedDescription)")
                completionHandler?()
                return
            }
        } else {
            loopBuffer = nil
        }

        if startHandler != nil {
            if let startBuffer = AVAudioPCMBuffer(pcmFormat: file.fileFormat, frameCapacity: 0) {
                scheduleBuffer(startBuffer, at: when, completionHandler: startHandler)
            } else {
                print("Failed to allocate buffer, calling start handler early")
                startHandler?()
            }
        }

        if let loop = loop, let loopBuffer = loopBuffer {
            let loopWhen = when.map {
                AVAudioTime(sampleTime: $0.sampleTime + loop.lowerBound, atRate: file.processingFormat.sampleRate)
            }

            scheduleBuffer(buffer, at: when)
            scheduleBuffer(loopBuffer, at: loopWhen, options: .loops, completionHandler: completionHandler)
        } else {
            scheduleBuffer(buffer, at: when, completionHandler: completionHandler)
        }
    }
}
