//
//  AboutViewController.swift
//  Avenue
//
//  Created by Vincent Neo on 30/8/21.
//  Copyright © 2021 Vincent. All rights reserved.
//

import Cocoa
import WebKit

class AboutViewController: NSViewController {

    @IBOutlet weak var versionBuildLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionBuildLabel.stringValue = "Version \(version), Build \(build)"
        }
    }
    
    @IBAction func acknowledgmentButtonClicked(_ sender: NSButton) {
        if let splitViewController = parent as? NSSplitViewController {
            let sidebar = splitViewController.splitViewItems[1]
            sidebar.animator().isCollapsed = !sidebar.isCollapsed
        }
    }
    
    @IBAction func otherAppsButtonClicked(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://apps.apple.com/sg/developer/vincent-neo/id1523681069")!)
    }
    
    @IBAction func sourceCodeButtonClicked(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://github.com/vincentneo/Avenue-GPX-Viewer")!)
    }
    
    @IBAction func gpxTrackerButtonClicked(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://github.com/merlos/iOS-Open-GPX-Tracker")!)
    }
    
}

class AcknowledgementViewController: NSViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        if let url = Bundle.main.url(forResource: "Credits", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
            webView.load(URLRequest(url: url))
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            }
        }
        else {
            decisionHandler(.allow)
        }
    }
    
}
