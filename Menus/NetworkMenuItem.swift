//
//  NetworkMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
import AppKit

class NetworkMenuItem: OmniMenuItem {
    
    private var model: VirtualNetworkModel
    
    init(network: VirtualNetworkModel) {
        self.model = network
        super.init()
        self.initMenu()
    }
    
    
    private func initMenu() {
        self.title = model.vnName
        self.action = #selector(didNetworkSelected)
        self.target = self
        self.submenu = NSMenu()
        let menuItem = OmniMenuItem()
        menuItem.view = NetworkItemDetailView(model: self.model)
        self.submenu?.addItem(menuItem)
    }
    
    @objc private func didNetworkSelected() {
        return
    }
}
