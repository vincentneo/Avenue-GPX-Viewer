//
//  QLMapView.swift
//  GPXQuickLook
//
//  Created by Vincent Neo on 15/12/20.
//  Copyright © 2020 Vincent. All rights reserved.
//

import MapKit
import CoreGPX

class QLMapView: MKMapView {
    var extent = GPXExtentCoordinates()
    var length = 0.0
    var timeInterval = 0.0
    
    func loadedGPXFile(_ root: GPXRoot) {
        print("MapView: GPX Object Loaded \(root)")
        for track in root.tracks {
            for trackseg in track.tracksegments {
                length += trackseg.length()
            }
            for trackseg in track.tracksegments {
                guard let startTime = trackseg.trackpoints.first?.time,
                    let endTime = trackseg.trackpoints.last?.time else { continue }
                let timeBetween = endTime.timeIntervalSince(startTime)
                timeInterval += timeBetween
            }
        }
        
        for waypoint in root.waypoints {
            self.addAnnotation(waypoint)
        }
        
        for track in root.tracks {
            for segment in track.tracksegments {
                let overlay = segment.overlay

                self.addOverlay(overlay, level: .aboveLabels)
                
                for trkpt in segment.trackpoints {
                    self.extent.extendAreaToIncludeLocation(trkpt.coordinate)
                }
            }
        }
        // reduce region span being too close to bounds of view
        extent.region.span.latitudeDelta *= 1.25
        extent.region.span.longitudeDelta *= 1.25
        
        self.setRegion(extent.region, animated: true)
        
    }
}
