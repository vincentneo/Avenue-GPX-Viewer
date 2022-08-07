//
//  PreferenceViewController.swift
//  Avenue
//
//  Created by Vincent Neo on 14/7/20.
//  Copyright © 2020 Vincent. All rights reserved.
//

import Cocoa
import MapCache

class PreferenceViewController: NSViewController {

    @IBOutlet weak var sizeText: NSTextField!
    @IBOutlet weak var cacheCheckBox: NSButton!
    @IBOutlet weak var clearCacheButton: NSButton!
    @IBOutlet weak var preferRetinaCheckBox: NSButton!
    @IBOutlet weak var mapTilesDefaultPopUp: NSPopUpButton!
    @IBOutlet weak var distanceUnitSegmentControl: NSSegmentedControl!
    @IBOutlet weak var showCursorCoordinatesButton: NSButton!
    
    /// Global Preferences
    var preferences : Preferences = Preferences.shared
    
    var cache : MapCache = MapCache(withConfig: MapCacheConfig(withUrlTemplate: ""))
    
    // Compute once, better performance for scrolling table view (reuse)
    /// Store cached size for reuse.
    var cachedSize = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cacheCheckBox.state = preferences.enableCache ? .on : .off
        preferRetinaCheckBox.state = preferences.preferRetina ? .on : .off

        let fileSize = cache.diskCache.fileSize ?? 0
        cachedSize = Int(fileSize).asFileSize()
        sizeText.stringValue = cachedSize
        
        // dropdown options for map tile
        mapTilesDefaultPopUp.removeAllItems()
        mapTilesDefaultPopUp.addItem(withTitle: " Standard")
        mapTilesDefaultPopUp.addItem(withTitle: " Hybrid")
        mapTilesDefaultPopUp.addItem(withTitle: " Satellite")
        mapTilesDefaultPopUp.menu?.addItem(.separator())
        for server in GPXTileServer.allCases {
            mapTilesDefaultPopUp.addItem(withTitle: server.name)
        }
        
        mapTilesDefaultPopUp.selectItem(at: preferences.mapTileIndex)
        mapTilesDefaultPopUp.action = #selector(popupButtonTriggered(_:))
        
        distanceUnitSegmentControl.selectedSegment = preferences.distanceUnitTypeInt
        
        showCursorCoordinatesButton.state = preferences.showCursorCoordinates ? .on : .off
    }
    
    @IBAction func clearButtonPressed(_ sender: NSButton) {
        print("clear cache")
        sizeText.stringValue = "Clearing..."
        //Create a cache
        cache.clear {
            print("Cache cleaned")
            self.cachedSize = 0.asFileSize()
            self.sizeText.stringValue = self.cachedSize
        }
    }
    
    @IBAction func cacheCheckBoxChanged(_ sender: NSButton) {
        if sender.state == .on {
            preferences.enableCache = true
        }
        else {
            preferences.enableCache = false
        }
         NotificationCenter.default.post(Notification(name: Notification.Name("CacheSettingsDidChange")))
    }
    
    @IBAction func preferRetinaCheckBox(_ sender: NSButton) {
        if sender.state == .on {
            preferences.preferRetina = true
        }
        else {
            preferences.preferRetina = false
        }
        NotificationCenter.default.post(Notification(name: Notification.Name("RetinaSettingDidChange")))
    }
    
    @IBAction func enableScaleCheckBoxChanged(_ sender: NSButton) {
        if sender.state == .on {
            preferences.showMapScale = true
        }
        else {
            preferences.showMapScale = false
        }
    }
    
    @objc func popupButtonTriggered(_ sender: NSPopUpButton) {
        let newValue = sender.indexOfSelectedItem
        preferences.mapTileIndex = newValue
    }
    
    @IBAction func distanceUnitChanged(_ sender: NSSegmentedControl) {
        let selectedTag = sender.selectedSegment
        Preferences.shared.distanceUnitTypeInt = selectedTag
    }
    
    @IBAction func cursorCoordinatesClicked(_ sender: NSButton) {
        if sender.state == .on {
            preferences.showCursorCoordinates = true
        }
        else {
            preferences.showCursorCoordinates = false
        }
        NotificationCenter.default.post(Notification(name: Notification.Name("CursorCoordinatesSettingDidChange")))
    }
}
