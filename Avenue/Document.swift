//
//  Document.swift
//  Avenue
//
//  Created by Vincent on 7/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa
import CoreGPX
import MapKit

class Document: NSDocument {
    
    var gpx: GPXRoot?
    var extent = GPXExtentCoordinates()
    var data = Data()
    
    let appDelegate = NSApp.delegate as! AppDelegate

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        self.appDelegate.launch.window?.close() 
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! WindowController
        
        if let fileName = self.fileURL?.lastPathComponent {
            //let systemRegular = [ NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18, weight: .regular) ]
            let systemSemibold = [ NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18, weight: .semibold) ]
            let title = NSMutableAttributedString(string: "\(fileName)", attributes: systemSemibold)
            //title.addAttributes(systemRegular, range: NSMakeRange(0, 5))
            
            //windowController.barTitle.stringValue = "Avenue - \(title)"
            windowController.barTitle.attributedStringValue = title
        }
        windowController.barTitle.isHidden = false
        self.addWindowController(windowController)
        
        let viewController = windowController.contentViewController as! ViewController
        //viewController.mapView.loadedGPXFile(gpx)
        viewController.mapView.loadedGPXData(data, windowController)
        viewController.filePath = fileURL?.absoluteString ?? ""
        Swift.print(viewController.filePath)
            
        windowController.fileImageView.image = NSWorkspace.shared.icon(forFileType: "public.gpx").resize(withSize: NSSize(width: 22, height: 22))
        windowController.fileImageView.fileURL = fileURL
        
        appDelegate.enableViewMenuItem()
        //viewController.mmHidden = !UserDefaults.standard.bool(forKey: "showMiniMap")
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        self.data = data
        /*
        let fileGPX = GPXParser(withData: data).parsedData()
        
        
        if fileGPX.tracks.count != 0 || fileGPX.waypoints.count != 0 {
            self.gpx = fileGPX
        }
        else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        */
    }
    
    override func preparePageLayout(_ pageLayout: NSPageLayout) -> Bool {
        Swift.print(pageLayout.accessoryControllers)
        pageLayout.addAccessoryController(AdditionalPageSetupViewController())
        return true
    }
    
    override func printDocument(_ sender: Any?) {
        Swift.print("print doc call")
        
        let options = MKMapSnapshotter.Options()
        
        if #available(macOS 10.14, *) {
            options.appearance = NSAppearance(named: .aqua)
        }
        options.region = extent.region
        
        let printInfo = self.printInfo
        printInfo.scalingFactor = floor(printInfo.scalingFactor)
        printInfo.verticalPagination = .fit
        printInfo.horizontalPagination = .fit
        printInfo.bottomMargin = 0
        printInfo.topMargin = 0
        printInfo.leftMargin = 0
        printInfo.rightMargin = 0
        
        let imageSize = printInfo.imageablePageBounds.size
        options.size = imageSize.multiplied(PageSetupResolution.chosenScale)
        
        Swift.print("Paper Size \(printInfo.paperSize) | Printable Bounds \(printInfo.imageablePageBounds.size)")
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let image = snapshot?.image else {
                if let error = error {
                    Swift.print(error)
                }
                return
            }
            let drawer = MKSnapshotDrawer(snapshot!, gpx: self.gpx!)
            let newImage = drawer.processImage()
            let imageView = NSImageView()
            imageView.frame = NSRect(origin: .zero, size: image.size)
            imageView.image = newImage
            
            NSPrintInfo.shared = printInfo
            imageView.beginDocument()
            
            let printOperation = NSPrintOperation(view: imageView, printInfo: printInfo)
            printOperation.showsPrintPanel = true
            printOperation.run()
            
            imageView.endDocument()
        }
    }
    
    override var isEntireFileLoaded: Bool {
        return true
    }
    
    // MARK: - To prevent Save Dialog from appearing
    
    override var isDocumentEdited: Bool {
        return false
    }
    
    override func updateChangeCount(_ change: NSDocument.ChangeType) {
    }
    
    override var hasUnautosavedChanges: Bool {
        return false
    }
    
    override class var autosavesDrafts: Bool {
        return false
    }
}

