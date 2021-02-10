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
        UserDefaults.standard.set(sender.state.toggle(), forKey: AUTO_LAUNCH_DEFAULT_KEY)
        let result = SMLoginItemSetEnabled(AUTO_LAUNCH_HELPER as CFString, sender.state.toggle().toBool() )
        NSLog("Set login item success: \(result)")
        
        updateUI()
    }
    
    @IBOutlet weak var updater: SUUpdater!
    
    @IBOutlet weak var autoUpdate: NSMenuItem!
    
    @IBAction func pressAutoUpdate(_ sender: NSMenuItem) {
        UserDefaults.standard.set(sender.state.toggle(), forKey: AUTO_UPDATE_DEFAULT_KEY)
        updateUI()
    }
    
    
    
    @IBOutlet weak var customeView: OGSwitch!
    
    var statusItem: NSStatusItem?
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
    }
    
    
    var xpcStore: XPCStore?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    @objc private func handleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue else {
            return
        }
        
        guard let url = URL(string: urlString) else{
            return
        }
        
        if let host = url.host, host == "signin"{
            let params = url.queryParameters
            guard let code = params?["code"] else{
                return
            }
            
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(code, forKey: LOGIN_TOKEN_KEY)
            
        }
        
        
        
        
        NSLog("URL is: \(urlString)")
        
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        self.xpcStore = XPCStore()
        
        updateUI()
        
    }
    
    func updateUI(){
        let userDefaults = UserDefaults.standard
        //        if let autoLaunchFlag =  userDefaults.object(forKey: AUTO_LAUNCH_DEFAULT_KEY) as? NSControl.StateValue{
        //            autoLaunch.state = autoLaunchFlag
        //        }else{
        //            autoLaunch.state = .on //default
        //            let result = SMLoginItemSetEnabled(AUTO_LAUNCH_HELPER as CFString, true)
        //            NSLog("Set login item success: \(result)")
        //
        //        }
        
        
        if let autoUpdateFlag =  userDefaults.object(forKey: AUTO_UPDATE_DEFAULT_KEY) as? NSControl.StateValue{
            
            autoUpdate.state = autoUpdateFlag
            updater.automaticallyChecksForUpdates =  autoUpdate.state.toBool()
            
        }else{
            //defaults
            autoUpdate.state = .on
            updater.automaticallyChecksForUpdates = true
            userDefaults.set(autoUpdate.state, forKey: AUTO_UPDATE_DEFAULT_KEY)
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

