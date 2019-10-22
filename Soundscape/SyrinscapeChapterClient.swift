//
//  SyrinscapeChapterClient.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

final class SyrinscapeChapterClient: NSObject, XMLParserDelegate {
    var slug: String?
    var createdDate: Date?
    var updatedDate: Date?
    var downloadUpdatedDate: Date?
    var uuid: String?
    var title: String?
    var credits: String?
    var creatorURL: URL?
    var category: Tag?
    var ownedBy: String?
    var createdBy: String?
    var uploadedBy: String?
    var backgroundImageFile: String?
    var inactiveBackgroundImageFile: String?
    var previewMP3URL: URL?
    var previewOGGURL: URL?
    var tags: [Tag] = []
    var initialGain: Float?
    var samples: [SoundSample] = []
    var musicElements: [Element] = []
    var sfxElements: [Element] = []
    var loopElements: [Element] = []
    var oneshotElements: [Element] = []
    var moods: [Mood] = []
    var reverb: String?
    var reverbPreset: ReverbPreset?
    var reverbPresets: [ReverbPreset] = []
    var formatVersion: String?

    struct Tag {
        var slug: String?
        var title: String?
    }

    struct SoundSample {
        var uuid: String?
        var fileExtension: String?
        var title: String?
        var category: Tag?
        var duration: Int?
        var tags: [Tag] = []
        var attribution: String?
        var is3D: Bool = false
        var createdDate: Date?
        var updatedDate: Date?
        var ownedBy: String?
        var uploadedBy: String?
    }

    struct Element {
        var slug: String?
        var title: String?
        var iconFile: String?
        var iconFileHires: String?
        var iconHoverFile: String?
        var iconHoverFileHires: String?
        var iconActiveFile: String?
        var iconActiveFileHires: String?
        var credits: String?
        var initialGain: Float?
        var initialIntensity: Float?
        var bypassEffects: Bool = false
        var bypassPosition: Bool = false
        var reverbPreset: String?
        var playlist: [PlaylistEntry] = []
        var reverseDirection: Bool = false
        var minStartDelay: Double?
        var maxStartDelay: Double?
        var randomisePlaylist: String?
        var repeatPlaylist: Bool = false
        var allowPlaylistOverlap: Bool = false
        var minTriggerWait: Double?
        var maxTriggerWait: Double?
        var minAngle: Float?
        var maxAngle: Float?
        var minDistance: Float?
        var maxDistance: Float?
        var speed: Float?
        var isGlobalOneshot: Bool = false
    }

    struct PlaylistEntry {
        var sampleFile: String?
        var minGain: Float?
        var maxGain: Float?
        var minElementIntensity: Float?
        var maxElementIntensity: Float?
        var position: Int?
    }

    struct Mood {
        var title: String?
        var elementParameters: [ElementParameter] = []
    }

    struct ElementParameter {
        var elementSlug: String?
        var plays: Bool = false
        var intensity: Float?
        var volume: Float?
    }

    struct ReverbPreset {
        var name: String?
        var dryLevel: Float?
        var room: Float?
        var roomHf: Float?
        var roomLf: Float?
        var hfReference: Float?
        var roomRolloff: Float?
        var decayTime: Float?
        var decayHfRatio: Float?
        var reflectionsLevel: Float?
        var reflectionsDelay: Float?
        var reverbDelay: Float?
        var diffusion: Float?
        var density: Float?
        var nearReverbLevel: Float?
        var farReverbLevel: Float?
        var nearReverbDistance: Float?
        var farReverbDistance: Float?
    }

    private var baseURL: URL?
    private var elementPathComponents: [String]?
    private var text: String?
    private var _tag: Tag?
    private var _soundSample: SoundSample?
    private var _element: Element?
    private var _playlistEntry: PlaylistEntry?
    private var _mood: Mood?
    private var _elementParameter: ElementParameter?
    private var _reverbPreset: ReverbPreset?

    func download(fromURL url: URL, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = url.authenticatedForSyrinscape() ?? url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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

            guard httpResponse.mimeType == "application/xml" else {
                completionHandler(.failure(SyrinscapeDownloadError.incorrectMimeType(httpResponse.mimeType)))
                return
            }

            self.baseURL = url
            let parser = XMLParser(data: data)
            parser.delegate = self

            if parser.parse() {
                return completionHandler(.success(()))
            } else if let parserError = parser.parserError {
                return completionHandler(.failure(parserError))
            } else {
                return completionHandler(.failure(SyrinscapeDownloadError.unknownParseError))
            }
        }
        task.resume()
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        elementPathComponents = []
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elementPathComponents!.append(elementName)
        let elementPath = elementPathComponents!.joined(separator: ".")

        switch elementPath {
        case "Chapter.Category":
            _tag = Tag()
        case "Chapter.Tags.Tag":
            _tag = Tag()
        case "Chapter.Samples.SoundSample":
            _soundSample = SoundSample()
        case "Chapter.Samples.SoundSample.Category":
            _tag = Tag()
        case "Chapter.Samples.SoundSample.Tags.Tag":
            _tag = Tag()
        case "Chapter.MusicElements.MusicElement":
            _element = Element()
        case "Chapter.SfxElements.SFXElement":
            _element = Element()
        case "Chapter.LoopElements.LoopElement":
            _element = Element()
        case "Chapter.OneshotElements.OneshotElement":
            _element = Element()
        case "Chapter.Moods.Mood":
            _mood = Mood()
        case "Chapter.Moods.Mood.ElementParameters.ElementParameter":
            _elementParameter = ElementParameter()
        case "Chapter.ReverbPreset":
            _reverbPreset = ReverbPreset()
        case "Chapter.ReverbPresets.ReverbPreset":
            _reverbPreset = ReverbPreset()

        default:
            switch elementName {
            // Match either of the four element types.
            case "PlaylistEntry" where _element != nil:
                _playlistEntry = PlaylistEntry()

            default:
                text = ""
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if text != nil {
            text! += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let elementPath = elementPathComponents!.joined(separator: ".")
        switch elementPath {
        case "Chapter.Slug":
            slug = text!
        case "Chapter.Created":
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            createdDate = formatter.date(from: text!)
        case "Chapter.Updated":
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            updatedDate = formatter.date(from: text!)
        case "Chapter.DownloadUpdated":
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            downloadUpdatedDate = formatter.date(from: text!)
        case "Chapter.Uuid":
            uuid = text!
        case "Chapter.Title":
            title = text!
        case "Chapter.Credits":
            credits = text!
        case "Chapter.CreatorUrl":
            creatorURL = URL(string: text!, relativeTo: baseURL)
        case "Chapter.Category":
            category = _tag!
            _tag = nil
        case "Chapter.OwnedBy":
            ownedBy = text!
        case "Chapter.CreatedBy":
            createdBy = text!
        case "Chapter.UploadedBy":
            uploadedBy = text!
        case "Chapter.BackgroundImageFile":
            backgroundImageFile = text!
        case "Chapter.InactiveBackgroundImageFile":
            inactiveBackgroundImageFile = text!
        case "Chapter.PreviewMp3":
            previewMP3URL = URL(string: text!, relativeTo: URL(string: "https://syrinscape-us.s3.amazonaws.com/media"))
        case "Chapter.PreviewOgg":
            previewOGGURL = URL(string: text!, relativeTo: URL(string: "https://syrinscape-us.s3.amazonaws.com/media"))
        case "Chapter.Tags.Tag":
            tags.append(_tag!)
            _tag = nil
        case "Chapter.Tags": break
        case "Chapter.InitialGain":
            initialGain = Float(text!)
        case "Chapter.Reverb":
            reverb = text!

        case "Chapter.Samples.SoundSample.Uuid":
            _soundSample!.uuid = text!
        case "Chapter.Samples.SoundSample.Extension":
            _soundSample!.fileExtension = text!
        case "Chapter.Samples.SoundSample.Title":
            _soundSample!.title = text!
        case "Chapter.Samples.SoundSample.Category":
            _soundSample!.category = _tag!
            _tag = nil
        case "Chapter.Samples.SoundSample.Duration":
            _soundSample!.duration = Int(text!)
        case "Chapter.Samples.SoundSample.Tags.Tag":
            _soundSample!.tags.append(_tag!)
            _tag = nil
        case "Chapter.Samples.SoundSample.Tags": break
        case "Chapter.Samples.SoundSample.Attribution":
            _soundSample!.attribution = text!
        case "Chapter.Samples.SoundSample.Is3d":
            _soundSample!.is3D = text! == "true"
        case "Chapter.Samples.SoundSample.Created":
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            _soundSample!.createdDate = formatter.date(from: text!)
        case "Chapter.Samples.SoundSample.Updated":
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            _soundSample!.updatedDate = formatter.date(from: text!)
        case "Chapter.Samples.SoundSample.OwnedBy":
            _soundSample!.ownedBy = text!
        case "Chapter.Samples.SoundSample.UploadedBy":
            _soundSample!.uploadedBy = text!
        case "Chapter.Samples.SoundSample":
            samples.append(_soundSample!)
            _soundSample = nil
        case "Chapter.Samples": break

        case "Chapter.MusicElements.MusicElement.Playlist": break
        case "Chapter.MusicElements.MusicElement":
            musicElements.append(_element!)
            _element = nil
        case "Chapter.MusicElements": break

        case "Chapter.SfxElements.SFXElement.Playlist": break
        case "Chapter.SfxElements.SFXElement":
            sfxElements.append(_element!)
            _element = nil
        case "Chapter.SfxElements": break

        case "Chapter.LoopElements.LoopElement.Playlist": break
        case "Chapter.LoopElements.LoopElement":
            loopElements.append(_element!)
            _element = nil
        case "Chapter.LoopElements": break

        case "Chapter.OneshotElements.OneshotElement.Playlist": break
        case "Chapter.OneshotElements.OneshotElement":
            oneshotElements.append(_element!)
            _element = nil
        case "Chapter.OneshotElements": break

        case "Chapter.Moods.Mood.Title":
            _mood!.title = text!
        case "Chapter.Moods.Mood.ElementParameters.ElementParameter.ElementSlug":
            _elementParameter!.elementSlug = text!
        case "Chapter.Moods.Mood.ElementParameters.ElementParameter.Plays":
            _elementParameter!.plays = text! == "true"
        case "Chapter.Moods.Mood.ElementParameters.ElementParameter.Intensity":
            _elementParameter!.intensity = Float(text!)
        case "Chapter.Moods.Mood.ElementParameters.ElementParameter.Volume":
            _elementParameter!.volume = Float(text!)
        case "Chapter.Moods.Mood.ElementParameters.ElementParameter":
            _mood!.elementParameters.append(_elementParameter!)
            _elementParameter = nil
        case "Chapter.Moods.Mood.ElementParameters": break
        case "Chapter.Moods.Mood":
            moods.append(_mood!)
            _mood = nil
        case "Chapter.Moods": break

        case "Chapter.ReverbPreset":
            reverbPreset = _reverbPreset
            _reverbPreset = nil
        case "Chapter.ReverbPresets.ReverbPreset":
            reverbPresets.append(_reverbPreset!)
            _reverbPreset = nil
        case "Chapter.ReverbPresets": break

        case "Chapter.FormatVersion":
            formatVersion = text!

        case "Chapter": break

        default:
            switch elementName {
            // Match any tag
            case "Title" where _tag != nil:
                _tag!.title = text!
            case "Slug" where _tag != nil:
                _tag!.slug = text!

            // Match the playlist entry of any element type.
            case "SampleFile" where _playlistEntry != nil:
                _playlistEntry!.sampleFile = text!
            case "MinGain" where _playlistEntry != nil:
                _playlistEntry!.minGain = Float(text!)
            case "MaxGain" where _playlistEntry != nil:
                _playlistEntry!.maxGain = Float(text!)
            case "MinElementIntensity" where _playlistEntry != nil:
                _playlistEntry!.minElementIntensity = Float(text!)
            case "MaxElementIntensity" where _playlistEntry != nil:
                _playlistEntry!.maxElementIntensity = Float(text!)
            case "Position" where _playlistEntry != nil:
                _playlistEntry!.position = Int(text!)

            // Match either of the four element types.
            case "Slug" where _element != nil:
                _element!.slug = text!
            case "Title" where _element != nil:
                _element!.title = text!
            case "IconFile" where _element != nil:
                _element!.iconFile = text!
            case "IconFileHires" where _element != nil:
                _element!.iconFileHires = text!
            case "IconHoverFile" where _element != nil:
                _element!.iconHoverFile = text!
            case "IconHoverFileHires" where _element != nil:
                _element!.iconHoverFileHires = text!
            case "IconActiveFile" where _element != nil:
                _element!.iconActiveFile = text!
            case "IconActiveFileHires" where _element != nil:
                _element!.iconActiveFileHires = text!
            case "Credits" where _element != nil:
                _element!.credits = text!
            case "InitialGain" where _element != nil:
                _element!.initialGain = Float(text!)
            case "InitialIntensity" where _element != nil:
                _element!.initialIntensity = Float(text!)
            case "BypassEffects" where _element != nil:
                _element!.bypassEffects = text! == "true"
            case "BypassPosition" where _element != nil:
                _element!.bypassPosition = text! == "true"
            case "ReverbPreset" where _element != nil:
                _element!.reverbPreset = text!
            case "PlaylistEntry" where _element != nil:
                _element!.playlist.append(_playlistEntry!)
                _playlistEntry = nil
            case "ReverseDirection" where _element != nil:
                _element!.reverseDirection = text! == "true"
            case "MinStartDelay" where _element != nil:
                _element!.minStartDelay = Double(text!)
            case "MaxStartDelay" where _element != nil:
                _element!.maxStartDelay = Double(text!)
            case "RandomisePlaylist" where _element != nil:
                _element!.randomisePlaylist = text! // shuffle inorder random
            case "RepeatPlaylist" where _element != nil:
                _element!.repeatPlaylist = text! == "true"
            case "AllowPlaylistOverlap" where _element != nil:
                _element!.allowPlaylistOverlap = text! == "true"
            case "MinTriggerWait" where _element != nil:
                _element!.minTriggerWait = Double(text!)
            case "MaxTriggerWait" where _element != nil:
                _element!.maxTriggerWait = Double(text!)
            case "MinAngle" where _element != nil:
                _element!.minAngle = Float(text!)
            case "MaxAngle" where _element != nil:
                _element!.maxAngle = Float(text!)
            case "MinDistance" where _element != nil:
                _element!.minDistance = Float(text!)
            case "MaxDistance" where _element != nil:
                _element!.maxDistance = Float(text!)
            case "Speed" where _element != nil:
                _element!.speed = Float(text!)
            case "IsGlobalOneshot" where _element != nil:
                _element!.isGlobalOneshot = text! == "true"

            // Match either the global reverb preset or from the list.
            case "Name" where _reverbPreset != nil:
                _reverbPreset!.name = text!
            case "DryLevel" where _reverbPreset != nil:
                _reverbPreset!.dryLevel = Float(text!)
            case "Room" where _reverbPreset != nil:
                _reverbPreset!.room = Float(text!)
            case "RoomHf" where _reverbPreset != nil:
                _reverbPreset!.roomHf = Float(text!)
            case "RoomLf" where _reverbPreset != nil:
                _reverbPreset!.roomLf = Float(text!)
            case "HfReference" where _reverbPreset != nil:
                _reverbPreset!.hfReference = Float(text!)
            case "RoomRolloff" where _reverbPreset != nil:
                _reverbPreset!.roomRolloff = Float(text!)
            case "DecayTime" where _reverbPreset != nil:
                _reverbPreset!.decayTime = Float(text!)
            case "DecayHfRatio" where _reverbPreset != nil:
                _reverbPreset!.decayHfRatio = Float(text!)
            case "ReflectionsLevel" where _reverbPreset != nil:
                _reverbPreset!.reflectionsLevel = Float(text!)
            case "ReflectionsDelay" where _reverbPreset != nil:
                _reverbPreset!.reflectionsDelay = Float(text!)
            case "ReverbDelay" where _reverbPreset != nil:
                _reverbPreset!.reverbDelay = Float(text!)
            case "Diffusion" where _reverbPreset != nil:
                _reverbPreset!.diffusion = Float(text!)
            case "Density" where _reverbPreset != nil:
                _reverbPreset!.density = Float(text!)
            case "NearReverbLevel" where _reverbPreset != nil:
                _reverbPreset!.nearReverbLevel = Float(text!)
            case "FarReverbLevel" where _reverbPreset != nil:
                _reverbPreset!.farReverbLevel = Float(text!)
            case "NearReverbDistance" where _reverbPreset != nil:
                _reverbPreset!.nearReverbDistance = Float(text!)
            case "FarReverbDistance" where _reverbPreset != nil:
                _reverbPreset!.farReverbDistance = Float(text!)

            default:
                print("Unhandled Chapter Client field: \(elementPath)")
            }
        }

        text = nil
        elementPathComponents?.removeLast()
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        elementPathComponents = nil
    }
}
