//
//  AdditionalPageSetupViewController.swift
//  Avenue
//
//  Created by Vincent Neo on 5/8/22.
//  Copyright © 2022 Vincent. All rights reserved.
//

import Cocoa

class AdditionalPageSetupViewController: NSViewController {
    
    @IBOutlet weak var resolutionButtonsView: NSStackView!
    
    init() {
        super.init(nibName: "AdditionalPageSetupViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func resolutionChanged(_ sender: PageSetupCellButton) {
        let allButtons = resolutionButtonsView.subviews
        for case let button as PageSetupCellButton in allButtons {
            button.isSelected = false
        }
        sender.isSelected = true
        PageSetupPreferences.shared.selectedMapResolution = sender.tag
    }
}
