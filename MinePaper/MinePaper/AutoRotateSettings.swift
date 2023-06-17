//
//  AutoRotateSettings.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/15/23.
//

import SwiftUI

struct AutoRotateSettings: View {
    
    @State private var toggled: Bool = false
    
    @State private var rotateOptions: [String]
    @State private var rotateValues: [Int]
    @State private var selectedRotateOption: String
    
    init() {
        rotateOptions = ["30 Minutes", "1 Hour", "2 Hours", "5 Hours", "12 Hours", "1 Day"]
        rotateValues = [30, 60, 120, 300, 720, 1440]
        selectedRotateOption = "30 Minutes"
    }
    
    var body: some View {
        HStack {
            Text("Auto Rotate:")
            Toggle("", isOn: $toggled)
            .toggleStyle(.switch)
            .labelsHidden()
            .onChange(of: toggled) { value in
                let settings = try? Utilities.readSettingsFromDisk()
                if settings != nil {
                    settings!.isRotating = toggled
                    try? Utilities.writeSettingsToDisk(settings: settings!)
                }
            }
            
            Picker(selection: $selectedRotateOption, label: Text("Rotate every: ")) {
                ForEach(rotateOptions, id: \.self) { rotateOption in
                    Text(rotateOption)
                }
            }
            .onChange(of: selectedRotateOption) { value in
                let index = rotateOptions.firstIndex(of: value)!
                let numberOfMinutes = rotateValues[index]
                
                let settings = try? Utilities.readSettingsFromDisk()
                if settings != nil {
                    settings!.autoRotateMinutes = numberOfMinutes
                    try? Utilities.writeSettingsToDisk(settings: settings!)
                }
            }
            .disabled(!toggled)
        }
        .onAppear {
            let settings = try? Utilities.readSettingsFromDisk()
            if settings != nil {
                toggled = settings!.isRotating
                
                let index = rotateValues.firstIndex(of: settings!.autoRotateMinutes)
                if index != nil {
                    selectedRotateOption = rotateOptions[index!]
                }
            }
        }
    }
}

struct AutoRotateSettings_Previews: PreviewProvider {
    static var previews: some View {
        AutoRotateSettings()
    }
}
