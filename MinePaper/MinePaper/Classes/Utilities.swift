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
        
        var availableImages = try? scanImagesDirectory()
        guard availableImages != nil else {
            throw GeneralErrors.DataReadError
        }
        
        let serverFileList = try? getImageListFromServer()
        guard serverFileList != nil else {
            throw NetworkError.GeneralError
        }
        
        if serverFileList!.count > 0 {
            
            for imageName in availableImages! {
                
                if !serverFileList!.contains(imageName) {
                    deleteImageFromDisk(fileName: imageName)
                }
            }
            
            availableImages = try? scanImagesDirectory()
            guard availableImages != nil else {
                throw GeneralErrors.DataReadError
            }
            
            while availableImages!.count > Constants.maxImages {
                let imageToDelete = availableImages!.randomElement()
                deleteImageFromDisk(fileName: imageToDelete!)
                availableImages = availableImages!.filter { $0 != imageToDelete! }
            }
            
            let numImagesToDownload = Int.random(in: Constants.minImagesToDownload..<Constants.maxImagesToDownload)
            var imagesDownloaded = 0
            var tries = 0
            var loopCount = 0
            
            while serverFileList!.count != availableImages!.count && imagesDownloaded < numImagesToDownload {
                
                loopCount += 1
                let imageToDownload = serverFileList!.randomElement()
                if !availableImages!.contains(imageToDownload!)
                {
                    do {
                        
                        if availableImages!.count > Constants.maxImages {
                            let imageToDelete = availableImages!.randomElement()
                            deleteImageFromDisk(fileName: imageToDelete!)
                            availableImages = availableImages!.filter { $0 != imageToDelete! }
                        }
                        
                        let downloadStatus = downloadImageFromServer(fileName: imageToDownload!)
                        availableImages!.append(imageToDownload!)
                        if downloadStatus == DownloadStatus.Success {
                            imagesDownloaded += 1
                        }
                        else if downloadStatus == DownloadStatus.NetworkError {
                            throw NetworkError.GeneralError
                        }
                        else if downloadStatus == DownloadStatus.InputDataError {
                            throw NetworkError.InputDataError
                        }
                        else if downloadStatus == DownloadStatus.FileWriteError {
                            throw GeneralErrors.DataWriteError
                        }
                    }
                    catch {
                        if tries > Constants.maxTries {
                            throw error
                        }
                        else {
                            tries += 1
                        }
                    }
                }
            }
            
            availableImages = try? scanImagesDirectory()
            guard availableImages != nil else {
                throw GeneralErrors.DataReadError
            }
            
            settings!.availableImages = availableImages!
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
        
        do {
            let imagesDirectory = try getImagesDirectory()
            let imagesFolder = try Folder(path: imagesDirectory)
            
            var output = [String]()
            let validExtensions = ["jpg", "png", "jpeg", "JPG", "PNG", "JPEG"]
            
            imagesFolder.files.enumerated().forEach { (index, file) in
                if validExtensions.contains(file.extension!) {
                    output.append(file.name)
                }
            }
            
            return output
        }
        catch {
            logErrorToDisk(error: error, methodName: #function)
            throw GeneralErrors.DataReadError
        }
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
            logErrorToDisk(error: error, methodName: #function)
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
                    do {
                        let originFile = try File(path: localURL.path)
                        try originFile.rename(to: fileName, keepExtension: false)
                        localURL.deleteLastPathComponent()
                        
                        let imageFile = try File(path: localURL.path + "/" + fileName)
                        let destinationFolder = try Folder(path: getImagesDirectory())
                        try imageFile.copy(to: destinationFolder)
                        
                        var filesToDelete = try FileManager.default.contentsOfDirectory(at: URL(string: localURL.path)!, includingPropertiesForKeys: nil)
                        filesToDelete = filesToDelete.filter { !$0.hasDirectoryPath }
                        
                        for file in filesToDelete {
                            let fileToDelete = try File(path: file.path)
                            try fileToDelete.delete()
                        }
                    }
                    catch {
                        logErrorToDisk(error: error, methodName: #function)
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
                else {
                    logErrorToDisk(error: GeneralErrors.DataWriteError, methodName: #function)
                }
            }
            else {
                logErrorToDisk(error: GeneralErrors.DataWriteError, methodName: #function)
            }
        }
        else {
            logErrorToDisk(error: GeneralErrors.DataWriteError, methodName: #function)
        }
    }
    
    static func setWallpaper(fileName: String, screen: NSScreen) throws {
        
        var screensTemp = [NSScreen]()
        screensTemp.append(screen)
        
        let imageURL = URL(fileURLWithPath: try Utilities.getImagesDirectory() + "/" + fileName, isDirectory: false)
        try Wallpaper.set(imageURL, screen: .nsScreens(screensTemp))
        
        let settings = try? Utilities.readSettingsFromDisk()
        guard settings != nil else {
            logErrorToDisk(error: GeneralErrors.DataReadError, methodName: #function)
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
    
    // Heavily based off of: https://stackoverflow.com/questions/44537133/how-to-write-application-logs-to-file-and-get-them
    static func logErrorToDisk(error: Error, methodName: String) {
        
        let logData = "\n\(error.localizedDescription) Location: \(methodName)"
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("error.log")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(logData.data(using: .utf8)!)
            handle.closeFile()
        }
        else {
            try? logData.data(using: .utf8)?.write(to: log)
        }
    }
    
    //Data directory is usually: /Users/<user>/Library/Containers/<app name>/Data/Library/
    static func getDataDirectory() throws -> String {
        let url = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url.path
    }
    
    static func getImagesDirectory() throws -> String {
        let url = try getDataDirectory() + "/Images"
        return url
    }
}
