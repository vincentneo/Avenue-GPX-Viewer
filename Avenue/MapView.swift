//
//  MapView.swift
//  Avenue
//
//  Created by Vincent on 8/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa
import MapKit
import CoreGPX

class MapView: MKMapView, DocumentDelegate {
    func loadedGPXFile(_ root: GPXRoot) {
        print("GPX File Loaded")
        print(root)
    }
    
    
    
}
