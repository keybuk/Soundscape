//
//  AVAudioPlayerNode+OggVorbis.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioPlayerNode {

    func scheduleFile(_ file: OggVorbisFile, at when: AVAudioTime? = nil, completionHandler: AVAudioNodeCompletionHandler? = nil) {
        // FIXME: this limits our play time to around 13 hours... oh no.
        let frames = AVAudioFrameCount(truncatingIfNeeded: file.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.fileFormat, frameCapacity: frames) else {
            print("Failed to allocate buffer")
            completionHandler?()
            return
        }

        do {
            try file.read(into: buffer)
        } catch let error {
            print("Failed to read into buffer: \(error.localizedDescription)")
            completionHandler?()
            return
        }

        if buffer.frameLength > 0 {
            scheduleBuffer(buffer, at: when, completionHandler: completionHandler)
        } else {
            completionHandler?()
        }
    }

}
