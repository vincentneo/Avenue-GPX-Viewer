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
        for route in root.routes {
            let overlay = route.overlay
            self.addOverlay(overlay, level: .aboveLabels)
            for point in route.points {
                self.extent.extendAreaToIncludeLocation(point.coordinate)
            }
            
            length += route.length()
            guard let startTime = route.points.first?.time,
                  let endTime = route.points.last?.time else { continue }
            let timeBetween = endTime.timeIntervalSince(startTime)
            timeInterval += timeBetween
        }
        
        for waypoint in root.waypoints {
            self.addAnnotation(waypoint)
        }
        
        for track in root.tracks {
            for segment in track.segments {
                let overlay = segment.overlay
                length += segment.length()

                self.addOverlay(overlay, level: .aboveLabels)
                
                for trkpt in segment.points {
                    self.extent.extendAreaToIncludeLocation(trkpt.coordinate)
                }
                
                guard let startTime = segment.points.first?.time,
                      let endTime = segment.points.last?.time else { continue }
                let timeBetween = endTime.timeIntervalSince(startTime)
                timeInterval += timeBetween
            }
        }
        // reduce region span being too close to bounds of view
        extent.region.span.latitudeDelta *= 1.25
        extent.region.span.longitudeDelta *= 1.25
        
        self.setRegion(extent.region, animated: true)
        
    }
}
