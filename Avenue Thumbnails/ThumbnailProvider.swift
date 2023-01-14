//
//  ThumbnailProvider.swift
//  Avenue Thumbnails
//
//  Created by Vincent Neo on 13/1/23.
//  Copyright © 2023 Vincent. All rights reserved.
//

import QuickLookThumbnailing
import MapKit
import CoreGPX

class ThumbnailProvider: QLThumbnailProvider {

    func prepareExtent(from gpx: GPXRoot) -> GPXExtentCoordinates {
        let extent = GPXExtentCoordinates()
        for route in gpx.routes {
            for point in route.points {
                extent.extendAreaToIncludeLocation(point.coordinate)
            }
        }
        
        for track in gpx.tracks {
            for segment in track.segments {
                for point in segment.points {
                    extent.extendAreaToIncludeLocation(point.coordinate)
                }
            }
        }
        
        for waypoint in gpx.waypoints {
            extent.extendAreaToIncludeLocation(waypoint.coordinate)
        }
        return extent
    }
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        // There are three ways to provide a thumbnail through a QLThumbnailReply. Only one of them should be used.
        
        // First way: Draw the thumbnail into the current context, set up with UIKit's coordinate system.
        guard let parser = GPXParser(withURL: request.fileURL), let gpx = parser.parsedData() else {
            handler(nil, GPXError.parser.fileIsEmpty)
            return
        }
        
        let extent = self.prepareExtent(from: gpx)
        
        let options = MKMapSnapshotter.Options()
        options.region = extent.region
        options.size = request.maximumSize
        if #available(macOS 10.14, *) {
            options.appearance = NSAppearance(named: .aqua)
        }
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            let drawer = MKSnapshotDrawer(snapshot!, gpx: gpx)
            let newImage = drawer.processImage()

            handler(QLThumbnailReply(contextSize: request.maximumSize, currentContextDrawing: { () -> Bool in
                // Draw the thumbnail here.
                newImage.draw(in: NSRect(origin: .zero, size: request.maximumSize))
                // Return true if the thumbnail was successfully drawn inside this block.
                return true
            }), nil)
        }
        
        /*
        
        // Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics's coordinate system.
        handler(QLThumbnailReply(contextSize: request.maximumSize, drawing: { (context) -> Bool in
            // Draw the thumbnail here.
         
            // Return true if the thumbnail was successfully drawn inside this block.
            return true
        }), nil)
         
        // Third way: Set an image file URL.
        handler(QLThumbnailReply(imageFileURL: Bundle.main.url(forResource: "fileThumbnail", withExtension: "jpg")!), nil)
        
        */
    }
}
