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

class MapView: MKMapView {
    
    //weak var documentDelegate: DocumentDelegate?
    
    func loadedGPXFile(_ root: GPXRoot) {
        print("GPX File Loaded")
        print(root)
        
        for waypoint in root.waypoints {
            self.addAnnotation(waypoint)
        }
        
        for track in root.tracks {
            for segment in track.tracksegments {
                let overlay = segment.overlay
                //self.addOverlay(overlay)
                self.addOverlay(overlay, level: .aboveLabels)
            }
        }
    }
    
    
    
}
