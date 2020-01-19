//
//  Sample+DownloadFromSyrinscape.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

extension Sample {
    var cacheURL: URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesDirectory.appendingPathComponent("\(uuid!).ogg", isDirectory: false)
    }

    var isCached: Bool {
        FileManager.default.fileExists(atPath: cacheURL.path)
    }

    func downloadFromSyrinscape(completionHandler: @escaping (Result<Void, Error>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url!.authenticatedForSyrinscape() ?? url!) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completionHandler(.failure(SyrinscapeDownloadError.invalidServerResponse(response)))
                return
            }

            guard httpResponse.statusCode == 200 else {
                completionHandler(.failure(SyrinscapeDownloadError.badServerResponse(httpResponse.statusCode)))
                return
            }

            guard httpResponse.mimeType == "audio/ogg" else {
                completionHandler(.failure(SyrinscapeDownloadError.incorrectMimeType(httpResponse.mimeType)))
                return
            }

            do {
                try data.write(to: self.cacheURL)
            } catch let error {
                completionHandler(.failure(error))
            }

            completionHandler(.success(()))
        }
        task.resume()
        return task
    }
}
