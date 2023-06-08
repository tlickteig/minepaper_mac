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
        var fileList = try? Utilities.getImageListFromServer()
        for file in fileList! {
            print(file)
        }
    }
}
