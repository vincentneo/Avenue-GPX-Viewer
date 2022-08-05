//
//  MKSnapshotDrawer.swift
//  Avenue
//
//  Created by Vincent Neo on 5/8/22.
//  Copyright © 2022 Vincent. All rights reserved.
//

import Cocoa
import MapKit
import CoreGPX

class MKSnapshotDrawer {
    let snapshot: MKMapSnapshotter.Snapshot
    let gpx: GPXRoot
    
    init(_ snapshot: MKMapSnapshotter.Snapshot, gpx: GPXRoot) {
        self.snapshot = snapshot
        self.gpx = gpx
    }
    
    func processImage() -> NSImage {
        let image = snapshot.image
        
        let allTrackSegments = self.gpx.tracks.reduce(into: ([GPXTrackSegment]())) { partialResult, track in
            partialResult.append(contentsOf: track.tracksegments)
        }
        let allCoordinates = allTrackSegments.map({
            $0.trackpoints.map({$0.coordinate})
        })
        let allPoints = allCoordinates.map({
            $0.map({ snapshot.point(for: $0) })
        })
        
        image.lockFocus()
        
        for lineSet in allPoints {
            let path = NSBezierPath()
            path.lineJoinStyle = .round
            if let firstPoint = lineSet.first {
                path.move(to: firstPoint)
                
                for point in lineSet.dropFirst() {
                    path.line(to: point)
                }
            }
            
            path.lineWidth = 2
            NSColor.red.withAlphaComponent(0.5).setStroke()
            path.stroke()
        }
        
        guard let pinImage = NSImage(named: "avenue-pin") else { image.unlockFocus(); return image }
        let size = pinImage.size
        
        for waypoint in gpx.waypoints {
            var point = snapshot.point(for: waypoint.coordinate)
            point.x -= size.width / 2
            point.y -= size.height / 2
            pinImage.draw(at: point, from: NSRect(origin: .zero, size: image.size), operation: .sourceOver, fraction: 1)
        }
        
        image.unlockFocus()
        return image
        
    }
    
}
