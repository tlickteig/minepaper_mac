//
//  MinePaperTests.swift
//  MinePaperTests
//
//  Created by Timothy Lickteig on 6/4/23.
//

import XCTest
import Wallpaper

@testable import MinePaper

final class MinePaperTests: XCTestCase {

    override func setUpWithError() throws {
        
    }
    
    func testDownloadImage() {
        //let filename = "KQFzzn6-best-1080p-wallpaper.jpg"
        //Utilities.downloadImageFromServer(fileName: filename)
        //Utilities.setWallpaper(fileName: filename, screen: Wallpaper.Screen.index(1))
        /*var fileList = try? Utilities.getImageListFromServer()
        for file in fileList! {
            print(file)
        }*/
        
        
        //print(fm)
        
        /*let wallpaper1 = ScreenWallpaper()
        wallpaper1.autoRotateMinutes = 30
        wallpaper1.currentImage = "KQFzzn6-best-1080p-wallpaper.jpg"
        wallpaper1.isRotating = true
        wallpaper1.lastRotatedTime = Date.distantPast
        
        let wallpaper2 = ScreenWallpaper()
        wallpaper2.autoRotateMinutes = 60
        wallpaper2.currentImage = "KQFzzn6-best-1080p-wallpaper.jpg2"
        wallpaper2.isRotating = false
        wallpaper2.lastRotatedTime = Date.distantFuture
        
        let settings = Settings()
        settings.availableImages = try! Utilities.getImageListFromServer() ?? [String]()
        settings.lastImageSyncedTime = Date.now
        settings.screenWallpapers.append(wallpaper1)
        settings.screenWallpapers.append(wallpaper2)
        
        try? Utilities.writeSettingsToDisk(settings: settings)*/
        //let settings = try? Utilities.readSettingsFromDisk()
        //print(settings)
        
        try? Utilities.scanImagesDirectory()
    }
}
