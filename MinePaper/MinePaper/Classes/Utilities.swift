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
    
    static func displayErrorMessage(message: String) -> Bool {
        
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = "Please try again later"
        alert.addButton(withTitle: "Ok")
        alert.alertStyle = .critical
        
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    static func backgroundAppRefresh() throws {
        
        let settings = try? readSettingsFromDisk()
        guard settings != nil else {
            throw GeneralErrors.DataReadError
        }
        
        if settings!.isRotating {
            for nsScreen in NSScreen.screens {
                
                var currentWallpaperOption = settings!.screenWallpapers.first { $0.screenName == nsScreen.localizedName }
                if currentWallpaperOption == nil {
                    
                    currentWallpaperOption = ScreenWallpaper()
                    currentWallpaperOption!.screenName = nsScreen.localizedName
                    settings!.screenWallpapers.append(currentWallpaperOption!)
                }
                
                let numberOfSecondsSinceWallpaperChanged = Int(Date().timeIntervalSince1970 - currentWallpaperOption!.lastRotatedTime.timeIntervalSince1970)
                if numberOfSecondsSinceWallpaperChanged > (settings!.autoRotateMinutes * 60) {
                    
                    var randomImageName = settings!.availableImages.randomElement()
                    while randomImageName == currentWallpaperOption?.currentImage {
                        randomImageName = settings!.availableImages.randomElement()
                    }
                    
                    if randomImageName != nil {
                        try setWallpaper(fileName: randomImageName!, screen: nsScreen)
                        currentWallpaperOption!.lastRotatedTime = Date()
                        currentWallpaperOption!.currentImage = randomImageName!
                        
                        settings!.screenWallpapers = settings!.screenWallpapers.filter { $0.screenName != currentWallpaperOption!.screenName }
                        settings!.screenWallpapers.append(currentWallpaperOption!)
                    }
                }
            }
            try writeSettingsToDisk(settings: settings!)
        }
    }
    
    static func syncImagesWithServer() throws {
        
        let settings = try? readSettingsFromDisk()
        guard settings != nil else {
            throw GeneralErrors.DataReadError
        }
        
        let availableImages = try? scanImagesDirectory()
        guard availableImages != nil else {
            throw GeneralErrors.DataReadError
        }
        
        let serverFileList = try? getImageListFromServer()
        guard serverFileList != nil else {
            throw NetworkError.GeneralError
        }
        
        if serverFileList!.count > 0 {
            
            var tempAvailableImages = try? scanImagesDirectory()
            guard tempAvailableImages != nil else {
                throw GeneralErrors.DataReadError
            }
            
            for imageName in availableImages! {
                
                if !serverFileList!.contains(imageName) {
                    deleteImageFromDisk(fileName: imageName)
                    tempAvailableImages = tempAvailableImages!.filter { $0 != imageName }
                }
            }
            
            let imagesToDownload = Int.random(in: Constants.minImagesToDownload..<Constants.maxImagesToDownload)
            var imagesDownloaded = 0
            
            settings!.availableImages = tempAvailableImages!
            for imageName in serverFileList! {
                
                if imagesDownloaded > imagesToDownload {
                    break;
                }
                
                if !settings!.availableImages.contains(imageName) {
                    
                    var tries = 0
                    while tries < 3 {
                        
                        do {
                            let downloadStatus = downloadImageFromServer(fileName: imageName)
                            if downloadStatus == DownloadStatus.Success {
                                tempAvailableImages!.append(imageName)
                                imagesDownloaded += 1
                                break
                            }
                            else if downloadStatus == DownloadStatus.NetworkError {
                                throw NetworkError.GeneralError
                            }
                            else if downloadStatus == DownloadStatus.FileWriteError {
                                throw GeneralErrors.DataWriteError
                            }
                            else if downloadStatus == DownloadStatus.InputDataError {
                                throw NetworkError.InputDataError
                            }
                            else {
                                throw GeneralErrors.GeneralError
                            }
                        }
                        catch {
                            if tries < 2 {
                                tries += 1
                            }
                            else {
                                tries += 1
                                throw error
                            }
                        }
                    }
                }
            }
            
            settings!.availableImages = tempAvailableImages!
            settings!.lastImageSyncedTime = Date()
            do {
                try writeSettingsToDisk(settings: settings!)
            }
            catch {
                throw GeneralErrors.DataWriteError
            }
        }
    }
    
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
        if url == nil {
            output = DownloadStatus.InputDataError
        }
        else {
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
        }
        
        return output
    }
    
    static func deleteImageFromDisk(fileName: String) {
        
        let imageDirectoryString = try? getImagesDirectory()
        if imageDirectoryString != nil {
            let imageDirectory = try? Folder(path: imageDirectoryString!)
            if imageDirectory != nil {
                let imageToDelete = try? imageDirectory!.file(at: fileName)
                if imageToDelete != nil {
                    try? imageToDelete!.delete()
                }
            }
        }
    }
    
    static func setWallpaper(fileName: String, screen: NSScreen) throws {
        
        var screensTemp = [NSScreen]()
        screensTemp.append(screen)
        
        let imageURL = URL(fileURLWithPath: try Utilities.getImagesDirectory() + "/" + fileName, isDirectory: false)
        try Wallpaper.set(imageURL, screen: .nsScreens(screensTemp))
        
        let settings = try? Utilities.readSettingsFromDisk()
        guard settings != nil else {
            throw GeneralErrors.DataReadError
        }
        
        let wallpaperScreen = ScreenWallpaper()
        wallpaperScreen.currentImage = fileName
        wallpaperScreen.screenName = screen.localizedName
        wallpaperScreen.lastRotatedTime = Date()
        
        settings!.screenWallpapers = settings!.screenWallpapers.filter { $0.screenName != screen.localizedName }
        settings!.screenWallpapers.append(wallpaperScreen)
        try Utilities.writeSettingsToDisk(settings: settings!)
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
