//
//  PlaylistEntry+Open.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/13/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Sample {
    func openFile(downloadingHandler: () -> Void, completionHandler: @escaping (Result<OggVorbisFile, Error>) -> Void) {
        if isCached,
            let file = try? OggVorbisFile(forReading: cacheURL)
        {
            completionHandler(.success(file))
            return
        } else {
            downloadingHandler()
            downloadFromSyrinscape { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        let file: OggVorbisFile
                        do {
                            file = try OggVorbisFile(forReading: self.cacheURL)
                        } catch let error {
                            completionHandler(.failure(error))
                            return
                        }

                        completionHandler(.success(file))
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                }
            }
        }
    }
}
