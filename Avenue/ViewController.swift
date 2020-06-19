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
        let kSize: CGFloat = 135
        miniMap.frame = NSRect(x: 10, y: subView.frame.height - (kSize + 10), width: kSize, height: kSize)
        mapView.addSubview(subView)
        
        // it will be weird to have legal text on both map views
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = miniMap.subviews.filter({ $0.isKind(of: textClass) }).first {
            mapText.isHidden = true
        }
        
        
        // disable user interaction on mini map
        miniMap.isZoomEnabled = false
        miniMap.isScrollEnabled = false
        
        miniMap.wantsLayer = true

        miniMap.layer?.borderColor = NSColor(named: NSColor.Name("MiniMapBorder"))?.cgColor//NSColor.gray.cgColor
        miniMap.layer?.borderWidth = 1.5
        miniMap.layer?.cornerRadius = 10
        
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(_:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
    }

    @objc func themeDidChange(_ sender: NSNotification) {
        // this seems to be called roughly .1 sec earlier than actual theme change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.miniMap.layer?.borderColor = NSColor(named: NSColor.Name("MiniMapBorder"))?.cgColor
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
                pr.alpha = 0.65
            } else {
                pr.strokeColor = NSColor(named: NSColor.Name("Poly Line Color"))
            }
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
            miniMap.animator().isHidden = true
            return
        }
        miniMap.animator().isHidden = false
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
