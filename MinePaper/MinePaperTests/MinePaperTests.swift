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
        do {
            throw GeneralErrors.GeneralError
        }
        catch {
            print(#function)
            Utilities.logErrorToDisk(error: error, methodName: #function)
        }
    }
}
