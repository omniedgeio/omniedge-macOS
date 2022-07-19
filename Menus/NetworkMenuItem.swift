//
//  NetworkMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
import AppKit

class NetworkMenuItem: ContentMenuItem {
    
    private var models: [VirtualNetworkModel]

    init(networks: [VirtualNetworkModel]) {
        self.models = networks
        super.init()
        self.initMenu()
        self.initLayout()
    }
    
    
    private func initMenu() {
        self.contentView.addSubview(self.networkView)
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.networkView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Constants.Margins.margin10),
            self.networkView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Constants.Margins.margin10),
            self.networkView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.networkView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    // lazy loading
    private lazy var networkView: NetworkContainerView = {
        let view = NetworkContainerView(models: self.models)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
