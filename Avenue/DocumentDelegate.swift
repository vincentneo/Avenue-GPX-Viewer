//
//  DocumentDelegate.swift
//  Avenue
//
//  Created by Vincent on 29/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import CoreGPX

protocol DocumentDelegate: class {
    
    func loadedGPXFile(_ root: GPXRoot)
    
}
