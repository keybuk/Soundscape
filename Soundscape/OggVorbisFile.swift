//
//  OggVorbisFile.swift
//  Soundscape
//
//  Created by Scott James Remnant on 8/26/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import AVFoundation

final class OggVorbisFile {

    private var vorbisFile: OggVorbis_File
    private var currentBitstream: Int32 = -1

    var fileFormat: AVAudioFormat
    var processingFormat: AVAudioFormat { fileFormat }
    var length: AVAudioFramePosition

    /// Looping portion of the file.
    var loop: ClosedRange<AVAudioFramePosition>?

    private var _framePosition: AVAudioFramePosition = 0
    var framePosition: AVAudioFramePosition {
        get { _framePosition }
        set {
            _framePosition = newValue
            ov_pcm_seek(&vorbisFile, _framePosition)
        }
    }

    init(forReading url: URL) throws {
        guard let fileHandle = url.withUnsafeFileSystemRepresentation({ fopen($0, "r") }) else {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)
        }

        vorbisFile = OggVorbis_File()
        let openResult = ov_open(fileHandle, &vorbisFile, nil, 0)
        guard openResult == 0 else {
            fclose(fileHandle)
            throw OggVorbisError(fromResult: openResult)
        }

        guard let comments = ov_comment(&vorbisFile, -1) else {
            throw OggVorbisError.invalidBitsream
        }

        guard let info = ov_info(&vorbisFile, -1) else {
            throw OggVorbisError.invalidBitsream
        }

        guard let fileFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                             sampleRate: Double(info.pointee.rate),
                                             channels: UInt32(info.pointee.channels),
                                             interleaved: false)
            else { throw OggVorbisError.incompatibleFormat }
        self.fileFormat = fileFormat

        let pcmTotal = ov_pcm_total(&vorbisFile, -1)
        guard pcmTotal >= 0 else { throw OggVorbisError(fromResult: Int32(pcmTotal)) }
        self.length = pcmTotal

        // Parse the comments for the looping portion.
        var loopStart: AVAudioFramePosition?
        var loopEnd: AVAudioFramePosition?
        var loopLength: AVAudioFramePosition?
        for c in 0..<Int(comments.pointee.comments) {
            guard let valueData = comments.pointee.user_comments?[c],
                let length = comments.pointee.comment_lengths?[c],
                let value = String(bytesNoCopy: valueData, length: Int(length), encoding: .utf8, freeWhenDone: false)
                else { continue }

            let parts = value.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            switch (parts[0].uppercased(), parts[1]) {
            case ("LOOP_START", let loopStartStr): fallthrough
            case ("LOOPSTART", let loopStartStr):
                loopStart = Int64(loopStartStr)
            case ("LOOP_END", let loopEndStr): fallthrough
            case ("LOOPEND", let loopEndStr):
                loopEnd = Int64(loopEndStr)
            case ("LOOP_LENGTH", let loopLengthStr): fallthrough
            case ("LOOPLENGTH", let loopLengthStr):
                loopLength = Int64(loopLengthStr)
            default: break
            }
        }

        if let loopStart = loopStart, let loopEnd = loopEnd {
            loop = loopStart...loopEnd
        } else if let loopStart = loopStart, let loopLength = loopLength {
            loop = loopStart...(loopStart + loopLength)
        }
    }

    deinit {
        ov_clear(&vorbisFile)
    }

    /// Reads frames from the OGG Vorbis file into the buffer.
    ///
    /// The contents of `buffer` are overwritten with frames read starting at the current `framePosition`.
    /// On return, the `frameLength` property is set to the number of frames read, which may be less than the number requested
    /// or zero in the case of end of file.
    /// - Parameter buffer: buffer to read frames into.
    /// - Parameter frames: number of frames to read.
    func read(into buffer: AVAudioPCMBuffer, frameCount frames: AVAudioFrameCount) throws {
        precondition(buffer.frameCapacity >= frames, "Buffer must have capacity for the number of frames requested")

        var framesRemaining = frames
        var totalFramesRead = 0
        var framesRead: Int
        repeat {
            var pcmChannels: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>?
            framesRead = ov_read_float(&vorbisFile, &pcmChannels, Int32(framesRemaining), &currentBitstream)
            guard framesRead >= 0 else { throw OggVorbisError(fromResult: Int32(framesRead)) }

            _framePosition += AVAudioFramePosition(framesRead)
            if framesRead > 0 {
                // Current bitstream may have changed the number of channels.
                guard let info = ov_info(&vorbisFile, currentBitstream) else {
                    throw OggVorbisError.invalidBitsream
                }

                let numberOfChannels = Int(info.pointee.channels)
                guard numberOfChannels == buffer.format.channelCount else { throw OggVorbisError.incompatibleFormat }

                for channel in 0..<numberOfChannels {
                    buffer.floatChannelData?[channel].advanced(by: totalFramesRead).assign(from: pcmChannels![channel]!, count: framesRead)
                }
            }

            totalFramesRead += framesRead
            framesRemaining -= AVAudioFrameCount(framesRead)
        } while framesRead > 0

        buffer.frameLength = AVAudioFrameCount(totalFramesRead)
    }

    /// Reads remaining frames from the OGG Vorbis file into the buffer.
    ///
    /// The contents of `buffer` are overwritten with frames read starting at the current `framePosition`.
    /// On return, the `frameLength` property is set to the number of frames read.
    /// - Parameter buffer: buffer to read frames into.
    func read(into buffer: AVAudioPCMBuffer) throws {
        let frames = AVAudioFrameCount(truncatingIfNeeded: length - framePosition)
        precondition(buffer.frameCapacity >= frames, "Buffer must have capacity for the number of frames required")

        try read(into: buffer, frameCount: frames)
    }

}
