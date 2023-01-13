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
    
    var document: Document? {
        return self.window?.windowController?.document as? Document
    }
    
    private var trackLength = 0.0
    private var trackDuration = 0.0
    
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
                windowCon.contentViewController?.view.addSubview(visualView)
                windowCon.contentViewController?.view.addSubview(indicator)
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
                var timeInterval = 0.0
                for track in fileGPX.tracks {
                    for trackseg in track.segments {
                        length += trackseg.length()
                    }
                    for trackseg in track.segments {
                        guard let startTime = trackseg.points.first?.time,
                              let endTime = trackseg.points.last?.time else { continue }
                        let timeBetween = endTime.timeIntervalSince(startTime)
                        timeInterval += timeBetween
                    }
                }
                
                for route in fileGPX.routes {
                    length += route.length()
                    guard let startTime = route.points.first?.time,
                          let endTime = route.points.last?.time else { continue }
                    let timeBetween = endTime.timeIntervalSince(startTime)
                    timeInterval += timeBetween
                }
                
                self.trackLength = length
                self.trackDuration = timeInterval
                
                self.updateBarInfo()

                self.document?.gpx = fileGPX
                self.loadedGPXFile()
                NotificationCenter.default.post(Notification(name: Notification.Name("GPXFileFinishedLoading")))
            }

        }
    }
    
    func updateBarInfo() {
        let timeText = self.trackDuration > 0 ? "\(ElapsedTime.getString(from: self.trackDuration))｜": ""
        if let windowController = window?.windowController as? WindowController {
            windowController.barDistance.stringValue = "\(timeText)\(self.trackLength.toDistance(type: Preferences.shared.distanceUnitType))"
        }
    }
    
    func loadedGPXFile() {
        guard let document = document, let root = document.gpx else { fatalError("this shouldn't happen...") }
        document.extent = .init()
        
        print("MapView: GPX Object Loaded \(root)")
        
        for waypoint in root.waypoints {
            self.addAnnotation(waypoint)
        }
        
        for track in root.tracks {
            for segment in track.segments {
                let overlay = segment.overlay

                self.addOverlay(overlay, level: .aboveLabels)
                
                for trkpt in segment.points {
                    document.extent.extendAreaToIncludeLocation(trkpt.coordinate)
                }
            }
        }
        
        for route in root.routes {
            let overlay = route.overlay
            self.addOverlay(overlay, level: .aboveLabels)
            for point in route.points {
                document.extent.extendAreaToIncludeLocation(point.coordinate)
            }
        }
        
        for waypoint in root.waypoints {
            document.extent.extendAreaToIncludeLocation(waypoint.coordinate)
        }
        // reduce region span being too close to bounds of view
        document.extent.region.span.latitudeDelta *= 1.25
        document.extent.region.span.longitudeDelta *= 1.25
        
        self.setRegion(document.extent.region, animated: true)
        
    }
    
    /// Sets all user interactable UI enabledness based on state parameter.
    func setUserInteraction(state: Bool) {
        self.isZoomEnabled = state
        self.isPitchEnabled = state
        self.isRotateEnabled = state
        self.isScrollEnabled = state
    }
    
}

