//
//  AppInfo.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 8/30/23.
//

import Foundation

class AppInfo {
    
    static var versionName: String {
        get {
            return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        }
    }
}
