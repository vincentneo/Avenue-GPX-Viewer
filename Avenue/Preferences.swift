//
//  Preferences.swift
//  Style from Open GPX Tracker
//

import Foundation
import CoreLocation

let kDefaultsShowMiniMap: String = "ShowMiniMap"

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
    
    private var _showMiniMap: Bool = true
    
    /// UserDefaults.standard shortcut
    private let defaults = UserDefaults.standard
    
    /// Loads preferences from UserDefaults.
    private override init() {
        //loads preferences into private vars
        if let showMiniMap = defaults.object(forKey: kDefaultsShowMiniMap) as? Bool {
            _showMiniMap = showMiniMap
        }
        
    }
    
    /// If true, user prefers to display imperial units (miles, feets). Otherwise metric units
    /// are displayed.
    var showMiniMap: Bool {
        get {
            return _showMiniMap
        }
        set {
            _showMiniMap = newValue
            defaults.set(newValue, forKey: kDefaultsShowMiniMap)
        }
    }
    
}
