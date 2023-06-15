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
        /*NSScreen.screens.forEach {
            var imagePath = "38dU0UH-best-1080p-wallpaper.jpg"
            
            var screens: [NSScreen] = [NSScreen]()
            screens.append($0)
            
            try? Wallpaper.set(URL(string: imagePath)!, screen: .nsScreens(screens))
        }*/
        //Utilities.deleteImageFromDisk(fileName: "KQFzzn6-best-1080p-wallpaper.jpg")
        try? Utilities.syncImagesWithServer()
    }
}
