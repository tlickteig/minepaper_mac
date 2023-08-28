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
        if let minepaperApp = FileManager.default.urls(
                for: .applicationDirectory,
                in: .systemDomainMask
            ).first?.appendingPathComponent("MinePaper.app") {
                NSWorkspace.shared.open(minepaperApp)
            }
    }
}
