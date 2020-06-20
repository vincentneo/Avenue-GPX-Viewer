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

    let launch = NSWindowController(windowNibName: "LaunchWindow")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //launch.window?.isRestorable = false
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        print("didRun")
        launch.showWindow(self)
        return false
    }
    
    func closeLaunchWindow() {
        launch.window?.performClose(self)
    }
    
}

