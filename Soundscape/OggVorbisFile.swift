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
            framesRead = ov_read_float(&vorbisFile, &pcmChannels, Int32(frames), &currentBitstream)
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
