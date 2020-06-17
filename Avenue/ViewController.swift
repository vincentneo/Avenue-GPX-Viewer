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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
        
        miniMap.autoresizingMask = .none
        let subView = NSView(frame: self.view.frame)
        subView.addSubview(miniMap)
        miniMap.frame = NSRect(x: 10, y: subView.frame.height - 110, width: 100, height: 100)
        mapView.addSubview(subView)
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = miniMap.subviews.filter({ $0.isKind(of: textClass) }).first {
            mapText.isHidden = true
        }
        miniMap.isZoomEnabled = false
        miniMap.isScrollEnabled = false
    }
    
    //
    /// Displays the line for each segment
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = NSColor(named: NSColor.Name("Poly Line Colour"))
            pr.lineWidth = 4
            return pr
        }
        return MKOverlayRenderer()
    }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        setMiniMapRegion(mapView)
    }
    
    func setMiniMapRegion(_ mapView: MKMapView) {
        var region = mapView.region
        
        // seems like somewhere between 2.5 * 10 will cause zoom to stop. Might as well remove minimap entirely.
        if region.span.latitudeDelta > 2.5 {
            miniMap.isHidden = true
            return
        }
        miniMap.isHidden = false
        region.span.latitudeDelta *= 10
        region.span.longitudeDelta *= 10
        miniMap.region = region
        // TODO:- add a bounding box to represent current size of main map view, represented in map.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
