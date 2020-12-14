//
//  PreviewViewController.swift
//  GPXQuickLook
//
//  Created by Vincent Neo on 14/12/20.
//  Copyright © 2020 Vincent. All rights reserved.
//

import Cocoa
import Quartz
import MapKit
import CoreGPX

class MapView: MKMapView {
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

class PreviewViewController: NSViewController, QLPreviewingController, MKMapViewDelegate {
    
    @IBOutlet weak var elapsedView: NSVisualEffectView!
    @IBOutlet weak var distanceView: NSVisualEffectView!
    @IBOutlet weak var elapsedLabel: NSTextField!
    @IBOutlet weak var distanceLabel: NSTextField!
    @IBOutlet weak var mapView: MapView!
    
    enum PossibleErrors: Error {
        case fileIsNil
    }
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    override func loadView() {
        super.loadView()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        elapsedView.blendingMode = .withinWindow
        elapsedView.wantsLayer = true
        elapsedView.layer?.cornerRadius = 5
        elapsedView.layer?.masksToBounds = true
        
        distanceView.blendingMode = .withinWindow
        distanceView.wantsLayer = true
        distanceView.layer?.cornerRadius = 5
        distanceView.layer?.masksToBounds = true
    }

    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     *
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
     */
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
        
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        guard let parser = GPXParser(withURL: url) else { handler(PossibleErrors.fileIsNil); return }
        do {
            guard let gpx = try parser.fallibleParsedData(forceContinue: false) else { handler(PossibleErrors.fileIsNil); return }
            mapView.loadedGPXFile(gpx)
            let elapsedText = ElapsedTime.getString(from: mapView.timeInterval)
            let distanceText = mapView.length.toDistance(useImperial: false)
            if mapView.timeInterval == 0 {
                elapsedLabel.isHidden = true
            }
            else {
                elapsedLabel.stringValue = elapsedText
            }
            distanceLabel.stringValue = distanceText
            
        }
        catch {
            handler(error)
        }
        handler(nil)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)
            if #available(OSX 10.14, *) {
                if #available(OSX 10.15, *) {
                    pr.shouldRasterize = true
                }
                pr.strokeColor = NSColor.controlAccentColor //.withAlphaComponent(0.65)
            } else {
                pr.strokeColor = .blue
            }
            pr.alpha = 0.65
            pr.lineWidth = 5
            return pr
        }
        return MKOverlayRenderer()
    }
}

