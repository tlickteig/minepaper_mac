//
//  MinePaperApp.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI

@main
struct MinePaperApp: App {
    @State var currentNumber: String = "1"
    @State private var isAutoRotating: Bool = false
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .frame(width: 800, height: 550)
                .toolbar {
                    AutoRotateSettings()
                }
                .onAppear {
                    _ = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { timer in
                        try? Utilities.backgroundAppRefresh()
                    }
                }
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra(currentNumber, systemImage: "photo.stack") {
            VStack {
                Text("MinePaper version \(AppInfo.versionName)")
                Button("Open main window") {
                    _ = Utilities.executeSchellScript(command: "open /Applications/MinePaper.app")
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
                Button("Quit") {
                    NSApplication.shared.terminate(self)
                }
            }
        }
    }
}
