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
                    Constants.localImagesFolder = localURL.path
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
    
    static func setWallpaper(fileName: String, screen: Wallpaper.Screen) {
        
        let imageURL = URL(fileURLWithPath: Constants.localImagesFolder + "/" + fileName, isDirectory: false)
        try! Wallpaper.set(imageURL, screen: screen)
    }
}
