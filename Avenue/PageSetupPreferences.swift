//
//  PageSetupPreferences.swift
//  Avenue
//
//  Created by Vincent Neo on 5/8/22.
//  Copyright © 2022 Vincent. All rights reserved.
//

import Foundation

let kDefaultsSelectedMapResolution: String = "PageSetupSelectedMapResolution"

class PageSetupPreferences {

    static let shared = PageSetupPreferences()
    
    private var _selectedMapResolution = 0
    
    /// UserDefaults.standard shortcut
    private let defaults = UserDefaults.standard
    
    /// Loads preferences from UserDefaults.
    private init() {
        //loads preferences into private vars
        if let selectedMapResolution = defaults.object(forKey: kDefaultsSelectedMapResolution) as? Int {
            _selectedMapResolution = selectedMapResolution
        }
    }
    
    var selectedMapResolution: Int {
        get {
            return _selectedMapResolution
        }
        set {
            _selectedMapResolution = newValue
            defaults.set(newValue, forKey: kDefaultsSelectedMapResolution)
        }
    }
    
}
