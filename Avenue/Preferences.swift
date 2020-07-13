//
//  Preferences.swift
//  Style from Open GPX Tracker
//

import Foundation
import CoreLocation

let kDefaultsHideMiniMap: String = "HideMiniMap"

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
    
    /// UserDefaults.standard shortcut
    private let defaults = UserDefaults.standard
    
    /// Loads preferences from UserDefaults.
    private override init() {
        //loads preferences into private vars
        if let hideMiniMap = defaults.object(forKey: kDefaultsHideMiniMap) as? Bool {
            _hideMiniMap = hideMiniMap
        }
        
    }
    
    /// If true, user prefers to display imperial units (miles, feets). Otherwise metric units
    /// are displayed.
    var hideMiniMap: Bool {
        get {
            return _hideMiniMap
        }
        set {
            _hideMiniMap = newValue
            defaults.set(newValue, forKey: kDefaultsHideMiniMap)
        }
    }
    
}
