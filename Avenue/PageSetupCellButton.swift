//
//  PageSetupCellButton.swift
//  Avenue
//
//  Created by Vincent Neo on 6/8/22.
//  Copyright © 2022 Vincent. All rights reserved.
//

import Cocoa

fileprivate let grayColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.9)

class PageSetupCellButton: NSButton {
    
    private var _isSelected = false
    
    /// Observes system accent color changes, according to `UserDefaults` AppleHighlightColor.
    private var systemAccentObserver: NSKeyValueObservation?
    
    var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            updateBackgroundColor()
        }
    }
    
    func updateBackgroundColor() {
        guard _isSelected else {
            self.layer?.backgroundColor = .clear
            return
        }
        if #available(OSX 10.14, *) {
            self.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        }
        else {
            self.layer?.backgroundColor = systemBlueColor.cgColor
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func awakeFromNib() {
        let trackingArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        self.wantsLayer = true
        self.layer?.cornerRadius = 15
        
        self.isSelected = PageSetupPreferences.shared.selectedMapResolution == self.tag
        
        systemAccentObserver = UserDefaults.standard.observe(\.AppleHighlightColor, options: [.initial, .new], changeHandler: { (defaults, change) in
            // update color based on highlight color. Delay required to get correct color as it may update faster before color change.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.updateBackgroundColor()
            }
        })
    }

    override func mouseEntered(with event: NSEvent) {
        if !_isSelected {
            self.layer?.backgroundColor = grayColor.cgColor
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if !_isSelected {
            self.layer?.backgroundColor = .clear
        }
    }
    
}
