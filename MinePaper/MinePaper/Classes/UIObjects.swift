//
//  UIObjects.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/9/23.
//

import Foundation

class WallpaperOption: Identifiable {
    
    init(imageName: String) {
        _imageName = imageName
    }
    
    private var _imageName: String = ""
    var imageName: String {
        set {
            _imageName = newValue
        }
        get {
            return _imageName
        }
    }
    
    var fullImagePath: String {
        get {
            return (try? Utilities.getImagesDirectory() + "/" + _imageName) ?? ""
        }
    }
}
