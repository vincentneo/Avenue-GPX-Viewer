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
    
    var extent = GPXExtentCoordinates()
    
    func loadedGPXData(_ data: Data, _ windowCon: WindowController) {
        let indicator = NSProgressIndicator(frame: self.frame)
        let visualView = NSVisualEffectView(frame: self.frame)
        visualView.blendingMode = .withinWindow
        visualView.material = .popover

        indicator.style = .spinning
        indicator.startAnimation(self)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            // UI start parse indication
            DispatchQueue.main.sync {
                self.setUserInteraction(state: false)
                self.addSubview(visualView)
                self.addSubview(indicator)
                indicator.translatesAutoresizingMaskIntoConstraints = false
                visualView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
                NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
                NSLayoutConstraint(item: visualView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0).isActive = true
                NSLayoutConstraint(item: visualView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0).isActive = true
            }

            // Parsing. Async as it may take a long time, dependent on file.
            let fileGPX = GPXParser(withData: data).parsedData()
            
            // UI end parse release
            DispatchQueue.main.sync {
                self.setUserInteraction(state: true)
                indicator.removeFromSuperview()
                visualView.removeFromSuperview()
                indicator.stopAnimation(self)
                guard let fileGPX = fileGPX else { return }
                var length = 0.0
                for track in fileGPX.tracks {
                    for trackseg in track.tracksegments {
                        length += trackseg.length()
                    }
                }
                windowCon.barDistance.stringValue = length.toDistance(useImperial: false)
                self.loadedGPXFile(fileGPX)
            }

        }
    }
    
    func loadedGPXFile(_ root: GPXRoot) {
        print("MapView: GPX Object Loaded \(root)")
        
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
        self.setRegion(extent.region, animated: true)
        
    }
    
    /// Sets all user interactable UI enabledness based on state parameter.
    func setUserInteraction(state: Bool) {
        self.isZoomEnabled = state
        self.isPitchEnabled = state
        self.isRotateEnabled = state
        self.isScrollEnabled = state
    }
    
}

