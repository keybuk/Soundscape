//
//  SyrinscapeManifestClient.swift
//  Soundscape
//
//  Created by Scott James Remnant on 9/10/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import Foundation

final class SyrinscapeManifestClient: NSObject, XMLParserDelegate {
    var soundsetFiles: [SoundsetFile] = []
    
    struct SoundsetFile {
        var url: URL?
        var hash: String?
        var size: Int?
        var filename: String?
    }

    func soundsetFile(matching filename: String) -> SoundsetFile? {
        soundsetFiles.first {
            $0.filename == filename || ($0.filename?.hasSuffix("/\(filename)") ?? false)
        }
    }
    
    private var baseURL: URL?
    private var elementPathComponents: [String]?
    private var text: String?
    private var _soundsetFile: SoundsetFile?
    
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
        case "SoundsetManifest.Files.SoundsetFile":
            _soundsetFile = SoundsetFile()
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
        case "SoundsetManifest.Files.SoundsetFile.Url":
            _soundsetFile!.url = URL(string: text!, relativeTo: baseURL)
        case "SoundsetManifest.Files.SoundsetFile.Hash":
            _soundsetFile!.hash = text!
        case "SoundsetManifest.Files.SoundsetFile.Filesize":
            _soundsetFile!.size = Int(text!)
        case "SoundsetManifest.Files.SoundsetFile.Filename":
            _soundsetFile!.filename = text!
            
        case "SoundsetManifest.Files.SoundsetFile":
            soundsetFiles.append(_soundsetFile!)
            _soundsetFile = nil
        case "SoundsetManifest.Files": break
        case "SoundsetManifest": break

        default:
            print("Unhandled Manifest Client field: \(elementPath)")
        }
        
        text = nil
        elementPathComponents?.removeLast()
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        elementPathComponents = nil
    }
}
