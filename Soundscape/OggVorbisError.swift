//
//  OggVorbisError.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/5/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

enum OggVorbisError: Error {
    /// A read from media returned an error.
    case readError

    /// Bitstream is not Vorbis data.
    case notVorbis

    /// Vorbis version mismatch.
    case versionMismatch

    /// Invalid Vorbis bitstream header.
    case badHeader

    /// Internal logic fault; indicates a bug or heap/stack corruption.
    case fault

    /// Bitstream does not exist or file has not been initialized correctly.
    case invalidBitsream

    /// There was an interruption in the data.
    case hole

    /// An invalid stream section was supplied to libvorbisfile, or the requested link is corrupt.
    case badLink

    /// Bitstream format is incompatible with Core Audio.
    case incompatibleFormat

    /// Unknown error.
    case unknownError(Int32)

    init(fromResult result: Int32) {
        guard result < 0 else { fatalError("Successful result is not an error") }
        switch result {
        case OV_EREAD: self = OggVorbisError.readError
        case OV_ENOTVORBIS: self = OggVorbisError.notVorbis
        case OV_EVERSION: self = OggVorbisError.versionMismatch
        case OV_EBADHEADER: self = OggVorbisError.badHeader
        case OV_EFAULT: self = OggVorbisError.fault
        case OV_EINVAL: self = OggVorbisError.invalidBitsream
        case OV_HOLE: self = OggVorbisError.hole
        case OV_EBADLINK: self = OggVorbisError.badLink
        default: self = OggVorbisError.unknownError(result)
        }
    }
}
