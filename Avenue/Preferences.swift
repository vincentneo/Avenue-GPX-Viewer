//
//  Preferences.swift
//  Style from Open GPX Tracker
//

import Foundation
import CoreLocation

let kAppGroup = "group.com.vincent-neo.Avenue"

let kDefaultsHideMiniMap: String = "HideMiniMap"

let kDefaultsEnableCache: String = "CacheSettings"

let kDefaultsPreferRetina: String = "PreferRetina"

let kDefaultsShowMapScale: String = "ShowMapScale"

let kDefaultsMapTileIndex: String = "MapTileIndex"

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
    private var _defaultMapTile: Int = 0
    
    /// UserDefaults.standard shortcut
    private let defaults = UserDefaults.standard
    private let appGroupDefaults = UserDefaults(suiteName: kAppGroup) ?? UserDefaults.standard
    
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
        
        if let defaultMapTileIndex = appGroupDefaults.object(forKey: kDefaultsMapTileIndex) as? Int {
            _defaultMapTile = defaultMapTileIndex
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
    
    var mapTile: GPXTileServer {
        get {
            return GPXTileServer(rawValue: _defaultMapTile) ?? .apple
        }
        set {
            let index = newValue.rawValue
            _defaultMapTile = index
            appGroupDefaults.set(index, forKey: kDefaultsMapTileIndex)
        }
    }
    
}
