//
//  WindowController.swift
//  Avenue
//
//  Created by Vincent on 8/7/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet weak var barDistance: NSTextField!
    
    private var dropDownIndex = [String : Int]() // filePath : idx
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //window?.titleVisibility = .hidden
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        
        //window.stringValue = "Avenue"
        //barTitle.isHidden = true
        
        if #available(OSX 10.12, *) {
            window?.tabbingMode = .preferred
        }
        window?.minSize = NSSize(width: 510, height: 280)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDropDownIndex(_:)), name: NSNotification.Name("EncodeRestorableState"), object: nil)
    }
    
    @objc func updateDropDownIndex(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let data = userInfo as? [String : Any] else { return }
        guard let idx = (data["index"] ?? 0) as? Int,
            let filePath = (data["filePath"] ?? "") as? String else { return }
        dropDownIndex[filePath] = idx
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(dropDownIndex, forKey: "dropDownIndex")
        print("Restoring previous tile server and drop down index setting")
        super.encodeRestorableState(with: coder)
    }
    
    override func restoreState(with coder: NSCoder) {
        guard let decoded = coder.decodeObject(forKey: "dropDownIndex") as? [String : Int] else { super.restoreState(with: coder); return }
        dropDownIndex = decoded
        print("Saving current tile server and drop down index setting")
        NotificationCenter.default.post(name: NSNotification.Name("DecodeRestorableState"), object: nil, userInfo: ["index" : dropDownIndex])
        super.restoreState(with: coder)
    }
    
}
