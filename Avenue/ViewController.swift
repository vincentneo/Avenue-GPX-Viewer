//
//  ViewController.swift
//  Avenue
//
//  Created by Vincent on 7/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa
import MapKit
import CoreGPX

class ViewController: NSViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MapView!
    
    let miniMap = MKMapView()
    
    /// Mini Map's zoom out boundaries reached: point of no zooming
    var mmBoundsReached = false
    
    var box = NSView(frame: NSRect.zero)
    
    /// Mini Map's should be hidden or not, by settings.
    var mmHidden = false
    
    var height = CGFloat.zero
    var width = CGFloat.zero
    var heightConstraints = NSLayoutConstraint()
    var widthConstraints = NSLayoutConstraint()
    
    let segments = NSSegmentedControl(labels: ["Standard", "Satellite", "Hybrid"], trackingMode: .selectOne, target: nil, action: #selector(segmentControlDidChange(_:)))
    
    // improve perf
    var skipCounter = 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
        miniMap.autoresizingMask = .none
        let kSize: CGFloat = 135
        let view = NSView(frame: NSRect(x: 10, y: mapView.frame.minY + 10, width: kSize, height: kSize))
        miniMap.frame = NSRect(x: 0, y: 0, width: kSize, height: kSize)
        view.addSubview(miniMap)
        mapView.addSubview(view)
        //miniMap.delegate = mmDelegate
        
        self.view.addSubview(segments)
        segments.selectedSegment = 0
        if #available(OSX 10.16, *) {
            // looks better for Big Sur, though can be better for visibility.
            segments.segmentStyle = .rounded
            
        }
        else {
            segments.segmentStyle = .texturedRounded
        }
        //segments.frame = CGRect(x: 3, y: mapView.frame.height, width: segments.frame.width, height: segments.frame.height)
        // it will be weird to have legal text on both map views
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = miniMap.subviews.filter({ $0.isKind(of: textClass) }).first {
            mapText.isHidden = true
        }
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = mapView.subviews.filter({ $0.isKind(of: textClass) }).first {
            segments.frame = segments.frame.offsetBy(dx: 3, dy: mapText.frame.height + 3)
        }
        
        // disable user interaction on mini map
        miniMap.isZoomEnabled = false
        miniMap.isScrollEnabled = false
        
        miniMap.wantsLayer = true

        if #available(OSX 10.13, *) {
            miniMap.layer?.borderColor = NSColor(named: NSColor.Name("MiniMapBorder"))?.cgColor
        } else {
            miniMap.layer?.borderColor = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).cgColor
        }
        miniMap.layer?.borderWidth = 1
        miniMap.layer?.cornerRadius = 10
        miniMap.layer?.opacity = 0.9
        
        width = mapView.frame.width / 10
        height = mapView.frame.height / 10
        //let height:CGFloat = 150//(miniMap.frame.width / mapView.frame.width) * miniMap.frame.width
        //let width:CGFloat = 40 //(miniMap.frame.height / mapView.frame.height) * miniMap.frame.height
            //print(width, height)

        box.wantsLayer = true
        if #available(OSX 10.14, *) {
            box.layer?.borderColor = NSColor.controlAccentColor.cgColor
        } else {
            box.layer?.borderColor = NSColor.blue.cgColor
        }
        box.layer?.borderWidth = 2
        miniMap.addSubview(box)
        
        box.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: box, attribute: .centerX, relatedBy: .equal, toItem: miniMap, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: box, attribute: .centerY, relatedBy: .equal, toItem: miniMap, attribute: .centerY, multiplier: 1, constant: 0).isActive = true

        setBoundsSize(width: width, height: height)
        //box.addConstraint(heightConstraints)
        //box.addConstraint(widthConstraints)
        
        
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(_:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(miniMapDidChange(_:)), name: .miniMapAction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewSizeDidChange(_:)), name: Notification.Name("NSWindowDidResizeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gpxFileFinishedLoading(_:)), name: Notification.Name("GPXFileFinishedLoading"), object: nil)
    }
    
    func setBoundsSize(width: CGFloat, height: CGFloat) {
        if skipCounter == 3 {
            widthConstraints.isActive = false
            heightConstraints.isActive = false
            box.updateConstraints()
            widthConstraints = NSLayoutConstraint(item: box, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: width)
            heightConstraints =  NSLayoutConstraint(item: box, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: height)

            widthConstraints.isActive = true
            heightConstraints.isActive = true
            
            box.updateConstraints()
            skipCounter = 0
        }
        else {
            skipCounter += 1
        }
        
    }
    
    @objc func gpxFileFinishedLoading(_ sender: Notification) {
        skipCounter = 3 // force bound to update
        setBoundsSize(width: width, height: height)
    }
    
    @objc func segmentControlDidChange(_ sender: NSSegmentedControl) {
        var mapType: MKMapType
        
        switch sender.selectedSegment {
        case 0: mapType = .standard
        case 1: mapType = .satelliteFlyover
        case 2: mapType = .hybridFlyover
        default:
            mapType = .standard
        }

        miniMap.mapType = mapType
        mapView.mapType = mapType
    }
    
    @objc func viewSizeDidChange(_ sender: Notification) {
        // allow for box size update everytime when view size is changed.
        skipCounter = 3
        mapViewDidChangeVisibleRegion(mapView)
    }
    
    @objc func miniMapDidChange(_ sender: Notification) {
        mmHidden = !mmHidden
        if !mmBoundsReached {
            miniMap.animator().isHidden = mmHidden
        }
    }
    
    @objc func themeDidChange(_ sender: NSNotification) {
        // this seems to be called roughly .1 sec earlier than actual theme change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if #available(OSX 10.13, *) {
                self.miniMap.layer?.borderColor = NSColor(named: NSColor.Name("MiniMapBorder"))?.cgColor
            }
            else {
                self.miniMap.layer?.borderColor = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).cgColor
            }
            if #available(OSX 10.14, *) {
                self.box.layer?.borderColor = NSColor.controlAccentColor.cgColor
            }
            else {
                self.box.layer?.borderColor = NSColor.blue.cgColor
            }
        }
    }
    
    //
    /// Displays the line for each segment
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)
            if #available(OSX 10.14, *) {
                pr.strokeColor = NSColor.controlAccentColor //.withAlphaComponent(0.65)
            } else {
                pr.strokeColor = .blue
            }
            pr.alpha = 0.65
            pr.lineWidth = 4
            return pr
        }
        return MKOverlayRenderer()
    }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        setMiniMapRegion(mapView)
    }
    
    func setMiniMapRegion(_ mapView: MKMapView) {
        var region = MKCoordinateRegion()
        region = mapView.region
        
        // Remove minimap when it is displaying useless information.
        // seems like somewhere between 2.5 will cause zoom to stop.
        // anything above 1.25, appears to make bounding box super inaccurate.
        // 1.85 for current zoom easeOutQuad algorithm
        if region.span.latitudeDelta > 1.85 {
            miniMap.animator().isHidden = true
            mmBoundsReached = true
            return
        }

        mmBoundsReached = false
        miniMap.animator().isHidden = mmHidden
        
        
        // Some pages that was referred. Content may or may not be relevant to final implementation.
        // https://stackoverflow.com/questions/36685372/how-to-zoom-in-out-in-react-native-map/36688156#36688156
        // https://stackoverflow.com/questions/2081753/getting-the-bounds-of-an-mkmapview
        //for minimap2.0

        // latitude delta of main map
        let mVLat = mapView.region.span.latitudeDelta
        // longitude delta of main map
        let mVLon = mapView.region.span.longitudeDelta
        
        // formula: -t^2 + 2t from https://hackernoon.com/ease-out-the-half-sigmoid-7240df433d98, where x = delta of lat/lon
        region.span.latitudeDelta = pow((-1 * mVLat * 2), 2) + (2 * mVLat * 2)
        region.span.longitudeDelta = pow((-1 * mVLon * 2), 2) + (2 * mVLon * 2)
        miniMap.region = region
 
        // as a percentage conversion btn main and mini map
        width = CGFloat((mapView.region.span.longitudeDelta / miniMap.region.span.longitudeDelta)) * miniMap.frame.width
        height = CGFloat((mapView.region.span.latitudeDelta / miniMap.region.span.latitudeDelta)) * miniMap.frame.height
        setBoundsSize(width: width, height: height)
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
