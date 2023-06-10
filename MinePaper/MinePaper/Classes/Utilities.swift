//
//  Utilities.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import Foundation
import Wallpaper
import AppKit
import Files

struct Utilities {
    
    static func writeSettingsToDisk(settings: Settings) throws {
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        let settingsJson = try jsonEncoder.encode(settings)
        let jsonString = String(data: settingsJson, encoding: String.Encoding.utf8)
        
        let url = try getDataDirectory()
        let folder = try Folder(path: url)
        let file = try folder.createFile(named: "settings.json")
        try file.write(jsonString!)
    }
    
    static func readSettingsFromDisk() throws -> Settings {
        
        let file = try? File(path: getDataDirectory() + "/settings.json")
        var output = Settings()
        
        if file != nil {
            let fileData = try file!.read()
            let jsonString = String(decoding: fileData, as: UTF8.self)
            
            if jsonString != "" {
                let jsonData = Data(jsonString.utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                output = try decoder.decode(Settings.self, from: jsonData)
            }
        }
            
        return output
    }
    
    static func scanImagesDirectory() throws -> [String] {
        
        let imagesDirectory = try? getImagesDirectory()
        guard imagesDirectory != nil else {
            throw GeneralErrors.DataReadError
        }
        
        let imagesFolder = try? Folder(path: imagesDirectory!)
        guard imagesFolder != nil else {
            throw GeneralErrors.DataReadError
        }
        
        var output = [String]()
        let validExtensions = ["jpg", "png", "jpeg", "JPG", "PNG", "JPEG"]
        
        imagesFolder!.files.enumerated().forEach { (index, file) in
            if validExtensions.contains(file.extension!) {
                output.append(file.name)
            }
        }
        
        return output
    }
    
    static func getImageListFromServer() throws -> [String] {
        
        var output = [String]()
        let sephamore = DispatchSemaphore(value: 0)
        
        do {
            var request = URLRequest(url: URL(string: Constants.remoteImageListEndpoint)!)
            request.httpMethod = "GET"
            var stringResult = ""
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if data == nil || response == nil {
                    stringResult = ""
                } else {
                    stringResult = String(data: data!, encoding: String.Encoding    .utf8)!
                }
                
                sephamore.signal()
            }
            
            task.resume()
            sephamore.wait()
            
            if stringResult == "" {
                throw NetworkError.GeneralError
            }
            
            let resultData = Data(stringResult.utf8)
            let resultDict = try JSONSerialization.jsonObject(with: resultData, options: []) as! [String: Any]
            if resultDict["files"] == nil {
                throw NetworkError.DataFormatError
            }
            else if resultDict["files"] is [String] {
                output = resultDict["files"] as! [String]
            }
            else {
                throw NetworkError.DataFormatError
            }
            
        } catch {
            throw error
        }
        
        return output
    }
    
    static func downloadImageFromServer(fileName: String) -> DownloadStatus {
        
        let sephamore = DispatchSemaphore(value: 0)
        var output: DownloadStatus = DownloadStatus.Success
        
        let url = URL(string: Constants.remoteImagesFolder + "/" + fileName)
        let task = URLSession.shared.downloadTask(with: url!) { localURL, urlResponse, error in
            if var localURL = localURL {
                
                let originFile = try? File(path: localURL.path)
                if originFile != nil {
                    try? originFile?.rename(to: fileName, keepExtension: false)
                    localURL.deleteLastPathComponent()
                    
                    let imageFile = try? File(path: localURL.path + "/" + fileName)
                    if imageFile == nil {
                        output = DownloadStatus.FileWriteError
                    }
                    else {
                        let destinationFolder = try? Folder(path: getImagesDirectory())
                        if destinationFolder == nil {
                            output = DownloadStatus.FileWriteError
                        }
                        else {
                            try? imageFile?.copy(to: destinationFolder!)
                        }
                    }
                }
                else {
                    output = DownloadStatus.FileWriteError
                }
            }
            else {
                output = DownloadStatus.NetworkError
            }
            
            sephamore.signal()
        }
        
        // Start the download
        task.resume()
        sephamore.wait()
        return output
    }
    
    static func setWallpaper(fileName: String, screen: Wallpaper.Screen) throws {
        let imageURL = URL(fileURLWithPath: try Utilities.getImagesDirectory() + "/" + fileName, isDirectory: false)
        try! Wallpaper.set(imageURL, screen: screen)
    }
    
    static func getDataDirectory() throws -> String {
        let url = try? FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url!.path
    }
    
    static func getImagesDirectory() throws -> String {
        let url = try getDataDirectory() + "/Images"
        return url
    }
}
