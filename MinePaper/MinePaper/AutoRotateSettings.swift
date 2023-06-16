//
//  AutoRotateSettings.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/15/23.
//

import SwiftUI

struct AutoRotateSettings: View {
    
    @State private var toggled: Bool = false
    
    var body: some View {
        HStack {
            Text("Auto Rotate Background:")
            Toggle("", isOn: $toggled)
            .toggleStyle(.switch)
            .labelsHidden()
            .onChange(of: toggled) { value in
                let settings = try? Utilities.readSettingsFromDisk()
                settings!.isRotating = toggled
                try? Utilities.writeSettingsToDisk(settings: settings!)
            }
        }
        .onAppear {
            let settings = try? Utilities.readSettingsFromDisk()
            if settings != nil {
                toggled = settings!.isRotating
            }
        }
    }
}

struct AutoRotateSettings_Previews: PreviewProvider {
    static var previews: some View {
        AutoRotateSettings()
    }
}
