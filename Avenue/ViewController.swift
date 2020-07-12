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
import MapCache

class ViewController: NSViewController, MKMapViewDelegate {

    /// main map that forms main view. Displays actual gps log and user interactable.
    @IBOutlet weak var mapView: MapView!
    
    // from OpenGPXTracker-iOS
    /// Overlay that holds map tiles
    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
    
    /// Is the map using local image cache??
    var useCache: Bool = true { //use tile overlay cache (
        didSet {
            if self.tileServerOverlay is CachedTileOverlay {
                print("GPXMapView:: setting useCache \(self.useCache)")
                (self.tileServerOverlay as! CachedTileOverlay).useCache = self.useCache
            }
        }
    }
    
    // from OpenGPXTracker-iOS
    var tileServer: GPXTileServer = .apple {
        willSet {
            print("Setting map tiles overlay to: \(newValue.name)" )

            // remove current overlay
            if self.tileServer != .apple {
                //to see apple maps we need to remove the overlay added by map cache.
                mapView.removeOverlay(self.tileServerOverlay)
                miniMap.removeOverlay(self.tileServerOverlay)
            }
            
            /// Min distance to the floor of the camera
            if #available(OSX 10.15, *) {
             mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: newValue.minCameraDistance, maxCenterCoordinateDistance: -1), animated: true)
             miniMap.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: newValue.minCameraDistance, maxCenterCoordinateDistance: -1), animated: true)
            }
            
            //add new overlay to map if not using Apple Maps
            if newValue != .apple {
                 //MapCache is still iOS only. May arrive at later date
                //Update cacheConfig
                var config = MapCacheConfig(withUrlTemplate: newValue.templateUrl)
                config.subdomains = newValue.subdomains
                
                if newValue.maximumZ > 0 {
                    config.maximumZ = newValue.maximumZ
                }
                if newValue.minimumZ > 0  {
                    config.minimumZ = newValue.minimumZ
                }
                let cache = MapCache(withConfig: config)
                // the overlay returned substitutes Apple Maps tile overlay.
                // we need to keep a reference to remove it, in case we return back to Apple Maps.
                self.tileServerOverlay = useCache(cache)//KTileOverlay(urlTemplate: randomSubdomain(newValue.subdomains, domain: newValue.templateUrl))
                self.tileServerOverlay.canReplaceMapContent = true
                
                mapView.insertOverlay(self.tileServerOverlay, at: 0, level: .aboveLabels)
                miniMap.insertOverlay(self.tileServerOverlay, at: 0, level: .aboveLabels)


            }
        }
        didSet {
            
            if #available(OSX 10.14, *) {
                if tileServer == .apple {
                    NSApp.appearance = nil
                }
                else { // if map is third party, dark mode is disabled.
                    let bestMatch = NSAppearance().bestMatch(from: [.aqua, .accessibilityHighContrastAqua]) ?? .aqua
                    NSApp.appearance = NSAppearance(named: bestMatch)
                }
                themeDidChange(NSNotification(name: .mapChangedTheme, object: nil))
            }
            
        }
    }
    
    /// borrowed cache
    func useCache(_ cache: MapCache) -> CachedTileOverlay {
        let tileServerOverlay = CachedTileOverlay(withCache: cache)
        tileServerOverlay.canReplaceMapContent = true
        
        if cache.config.maximumZ > 0 {
            tileServerOverlay.maximumZ = cache.config.maximumZ
        }
        
        if cache.config.minimumZ > 0 {
            tileServerOverlay.minimumZ = cache.config.minimumZ
        }
        return tileServerOverlay
    }
    
    /// mini map that typically locates at top left corner of view.
    let miniMap = MKMapView()
    var mmBackingView = NSView()
    let mmDelegate = MiniDelegate()
    
    /// mini map's center box
    var box = NSView(frame: NSRect.zero)
    var boxHeight = CGFloat.zero
    var boxWidth = CGFloat.zero
    var boxHeightConstraints = NSLayoutConstraint()
    var boxwidthConstraints = NSLayoutConstraint()
    
    /// Mini Map's zoom out boundaries reached: point of no zooming
    var mmBoundsReached = false
    
    /// Mini Map's should be hidden or not, by settings.
    var mmHidden = false
    
    /// segments that allow users to choose apple map type at bottom left corner above legal text. Subject to changes in future.
    let dropDownMenu = NSPopUpButton(title: "", target: nil, action: #selector(dropDownDidChange(_:)))
    let segments = NSSegmentedControl(labels: ["Standard", "Satellite", "Hybrid"], trackingMode: .selectOne, target: nil, action: #selector(segmentControlDidChange(_:)))
    
    /// a counter for use to improve performance in minimap bound box drawing,
    /// as size change calls may be overly repetitive, and that its fine to skip some drawing cycles.
    var skipCounter = 3
    
    /// Observes system accent color changes, according to `UserDefaults` AppleHighlightColor.
    var systemAccentObserver: NSKeyValueObservation?
    
    var attribution = NSTextField(frame: CGRect(x: 0, y: 0, width: 180, height: 20))
    
    enum MiniMapSize: CGFloat {
        
        static let shared = MiniMapSize.small
        
        case small = 135
        case mid = 160
        case full = 185
        
        func preferredSize(_ width: CGFloat, _ height: CGFloat) -> CGFloat {
            // window?.minSize = NSSize(width: 510, height: 280)
            if width < 650 || height < 450 {
                return MiniMapSize.small.rawValue
            }
            else if width < 1200 || height < 1000 {
                return MiniMapSize.mid.rawValue
            }
            else {
                return MiniMapSize.full.rawValue
            }
        }
    }
    
    var mmSize = MiniMapSize.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mmHidden = Preferences.shared.hideMiniMap
        mapView.delegate = self
        // Do any additional setup after loading the view.
        miniMap.autoresizingMask = .none
        miniMap.delegate = mmDelegate
        // size of minimap
        let kSize: CGFloat = mmSize.preferredSize(mapView.frame.width, mapView.frame.height)
        mmBackingView = NSView(frame: NSRect(x: 10, y: mapView.frame.minY + 10, width: kSize, height: kSize))
        miniMap.frame = NSRect(x: 0, y: 0, width: kSize, height: kSize)
        mmBackingView.addSubview(miniMap)
        mapView.addSubview(mmBackingView)
        //miniMap.delegate = mmDelegate
        
        dropDownMenu.frame = NSRect(x: 0, y: 0, width: 145, height: 25)
        dropDownMenu.addItem(withTitle: " Standard")
        dropDownMenu.addItem(withTitle: " Hybrid")
        dropDownMenu.addItem(withTitle: " Satellite")
        dropDownMenu.menu?.addItem(.separator())
        dropDownMenu.addItem(withTitle: "Open Street Map")
        dropDownMenu.addItem(withTitle: "CartoDB")
        dropDownMenu.addItem(withTitle: "OpenTopoMap")
        dropDownMenu.select(dropDownMenu.item(at: 0))
        dropDownMenu.wantsLayer = true
        dropDownMenu.layer?.opacity = 0.9
        //dropDownMenu.menu?.items.append()
        self.view.addSubview(dropDownMenu)
        
        //self.view.addSubview(segments)
        //segments.selectedSegment = 0
        //segments.segmentStyle = .texturedRounded
        
        //segments.frame = CGRect(x: 3, y: mapView.frame.height, width: segments.frame.width, height: segments.frame.height)
        // it will be weird to have legal text on both map views
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = miniMap.subviews.filter({ $0.isKind(of: textClass) }).first {
            mapText.isHidden = true
        }
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = mapView.subviews.filter({ $0.isKind(of: textClass) }).first {
            dropDownMenu.frame = dropDownMenu.frame.offsetBy(dx: 3, dy: mapText.frame.height + 3)
            //segments.frame = segments.frame.offsetBy(dx: 3, dy: mapText.frame.height + 3)
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
        
        boxWidth = mapView.frame.width / 10
        boxHeight = mapView.frame.height / 10
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
        let shadow = NSShadow()
        
        shadow.shadowColor = .gray
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        shadow.shadowBlurRadius = 2
        miniMap.addSubview(box)
        box.shadow = shadow
        
        box.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: box, attribute: .centerX, relatedBy: .equal, toItem: miniMap, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: box, attribute: .centerY, relatedBy: .equal, toItem: miniMap, attribute: .centerY, multiplier: 1, constant: 0).isActive = true

        setBoundsSize(width: boxWidth, height: boxHeight)
        //box.addConstraint(heightConstraints)
        //box.addConstraint(widthConstraints)
        
        
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(_:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(miniMapDidChange(_:)), name: .miniMapAction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewSizeDidChange(_:)), name: Notification.Name("NSWindowDidResizeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gpxFileFinishedLoading(_:)), name: Notification.Name("GPXFileFinishedLoading"), object: nil)
        systemAccentObserver = UserDefaults.standard.observe(\.AppleHighlightColor, options: [.initial, .new], changeHandler: { (defaults, change) in
            // update color based on highlight color. Delay required to get correct color as it may update faster before color change.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.setBoxBorderColor()
            }
        })
        
        mapView.addSubview(attribution)
        attribution.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: attribution, attribute: .leading, relatedBy: .equal, toItem: mapView, attribute: .leading, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: attribution, attribute: .bottom, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 1, constant: -3).isActive = true
        
        attribution.isBezeled = false
        attribution.drawsBackground = false
        attribution.isEditable = false
        attribution.isSelectable = false
    }
    
    deinit {
        systemAccentObserver?.invalidate()
    }
    
    // from merlos/MapCache
    public func randomSubdomain(_ subdomains: [String], domain: String) -> String? {
        if subdomains.count == 0 {
            return nil
        }
        let rand = Int(arc4random_uniform(UInt32(subdomains.count)))
        
        return domain.replacingOccurrences(of: "{s}", with: subdomains[rand])
    }
    
    func setBoundsSize(width: CGFloat, height: CGFloat) {
        if skipCounter == 3 {
            boxwidthConstraints.isActive = false
            boxHeightConstraints.isActive = false
            box.updateConstraints()
            boxwidthConstraints = NSLayoutConstraint(item: box, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: width)
            boxHeightConstraints =  NSLayoutConstraint(item: box, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: height)

            boxwidthConstraints.isActive = true
            boxHeightConstraints.isActive = true
            
            box.updateConstraints()
            skipCounter = 0
        }
        else {
            skipCounter += 1
        }
        
    }
    
    @objc func gpxFileFinishedLoading(_ sender: Notification) {
        skipCounter = 3 // force bound to update
        setBoundsSize(width: boxWidth, height: boxHeight)
        for overlay in mapView.overlays {
            if overlay is MKPolyline {
                miniMap.addOverlay(overlay, level: .aboveLabels)
            }
        }
        miniMap.addAnnotations(mapView.annotations)
    }
    
    @objc func dropDownDidChange(_ sender: NSPopUpButton) {
        var mapType: MKMapType
        
        var legalLabel: String?
        
        switch sender.indexOfSelectedItem {
            case 0: mapType = .standard;             tileServer = .apple
            case 1: mapType = .satelliteFlyover;     tileServer = .apple
            case 2: mapType = .hybridFlyover;        tileServer = .apple
         // case 3: will be a seperator; > 4 = custom
            case 4: mapType = .standard;             tileServer = .openStreetMap; legalLabel = "© OpenStreetMap contributors"
            case 5: mapType = .standard;             tileServer = .cartoDB; legalLabel = "© OpenStreetMap contributors, © CARTO"
            case 6: mapType = .standard;             tileServer = .openTopoMap; legalLabel = "© OpenStreetMap contributors, SRTM, © OpenTopoMap (CC-BY-SA)"
        default:
            mapType = .standard
        }
        
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = mapView.subviews.filter({ $0.isKind(of: textClass) }).first {
            if sender.indexOfSelectedItem > 3 {
                attribution.font = .boldSystemFont(ofSize: 8.5)
                guard let legalLabel = legalLabel else { return }
                attribution.stringValue = legalLabel
                attribution.isHidden = false
                mapText.isHidden = true
                
            }
            else {
                mapText.isHidden = false
                attribution.isHidden = true
            }

        }

        if mapType == .hybridFlyover {
            miniMap.mapType = .hybrid
        }
        else if mapType == .satelliteFlyover {
            miniMap.mapType = .satellite
        }
        else {
            miniMap.mapType = mapType
        }
        mapView.mapType = mapType
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
        let kSize = mmSize.preferredSize(mapView.frame.width, mapView.frame.height)
        
        // dispatch after to prevent erronous frame sizes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mmBackingView.animator().frame = NSRect(x: 10, y: self.mapView.frame.minY + 10, width: kSize, height: kSize)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.miniMap.animator().frame = NSRect(x: 0, y: 0, width: kSize, height: kSize)
        }
        

    }

    @objc func miniMapDidChange(_ sender: Notification) {
        mmHidden = !mmHidden
        if !mmBoundsReached {
            miniMap.animator().isHidden = mmHidden
        }
        Preferences.shared.hideMiniMap = mmHidden
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
            self.setBoxBorderColor()
        }
    }
    
    func setBoxBorderColor() {
        if #available(OSX 10.14, *) {
            self.box.layer?.borderColor = NSColor.controlAccentColor.cgColor
        }
        else {
            self.box.layer?.borderColor = NSColor.blue.cgColor
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
                if #available(OSX 10.15, *) {
                    pr.shouldRasterize = true
                }
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
        boxWidth = CGFloat((mapView.region.span.longitudeDelta / miniMap.region.span.longitudeDelta)) * miniMap.frame.width
        boxHeight = CGFloat((mapView.region.span.latitudeDelta / miniMap.region.span.latitudeDelta)) * miniMap.frame.height
        setBoundsSize(width: boxWidth, height: boxHeight)
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension UserDefaults {
    
    // from https://stackoverflow.com/a/47856467
    
    /// name does not respect lowerCamelCase
    /// as the source of implementation states that no callbacks if name != key.
    @objc dynamic var AppleHighlightColor: String? {
        return string(forKey: "AppleHighlightColor")
    }
}

class MiniDelegate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
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
            pr.alpha = 0.8
            pr.lineWidth = 1.5
            return pr
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is GPXWaypoint else {
            print("Non-GPXWaypoint annotation for minimap found")
            return nil
        }
        
        let identifier = "mmPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        guard let img = NSImage(named: NSImage.Name("avenue-pin")) else { print("Oh no! Mini map pin not found :("); return nil}
        annotationView?.image = img
        annotationView?.canShowCallout = false // minimap is not user interactable
        
        return annotationView
    }
}

extension Notification.Name {
    static let mapChangedTheme = Notification.Name("MapChangedTheme")
}
