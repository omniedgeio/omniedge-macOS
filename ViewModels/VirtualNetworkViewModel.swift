//
//  VirtualNetworkViewModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation

protocol VirtualNetworkDelegate: AnyObject {
    
}

protocol IVirtualNetworkViewMdel {
    func queryNetworks(token: String)
    func registerDevice(token: String, deviceInfo: DeviceModel)
    func joinDevice(token: String, deviceId: String, networkUuid: String)
}

class VirtualNetworkViewMdel: BaseViewModel, IVirtualNetworkViewMdel {

    private weak var delegate: VirtualNetworkDelegate?
    
    func queryNetworks(token: String) {
        
    }
    
    func registerDevice(token: String, deviceInfo: DeviceModel) {
        
    }
    
    func joinDevice(token: String, deviceId: String, networkUuid: String) {
        
    }
}
