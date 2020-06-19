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

    var launch = NSWindowController(windowNibName: "LaunchWindow")
    var stateRestore = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        print("didRun")
        

            if launch.isWindowLoaded { launch = NSWindowController(windowNibName: "LaunchWindow") }
            launch.showWindow(nil)
            launch.window?.center()
        
        
        return false
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        print("didOpen")
        return true
    }
    
    func closeLaunchWindow() {
        launch.window?.close()
    }
    
}

