//
//  UIObjects.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/9/23.
//

import Foundation

class RotateFrequency: Identifiable {
    
    private var _rotateFrequencyMinutes: Int = 0
    var rotateFrequencyMinutes: Int {
        set {
            _rotateFrequencyMinutes = newValue
        }
        get {
            return _rotateFrequencyMinutes
        }
    }
    
    private var _label: String = ""
    var label: String {
        set {
            _label = newValue
        }
        get {
            return _label
        }
    }
}

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
