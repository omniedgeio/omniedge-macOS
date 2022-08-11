//
//  NetworkMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
import AppKit

class NetworkMenuItem: OmniMenuItem {
    
    var networkService: IVirtualNetworkService?
    var cacheService: ICacheService?
    
    private var model: VirtualNetworkModel
    private var detailMenuView: NetworkItemDetailView?
    
    init(network: VirtualNetworkModel, networkService: IVirtualNetworkService) {
        self.model = network
        self.networkService = networkService
        super.init()
        self.initMenu()
    }
    
    
    private func initMenu() {
        self.title = model.vnName
        self.action = #selector(didNetworkSelected)
        self.target = self
        self.submenu = NSMenu()
        self.submenu?.delegate = self
        let menuItem = OmniMenuItem()
        self.detailMenuView = NetworkItemDetailView(model: self.model)
        self.detailMenuView?.delegate = self
        menuItem.view = self.detailMenuView
        self.submenu?.addItem(menuItem)
    }
    
    @objc private func didNetworkSelected() {
        return
    }
    
    private func toggleOff() {
        DispatchQueue.main.async {
            self.detailMenuView?.toggleOff()
        }
    }
}

extension NetworkMenuItem: NetworItemDetailViewDelegate {
    func didToggled(on: Bool) {
        
        if !on {
            self.networkService?.disconnectNetwork()
            return
        }
        
        // join device first
        self.networkService?.joinDeviceInNetwork(vnId: self.model.vnId)

    }
}

extension NetworkMenuItem: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        guard let curVnId = self.networkService?.curConnectedNetworkId else {
            return
        }
        
        if curVnId != self.model.vnId {
            self.toggleOff()
        }
    }
}
