//
//  AppDelegate.swift
//  Avenue
//
//  Created by Vincent on 7/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var showMiniMap: NSMenuItem!
    @IBOutlet weak var hideMiniMap: NSMenuItem!
    
    let launch = NSWindowController(windowNibName: "LaunchWindow")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        print("didRun")
        launch.showWindow(self)
        disableAllViewMenuItems()
        return false
    }
    
    func closeLaunchWindow() {
        launch.window?.performClose(self)
    }
    
    @IBAction func showMiniMapClicked(_ sender: NSMenuItem) {
        hideMiniMap.isHidden = false
        showMiniMap.isHidden = true
        
        NotificationCenter.default.post(name: .miniMapAction, object: nil)
    }
    
    @IBAction func hideMiniMapClicked(_ sender: NSMenuItem) {
        showMiniMap.isHidden = false
        hideMiniMap.isHidden = true
        NotificationCenter.default.post(name: .miniMapAction, object: nil)
    }
    
    func disableAllViewMenuItems() {
        let main = NSApplication.shared.menu?.item(withTitle: "View")
        let subMenuItems = main?.submenu?.items
        for item in subMenuItems! {
                item.isEnabled = false

        }
    }
    
    func enableMiniMapMenuItems() {
        let main = NSApplication.shared.menu?.item(withTitle: "View")
        let subMenuItems = main?.submenu?.items
        for item in subMenuItems! {

                item.isEnabled = true
        
            
        }
    }
    
}

extension NSNotification.Name {
    static let miniMapAction = Notification.Name("MiniMapAction")
}
