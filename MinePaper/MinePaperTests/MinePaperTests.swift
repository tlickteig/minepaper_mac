//
//  MinePaperTests.swift
//  MinePaperTests
//
//  Created by Timothy Lickteig on 6/4/23.
//

import XCTest
@testable import MinePaper

final class MinePaperTests: XCTestCase {

    override func setUpWithError() throws {
        
    }
    
    func testDownloadImage() {
        Utilities.downloadImageFromServer(fileName: "ZlwPHMV-best-1080p-wallpapers.jpg")
    }
}
