//
//  MinePaperApp.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI

@main
struct MinePaperApp: App {
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .frame(width: 800, height: 550)
                .toolbar {
                    AutoRotateSettings()
                }
        }
        .windowResizability(.contentSize)
    }
}
