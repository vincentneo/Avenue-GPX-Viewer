//
//  Document.swift
//  Avenue
//
//  Created by Vincent on 7/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa
import CoreGPX

class Document: NSDocument {
    
    var gpx = GPXRoot()

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! WindowController
        windowController.barTitle.stringValue = self.fileURL?.lastPathComponent ?? ""
        self.addWindowController(windowController)
        
        let viewController = windowController.contentViewController as! ViewController
        viewController.mapView.loadedGPXFile(gpx)
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
        let gpx1 = GPXParser(withData: data).parsedData()
        //self.delegate?.loadedGPXFile(gpx)
        Swift.print(gpx)
        if gpx.tracks.count == 0 {
            self.gpx = gpx1
            //throw NSError(domain: , code: unimpErr, userInfo: nil)
        }
        //Swift.print(gpx.tracks[0].tracksegments[0].trackpoints[0].latitude)
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }


}

