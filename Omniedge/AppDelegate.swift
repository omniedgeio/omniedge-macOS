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
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    @IBOutlet weak var firstMenuItem: NSMenuItem!
    
    @IBOutlet weak var autoLaunch: NSMenuItem!
    
    @IBAction func pressAutoLaunch(_ sender: NSMenuItem) {
        sender.state = sender.state == .on ? .off : .on
        UserDefaults.standard.set(sender.state, forKey: AUTO_LAUNCH)
        NSLog("Set login item switch to: \(sender.state == .on ? true : false)")

        let result = SMLoginItemSetEnabled(AUTO_LAUNCH_HELPER as CFString, sender.state == .on ? true : false)
        NSLog("Set login item success: \(result)")

        
    }
    
    @IBOutlet weak var updater: SUUpdater!
    
    @IBOutlet weak var autoUpdate: NSMenuItem!
    
    @IBAction func pressAutoUpdate(_ sender: NSMenuItem) {
        sender.state = sender.state == .on ? .off : .on
        UserDefaults.standard.set(sender.state, forKey: AUTO_UPDATE)
        updater.automaticallyChecksForUpdates = sender.state == .on ? true:false
    }
    
    
    
    
    
    
    
    
    @IBOutlet weak var customeView: OGSwitch!
    
    var statusItem: NSStatusItem?
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
    }
    
    
    var xpcStore: XPCStore?
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.xpcStore = XPCStore()
        
        let userDefaults = UserDefaults.standard
        if let autoLaunchFlag =  userDefaults.object(forKey: AUTO_LAUNCH) as? NSControl.StateValue{
            autoLaunch.state = autoLaunchFlag
        }else{
            autoLaunch.state = .on //default
            let result = SMLoginItemSetEnabled(AUTO_LAUNCH_HELPER as CFString, true)
            NSLog("Set login item success: \(result)")

        }
        
        
        if let autoUpdateFlag =  userDefaults.object(forKey: AUTO_UPDATE) as? NSControl.StateValue{
            autoUpdate.state = autoUpdateFlag
        }else{
            autoUpdate.state = .on //default
            updater.automaticallyChecksForUpdates = true

        }
    
        
        
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
    
    
}

