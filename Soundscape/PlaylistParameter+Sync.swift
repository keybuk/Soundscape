//
//  PlaylistParameter+Sync.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/16/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation
import CoreData

extension PlaylistParameter {
    static func createFrom(_ client: SyrinscapeChapterClient.ElementParameter, mood: Mood, context managedObjectContext: NSManagedObjectContext) -> PlaylistParameter? {
        // Must be called from managedObjectContext.perform
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard let slug = client.elementSlug
            else { return nil }

        let fetchRequest: NSFetchRequest<PlaylistParameter> = PlaylistParameter.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mood == %@ AND playlist.slug == %@", mood, slug)

        var playlistParameter: PlaylistParameter?
        do {
            let results = try fetchRequest.execute()
            playlistParameter = results.first
        } catch let error {
            print("Failed to fetch element parameter: \(error.localizedDescription)")
            return nil
        }

        if playlistParameter == nil {
            let playlistFetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
            playlistFetchRequest.predicate = NSPredicate(format: "slug == %@", slug)

            let playlist: Playlist?
            do {
                let playlistResults = try playlistFetchRequest.execute()
                playlist = playlistResults.first
            } catch let error {
                print("Failed to fetch playlist \(slug): \(error.localizedDescription)")
                return nil
            }

            if playlist == nil {
                print("Missing playlist: \(slug) for playlist parameter")
                return nil
            }

            playlistParameter = PlaylistParameter(context: managedObjectContext)
            playlistParameter!.playlist = playlist
        }

        playlistParameter!.isPlaying = client.plays
        playlistParameter!.volume = client.volume ?? 1

        return playlistParameter
    }
}
