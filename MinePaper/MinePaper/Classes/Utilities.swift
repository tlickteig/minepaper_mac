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
