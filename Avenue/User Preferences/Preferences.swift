//
//  Preferences.swift
//  Style from Open GPX Tracker
//

import Cocoa
import CoreLocation

let systemBlueColor = NSColor(red: 0.01, green: 0.47, blue: 1.00, alpha: 1.00)

let kAppGroup = "group.com.vincent-neo.Avenue"

let kDefaultsHideMiniMap: String = "HideMiniMap"

let kDefaultsEnableCache: String = "CacheSettings"

let kDefaultsPreferRetina: String = "PreferRetina"

let kDefaultsShowMapScale: String = "ShowMapScale"

let kDefaultsShowCursorCoordinates: String = "ShowCursorFollowerCoordinates"

let kDefaultsMapTileIndex: String = "MapTileIndex"

let kDefaultsDistanceUnitType: String = "DistanceUnitType"

/// A class to handle app preferences in one single place.
/// When the app starts for the first time the following preferences are set:
///
/// * useCache = true
/// * useImperial = whatever is set by current locale (NSLocale.usesMetricUnits) or false
/// * tileServer = .apple
///
class Preferences: NSObject {

    /// Shared preferences singleton.
    /// Usage:
    ///      var preferences: Preferences = Preferences.shared
    ///      print (preferences.useCache)
    ///
    static let shared = Preferences()
    
    private var _hideMiniMap: Bool = false
    private var _enableCache: Bool = true
    private var _preferRetina: Bool = true
    private var _showMapScale: Bool = true
    private var _showCursorCoordinates: Bool = false
    private var _defaultMapTile: Int = 0
    private var _distanceUnitType: Int = 0
    
    /// UserDefaults.standard shortcut
    private let defaults = UserDefaults.standard
    //private let appGroupDefaults = UserDefaults(suiteName: kAppGroup) ?? UserDefaults.standard
    
    /// Loads preferences from UserDefaults.
    private override init() {
        //loads preferences into private vars
        if let hideMiniMap = defaults.object(forKey: kDefaultsHideMiniMap) as? Bool {
            _hideMiniMap = hideMiniMap
        }
        
        if let enableCache = defaults.object(forKey: kDefaultsEnableCache) as? Bool {
            _enableCache = enableCache
        }
        
        if let preferRetina = defaults.object(forKey: kDefaultsPreferRetina) as? Bool {
            _preferRetina = preferRetina
        }
        
        if let showMapScale = defaults.object(forKey: kDefaultsShowMapScale) as? Bool {
            _showMapScale = showMapScale
        }
        
        if let showCursorCoordinates = defaults.object(forKey: kDefaultsShowCursorCoordinates) as? Bool {
            _showCursorCoordinates = showCursorCoordinates
        }
        
        if let defaultMapTileIndex = defaults.object(forKey: kDefaultsMapTileIndex) as? Int {
            _defaultMapTile = defaultMapTileIndex
        }
        
        if let distanceUnitType = defaults.object(forKey: kDefaultsDistanceUnitType) as? Int {
            _distanceUnitType = distanceUnitType
        }
    }
    
    var hideMiniMap: Bool {
        get {
            return _hideMiniMap
        }
        set {
            _hideMiniMap = newValue
            defaults.set(newValue, forKey: kDefaultsHideMiniMap)
        }
    }
    
    var enableCache: Bool {
        get {
            return _enableCache
        }
        set {
            _enableCache = newValue
            defaults.set(newValue, forKey: kDefaultsEnableCache)
        }
    }
    
    var preferRetina: Bool {
        get {
            return _preferRetina
        }
        set {
            _preferRetina = newValue
            defaults.set(newValue, forKey: kDefaultsPreferRetina)
        }
    }
    
    var showMapScale: Bool {
        get {
            return _showMapScale
        }
        set {
            _showMapScale = newValue
            defaults.set(newValue, forKey: kDefaultsShowMapScale)
        }
    }
    
    var mapTileIndex: Int {
        get {
            return _defaultMapTile
        }
        set {
            _defaultMapTile = newValue
            defaults.set(newValue, forKey: kDefaultsMapTileIndex)
        }
    }
    
    var distanceUnitTypeInt: Int {
        get {
            return _distanceUnitType
        }
        set {
            _distanceUnitType = newValue
            NotificationCenter.default.post(Notification(name: Notification.Name("DistanceUnitChanged")))
            defaults.set(newValue, forKey: kDefaultsDistanceUnitType)
        }
    }
    
    var distanceUnitType: Double.DistanceUnitTypes {
        get {
            return Double.DistanceUnitTypes(rawValue: _distanceUnitType)!
        }
        set {
            _distanceUnitType = newValue.rawValue
            NotificationCenter.default.post(Notification(name: Notification.Name("DistanceUnitChanged")))
            defaults.set(newValue.rawValue, forKey: kDefaultsDistanceUnitType)
        }
    }
    
    var showCursorCoordinates: Bool {
        get {
            return _showCursorCoordinates
        }
        set {
            _showCursorCoordinates = newValue
            defaults.set(newValue, forKey: kDefaultsShowCursorCoordinates)
        }
    }
}
