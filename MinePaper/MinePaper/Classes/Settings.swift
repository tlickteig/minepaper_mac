//
//  Settings.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/7/23.
//

import Foundation

class Settings {
    
    private var _availableImages: [String] = [String]()
    var availableImages: [String] {
        set {
            _availableImages = newValue
        }
        get {
            return _availableImages
        }
    }
    
    private var _lastImageSyncedTime: Date = Date.distantPast
    var lastImageSyncedTime: Date {
        set {
            _lastImageSyncedTime = newValue
        }
        get {
            return _lastImageSyncedTime
        }
    }
}

class ScreenWallpaper {

    private var _currentImage: String = ""
    var currentImage: String {
        set {
            _currentImage = newValue
        }
        get {
            return _currentImage
        }
    }
    
    private var _isRotating: Bool = false
    var isRotating: Bool {
        set {
            _isRotating = newValue
        }
        get {
            return _isRotating
        }
    }
    
    private var _lastRotatedTime: Date = Date.distantPast
    var lastRotatedTime: Date {
        set {
            _lastRotatedTime = newValue
        }
        get {
            return _lastRotatedTime
        }
    }
    
    private var _autoRotateMinutes: Int = 0
    var autoRotateMinutes: Int {
        set {
            _autoRotateMinutes = newValue
        }
        get {
            return _autoRotateMinutes
        }
    }
}
