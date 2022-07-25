//
//  OmniEdgeMainMenu.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation
import AppKit

class OmniMainMenu: NSMenu {
    
    enum OmniMenuItemType: Int {
        case unknown = 0
        case login
        case dashboard
        case autoUpdate
        case update
        case about
        case quit
    }
    
    private var omniService: IOmniService
    private var menuItems: [OmniMenuItem] = []
    private var myDeviceMenuItem: DetailMenuItem?
    private var networkMenuItem: [NSMenuItem] = []
    
    init(omniService: IOmniService) {
        self.omniService = omniService
        super.init(title: Constants.EmptyText)
        self.omniService.delegate = self
        self.initMainMenu()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initMainMenu() {
        self.delegate = self
        self.addMenuItem(title: "Login", action: #selector(didLoginMenuItemClicked(_:)), keyEquivalent: Constants.EmptyText, menuItemType: .login)
                                        
        self.addItem(NSMenuItem.separator())
        
        self.addMenuItem(title: "Dashboard", action: #selector(didDashboardMenuItemClicked(_:)), keyEquivalent: Constants.EmptyText, menuItemType: .dashboard)
        
        self.addItem(NSMenuItem.separator())
        
        self.addMenuItem(title: "Auto update", action: #selector(didAutoUpdateMenuItemClicked(_:)), keyEquivalent: Constants.EmptyText, menuItemType: .autoUpdate)
        self.addMenuItem(title: "Check for update", action: #selector(didUpdateMenuItemClicked(_:)), keyEquivalent: Constants.EmptyText, menuItemType: .update)
        self.addMenuItem(title: "About OmniEdge", action: #selector(didAboutMenuItemClicked(_:)), keyEquivalent: Constants.EmptyText, menuItemType: .about)
        self.addMenuItem(title: "Quit", action: #selector(didQuitMenuItemClicked(_:)), keyEquivalent: Constants.EmptyText, menuItemType: .quit)
    }
    
    @objc func didLoginMenuItemClicked(_ sender: Any) {
        if self.omniService.hasLoggedIn {
            self.omniService.logout()
            return
        }
        
        self.omniService.login()
    }
    
    @objc func didDashboardMenuItemClicked(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://omniedge.io/dashboard")!)
    }
    
    @objc func didAutoUpdateMenuItemClicked(_ sender: Any) {
        
    }
    
    @objc func didUpdateMenuItemClicked(_ sender: Any) {
        
    }
    
    @objc func didNetworkSelected(_ sender: Any) {
        return
    }
    
    @objc func didAboutMenuItemClicked(_ sender: Any) {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients=["support@omniedge.io"]
        service.subject="OmniEdge macOS Support"
        service.perform(withItems: [""])
    }
    
    @objc func didQuitMenuItemClicked(_ sender: Any) {
        NSApp.terminate(self)
    }
    
    private func reset() {
        self.removeAllItems()
        self.networkMenuItem.removeAll()
        self.myDeviceMenuItem = nil
        self.initMainMenu()
    }
    
    private func addMenuItem(title: String, action: Selector?, keyEquivalent: String, menuItemType: OmniMenuItemType) {
        let menuItem = OmniMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        menuItem.target = self
        menuItem.tag = menuItemType.rawValue
        self.menuItems.append(menuItem)
        self.addItem(menuItem)
    }
    
    private func getMenuItemByTag(tag: Int) -> OmniMenuItem? {
        return self.menuItems.first(where: {$0.tag == tag})
    }
    
    private func populateMyDeviceMenuItem(model: DeviceRegisterModel) {
        let menuItem = DetailMenuItem(title: "My OmniNetwork    This Device")
        menuItem.detail = "\(model.deviceName)  \(model.virtualIp ?? Constants.EmptyText)"
        self.insertItem(menuItem, at: 2)
        self.addItem(NSMenuItem.separator())
        self.myDeviceMenuItem = menuItem
    }
    
    private func populateNetworkList(networks: [VirtualNetworkModel]) {
        self.networkMenuItem.forEach { item in
            self.removeItem(item)
        }
        
        self.networkMenuItem.removeAll()
        var insertAtIndex = self.myDeviceMenuItem == nil ? 2 : 4
        
        let seperator = NSMenuItem.separator()
        self.networkMenuItem.append(seperator)
        self.insertItem(seperator, at: insertAtIndex)
        insertAtIndex += 1
        
        let itemNetworkLabel = OmniMenuItem(title: "My Virtual Networks", action: nil, keyEquivalent: Constants.EmptyText)
        self.networkMenuItem.append(itemNetworkLabel)
        self.insertItem(itemNetworkLabel, at: insertAtIndex)
        insertAtIndex += 1
        var networkIndex = 0
        networks.forEach { model in
            let menuItem = NetworkMenuItem(network: model, networkService: self.omniService.networkService)
            self.networkMenuItem.append(menuItem)
            self.insertItem(menuItem, at: insertAtIndex)
            insertAtIndex += 1
            networkIndex += 1
        }
        self.insertItem(NSMenuItem.separator(), at: insertAtIndex)
    }
}

extension OmniMainMenu: NSMenuDelegate {
}

extension OmniMainMenu: OmniServiceDelegate {
    
    func didLoginSuccess() {
        guard let menuItem = self.getMenuItemByTag(tag: OmniMenuItemType.login.rawValue) else {
            return
        }
        
        menuItem.title = "Log out"
    }
    
    func didLoginFailed() {
        guard let menuItem = self.getMenuItemByTag(tag: OmniMenuItemType.login.rawValue) else {
            return
        }
        
        menuItem.title = "Log in"
    }
    
    func didLogout() {
        guard let menuItem = self.getMenuItemByTag(tag: OmniMenuItemType.login.rawValue) else {
            return
        }
        
        menuItem.title = "Log in"
        self.reset()
    }
    
    func didNetworksLoaded(networks: [VirtualNetworkModel]) {
        DispatchQueue.main.async {
            self.populateNetworkList(networks: networks)
        }
    }
    
    func didDeviceRegister(model: DeviceRegisterModel) {
        DispatchQueue.main.async {
            self.populateMyDeviceMenuItem(model: model)
        }
    }
}
