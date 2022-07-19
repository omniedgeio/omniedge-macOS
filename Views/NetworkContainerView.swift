//
//  NetworkContainerView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 19/7/2022.
//

import Foundation
import AppKit

class NetworkContainerView: BaseView {
    
    private var models: [VirtualNetworkModel]
    private var itemViews: [NSView] = []
    
    init(models: [VirtualNetworkModel]) {
        self.models = models
        super.init()
        self.initView()
        self.initLayout()
    }
    
    private func initView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.containerView)
        self.createNetworkItemViews()
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: Constants.Margins.margin5),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.layoutNetworkItemViews()
    }
    
    private func createNetworkItemViews() {
        self.models.forEach { item in
            let view = NetworkItemView(title: item.vnName)
            view.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(view)
            self.itemViews.append(view)
        }
    }
    
    private func layoutNetworkItemViews() {
        var previousView: NSView?
        
        self.itemViews.forEach { itemView in
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
                itemView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            ])
            
            if previousView == nil {
                itemView.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
            } else {
                itemView.topAnchor.constraint(equalTo: previousView!.bottomAnchor, constant: Constants.Margins.margin10).isActive = true
            }
            
            previousView = itemView
        }
        
        self.itemViews.last?.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
    }
    
    // lazy loading
    private lazy var titleLabel: OmniLabel = {
        let view = OmniLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.stringValue = "My Virtual Networks"
        return view
    }()
    
    
    private lazy var containerView: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
