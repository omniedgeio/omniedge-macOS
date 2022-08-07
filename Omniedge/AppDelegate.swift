//
//  AppDelegate.swift
//  Omniedge
//
//  Created by An Li on 2021/1/10.
//

import Cocoa

@available(macOS 10.15, *)
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var omniService: IOmniService!
    private var statusItem: NSStatusItem!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let locatorService = LocatorService.shareInstance()
        self.registerServices(locatorService: locatorService)
        self.omniService = OmniService(locatorService: locatorService)
        self.omniService.initService()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem?.button?.image = NSImage(named: "StatusBarIcon")
        self.statusItem.menu = OmniMainMenu(omniService: self.omniService)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        self.omniService.terminate()
    }
    
    func didLogin(login: Bool) {
        let imageName = login ? "Connected" : "Disconnected"
        self.statusItem.button?.image = NSImage(named: imageName)
    }
}

extension AppDelegate {
    
    private func registerServices(locatorService: ILocatorService){
        locatorService.register(instance: HttpService() as IHttpService)
        locatorService.register(instance: XPCService() as IXPCService)
        locatorService.register(instance: CacheService() as ICacheService)
    }
}
