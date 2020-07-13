//
//  WindowController.swift
//  Avenue
//
//  Created by Vincent on 8/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet weak var barTitle: NSTextField!
    @IBOutlet weak var barDistance: NSTextField!
    
    private var dropDownIndex = 0
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        barTitle.stringValue = "Avenue"
        barTitle.isHidden = true
        
        if #available(OSX 10.12, *) {
            window?.tabbingMode = .preferred
        }
        window?.minSize = NSSize(width: 510, height: 280)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDropDownIndex(_:)), name: NSNotification.Name("EncodeRestorableState"), object: nil)
    }
    
    @objc func updateDropDownIndex(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let data = userInfo as? [String : Int] else { return }
        dropDownIndex = data["index"] ?? 0
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(dropDownIndex, forKey: "dropDownMenu")
        print("Restoring previous tile server and drop down index setting")
        super.encodeRestorableState(with: coder)
    }
    
    override func restoreState(with coder: NSCoder) {
        dropDownIndex = coder.decodeInteger(forKey: "dropDownMenu")
        let vcHash = coder.decodeInteger(forKey: "vcHash")
        print("Saving current tile server and drop down index setting")
        NotificationCenter.default.post(name: NSNotification.Name("DecodeRestorableState"), object: nil, userInfo: ["index" : dropDownIndex, "vcHash" : vcHash])
        super.restoreState(with: coder)
    }
    
}
