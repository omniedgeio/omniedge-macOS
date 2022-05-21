//
//  VirtualNetworkContainerView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 21/5/2022.
//

import Cocoa

class VirtualNetworkContainerView: NSView {
    private var virtualNetworks: [VirtualNetworkModel]
    private var viewItems: [NSView] = []
    
    init(virtualNetworks: [VirtualNetworkModel]) {
        self.virtualNetworks = virtualNetworks
        super.init(frame: .zero)
        
        self.initView()
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.virtualNetworks.forEach { item in
            let view = VirtualNetworkItemView(model: item)
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            self.viewItems.append(view)
        }
    }
    
    private func initLayout() {
        
        var previousItem: NSView?
        self.viewItems.forEach { item in
            item.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            item.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10).isActive = true
            if previousItem == nil {
                item.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            } else {
                item.topAnchor.constraint(equalTo: previousItem!.bottomAnchor, constant: 5).isActive = true
            }
            
            previousItem = item
        }
        
        self.viewItems.last?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
    }
}
