//
//  PageSetupResolution.swift
//  Avenue
//
//  Created by Vincent Neo on 6/8/22.
//  Copyright © 2022 Vincent. All rights reserved.
//

import Foundation

enum PageSetupResolution: Int {
    case largest = 0
    case medium = 1
    case small = 2
    case smallest = 3
    
    var scale: Double {
        switch self {
        case .largest:
            return 1
        case .medium:
            return 1.5
        case .small:
            return 2
        case .smallest:
            return 3
        }
    }
    
    static var chosen: Self {
        let preferences = PageSetupPreferences.shared
        return PageSetupResolution(rawValue: preferences.selectedMapResolution)!
    }
    
    static var chosenScale: Double {
        return chosen.scale
    }
}
