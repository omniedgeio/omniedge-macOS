//
//  AppDelegate.swift
//  Omniedge
//
//  Created by An Li on 2021/1/10.
//

import Cocoa

import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    @IBOutlet weak var firstMenuItem: NSMenuItem!
    
    
    
    var statusItem: NSStatusItem?

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        
//        let xpcStore = XPCStore()

        
        
      
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "Omniedge"
        
        if let menu = menu {
            statusItem?.menu = menu
            menu.delegate = self
        }
        
        //        firstMenuItem.view = OmniPanel(frame: NSRect(x: 0.0, y: 0.0, width: 250.0, height: 170.0))
//        let view = NSHostingView(rootView: StatusBarView(xpcStore: xpcStore))
        
        let view = NSSwitch()

        
        view.frame = NSRect(x: 0.0, y: 0.0, width: WIDTH, height: HIGHT)
        
        
        firstMenuItem.view = view
        
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

