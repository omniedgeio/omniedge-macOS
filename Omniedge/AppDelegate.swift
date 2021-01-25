//
//  AppDelegate.swift
//  Omniedge
//
//  Created by An Li on 2021/1/10.
//

import Cocoa
import OGSwitch
import SwiftUI
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    @IBOutlet weak var firstMenuItem: NSMenuItem!
    
    
    @IBOutlet weak var customeView: OGSwitch!
    
    var statusItem: NSStatusItem?
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
    }
    
    
    var xpcStore: XPCStore?
    
    @IBAction func switchPressed(_ sender: Any) {
        if let button = sender as? OGSwitch{
            switchLabel.stringValue = button.isOn ? "On":"Off"
            
            if(button.isOn){
                self.xpcStore?.helperTool?.install()
            }else{
                self.xpcStore?.helperTool?.uninstall()
            }
            
        }
        
        
        
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.xpcStore = XPCStore()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "📡"
        
        if let menu = menu {
            statusItem?.menu = menu
            menu.delegate = self
        }
        
        //        firstMenuItem.view = OmniPanel(frame: NSRect(x: 0.0, y: 0.0, width: 250.0, height: 170.0))
        //        let view = NSHostingView(rootView: StatusBarView(xpcStore: xpcStore))
        //
        //        view.frame = NSRect(x: 0.0, y: 0.0, width: WIDTH, height: HIGHT)
        
        
        firstMenuItem.view = customeView
        
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

