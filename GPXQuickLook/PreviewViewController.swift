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
import MapCache

class PreviewViewController: NSViewController, QLPreviewingController, MKMapViewDelegate {
    
    @IBOutlet weak var elapsedView: NSVisualEffectView!
    @IBOutlet weak var distanceView: NSVisualEffectView!
    @IBOutlet weak var elapsedLabel: NSTextField!
    @IBOutlet weak var distanceLabel: NSTextField!
    @IBOutlet weak var mapView: QLMapView!
    //@IBOutlet weak var debugLabel: NSTextField!
    
    enum PossibleErrors: Error {
        case fileIsNil
    }
    
//    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
//
//    /// Is the map using local image cache??
//    var useCache: Bool = true { //use tile overlay cache (
//        didSet {
//            if self.tileServerOverlay is CachedTileOverlay {
//                print("GPXMapView:: setting useCache \(self.useCache)")
//                (self.tileServerOverlay as! CachedTileOverlay).useCache = self.useCache
//            }
//        }
//    }
//
//    // from OpenGPXTracker-iOS
//    var tileServer: GPXTileServer = .apple {
//        willSet {
//            print("Setting map tiles overlay to: \(newValue.name)" )
//
//            // remove current overlay
//            if self.tileServer != .apple {
//                //to see apple maps we need to remove the overlay added by map cache.
//                mapView.removeOverlay(self.tileServerOverlay)
//            }
//
//            //add new overlay to map if not using Apple Maps
//            if newValue != .apple {
//
//                //Update cacheConfig
//                var config: MapCacheConfig
//                if Preferences.shared.preferRetina, let retinaUrl = newValue.retinaUrl {
//                    config = MapCacheConfig(withUrlTemplate: retinaUrl)
//                    config.tileSize = CGSize(width: 512, height: 512)
//                    print(config.tileSize)
//                }
//                else {
//                    config = MapCacheConfig(withUrlTemplate: newValue.templateUrl)
//                    config.tileSize = CGSize(width: 256, height: 256)
//                }
//                config.subdomains = newValue.subdomains
//
//                if newValue.maximumZ > 0 {
//                    config.maximumZ = newValue.maximumZ
//                }
//                if newValue.minimumZ > 0  {
//                    config.minimumZ = newValue.minimumZ
//                }
//                let cache = MapCache(withConfig: config)
//                // the overlay returned substitutes Apple Maps tile overlay.
//                // we need to keep a reference to remove it, in case we return back to Apple Maps.
//                self.tileServerOverlay = mapView.useCache(cache)//useCache(cache)//KTileOverlay(urlTemplate: randomSubdomain(newValue.subdomains, domain: newValue.templateUrl))
//                // to use cache or not
//                useCache = Preferences.shared.enableCache
//
//                self.tileServerOverlay.canReplaceMapContent = true
//
//                let level: MKOverlayLevel = .aboveLabels
//
//                mapView.insertOverlay(self.tileServerOverlay, at: 0, level: level)
//            }
//        }
//        didSet {
//            if #available(OSX 10.14, *) {
//                if tileServer == .apple {
//                    mapView.appearance = nil
//                }
//                else { // if map is third party, dark mode is disabled.
//                    let bestMatch = NSAppearance().bestMatch(from: [.aqua, .accessibilityHighContrastAqua]) ?? .aqua
//                    mapView.appearance = NSAppearance(named: bestMatch)
//                }
//                //themeDidChange(NSNotification(name: .mapChangedTheme, object: nil))
//            }
//
//        }
//    }
//
//    /// borrowed cache
//    func useCache(_ cache: MapCache) -> CachedTileOverlay {
//        let tileServerOverlay = CachedTileOverlay(withCache: cache)
//        tileServerOverlay.canReplaceMapContent = true
//
//        if cache.config.maximumZ > 0 {
//            tileServerOverlay.maximumZ = cache.config.maximumZ
//        }
//
//        if cache.config.minimumZ > 0 {
//            tileServerOverlay.minimumZ = cache.config.minimumZ
//        }
//        return tileServerOverlay
//    }
    
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
        
        //mapView.addOverlay(tileServerOverlay)
        //updateMapViewToUse(index: Preferences.shared.mapTileIndex)
        //debugLabel.stringValue = "MapIndex \(Preferences.shared.mapTileIndex)\nMapView \(tileServer)\nPrefs \(UserDefaults(suiteName: kAppGroup))"
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
            let locale = Locale.current
            let useImperial = !locale.usesMetricSystem
            
            let elapsedText = ElapsedTime.getString(from: mapView.timeInterval)
            let distanceText = mapView.length.toDistance(useImperial: useImperial)
            
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
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)//mapView.mapCacheRenderer(forOverlay: overlay)
        }
        
        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)
            if #available(OSX 10.14, *) {
                if #available(OSX 10.15, *) {
                    pr.shouldRasterize = true
                }
                pr.strokeColor = NSColor.controlAccentColor //.withAlphaComponent(0.65)
            } else {
                pr.strokeColor = systemBlueColor
            }
            pr.alpha = 0.65
            pr.lineWidth = 5
            return pr
        }
        return MKOverlayRenderer()
    }
//    
//    func getMapType(basedOn index: Int) -> MKMapType {
//        var mapType: MKMapType
//        switch index {
//            case 0: mapType = .standard;             tileServer = .apple
//            case 1: mapType = .hybridFlyover;        tileServer = .apple
//            case 2: mapType = .satelliteFlyover;     tileServer = .apple
//         // case 3: will be a seperator; > 4 = custom
//        default:
//            mapType = .standard; tileServer = GPXTileServer(rawValue: index) ?? .apple
//        }
//        return mapType
//    }
//    
//    func updateMapViewToUse(index: Int) {
//        let mapType = getMapType(basedOn: index)
//        if let textClass = NSClassFromString("MKAttributionLabel"),
//           let mapText = mapView.subviews.filter({ $0.isKind(of: textClass) }).first {
//            if index > 3 {
//                //attribution.font = .boldSystemFont(ofSize: 8.5)
//                guard tileServer != .apple else { return }
//                //attribution.stringValue = tileServer.attribution
//                //attribution.isHidden = false
//                mapText.isHidden = true
//                
//            }
//            else {
//                mapText.isHidden = false
//                //attribution.isHidden = true
//            }
//
//        }
//        mapView.mapType = mapType
//    }
}
