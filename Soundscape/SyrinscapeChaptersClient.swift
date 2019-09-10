//
//  SyrinscapeChaptersClient.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

final class SyrinscapeChaptersClient: NSObject, XMLParserDelegate {
    var chapters: [ChapterOptions] = []
    var campaigns: [Campaign] = []
    var isDeviceBlessed: Bool = false
    var latestVersion: String?
    var minimumVersion: String?
    var token: String?

    struct ChapterOptions {
        var sku: String?
        var slug: String?
        var title: String?
        var description: String?
        var moodNames: [String] = []
        var elementNames: [String] = []
        var isPurchased: Bool = false
        var isBundled: Bool = false
        var isCommunityContent: Bool = false
        var viewURL: URL?
        var downloadURL: URL?
        var downloadSize: Int?
        var downloadUpdatedDate: Date?
        var manifestURL: URL?
        var mobileDownloadURL: URL?
        var mobileDownloadSize: Int?
        var mobileManifestURL: URL?
        var backgroundImageURL: URL?
        var inactiveBackgroundImageURL: URL?
        var teaserImageURL: URL?
        var teaserVideoURL: URL?
        var previewMP3URL: URL?
        var previewOGGURL: URL?
    }

    struct Campaign {
        var name: String?
        var soundsetNames: [String] = []
    }

    private var baseURL: URL?
    private var elementPathComponents: [String]?
    private var text: String?
    private var chapterOptions: ChapterOptions?
    private var campaign: Campaign?

    func download(category: SyrinscapeCategory, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string:"https://www.syrinscape.com/account/chapters/\(category.urlComponent)/1.2.1/")!
        download(fromURL: url, completionHandler: completionHandler)
    }

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
        case "Response.Chapters.ChapterOptions":
            chapterOptions = ChapterOptions()
        case "Response.Campaigns.Campaign":
            campaign = Campaign()
        default:
            text = ""
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
        case "Response.Chapters.ChapterOptions.SKU":
            chapterOptions!.sku = text!
        case "Response.Chapters.ChapterOptions.Slug":
            chapterOptions!.slug = text!
        case "Response.Chapters.ChapterOptions.Title":
            chapterOptions!.title = text!
        case "Response.Chapters.ChapterOptions.Description":
            chapterOptions!.description = text!
        case "Response.Chapters.ChapterOptions.Moods.Mood":
            chapterOptions!.moodNames.append(text!)
        case "Response.Chapters.ChapterOptions.Elements.Element" :
            chapterOptions!.elementNames.append(text!)
        case "Response.Chapters.ChapterOptions.IsPurchased":
            chapterOptions!.isPurchased = text == "true"
        case "Response.Chapters.ChapterOptions.IsBundled":
            chapterOptions!.isBundled = text == "true"
        case "Response.Chapters.ChapterOptions.IsCommunityContent":
            chapterOptions!.isCommunityContent = text! == "true"
        case "Response.Chapters.ChapterOptions.ViewURL":
            chapterOptions!.viewURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.DownloadURL":
            chapterOptions!.downloadURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.DownloadSize":
            chapterOptions!.downloadSize = Int(text!)
        case "Response.Chapters.ChapterOptions.DownloadUpdated":
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            chapterOptions!.downloadUpdatedDate = formatter.date(from: text!)
        case "Response.Chapters.ChapterOptions.ManifestURL":
            chapterOptions!.manifestURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.MobileDownloadURL":
            chapterOptions!.mobileDownloadURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.MobileDownloadSize":
            chapterOptions!.mobileDownloadSize = Int(text!)
        case "Response.Chapters.ChapterOptions.MobileManifestURL":
            chapterOptions!.mobileManifestURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.BackgroundImage":
            chapterOptions!.backgroundImageURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.InactiveBackgroundImage":
            chapterOptions!.inactiveBackgroundImageURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.TeaserImage":
            chapterOptions!.teaserImageURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.TeaserVideo":
            chapterOptions!.teaserVideoURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.PreviewMP3":
            chapterOptions!.previewMP3URL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions.PreviewOGG":
            chapterOptions!.previewOGGURL = URL(string: text!, relativeTo: baseURL)
        case "Response.Chapters.ChapterOptions":
            chapters.append(chapterOptions!)
            chapterOptions = nil

        case "Response.Campaigns.Campaign.Name":
            campaign!.name = text!
        case "Response.Campaigns.Campaign.Soundset":
            campaign!.soundsetNames.append(text!)
        case "Response.Campaigns.Campaign":
            campaigns.append(campaign!)
            campaign = nil

        case "Response.DeviceIsBlessed":
            isDeviceBlessed = text! == "true"
        case "Response.LatestVersion":
            latestVersion = text!
        case "Response.MinimumVersion":
            minimumVersion = text!
        case "Response.Token":
            token = text!

        default: break
        }

        text = nil
        elementPathComponents?.removeLast()
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        elementPathComponents = nil
    }
}
