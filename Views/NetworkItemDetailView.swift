//
//  NetworkItemDetailView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 20/7/2022.
//

import Foundation
import OGSwitch

protocol NetworItemDetailViewDelegate: AnyObject {
    func didToggled(on: Bool, model: VirtualNetworkModel, contentView: NetworkItemDetailView);
}

class NetworkItemDetailView: BaseView {
    weak public var delegate: NetworItemDetailViewDelegate?
    
    var swicher: OGSwitch {
        get{
            return self.toggleSwitch
        }
    }
    
    private var seperatorBottomCopnstraint: NSLayoutConstraint?
    private var model: VirtualNetworkModel
    private var deviceItemViews: [DeviceItemView] = []
    
    init(model: VirtualNetworkModel) {
        self.model = model
        super.init()
        self.initView()
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateModel(model: VirtualNetworkModel) {
        self.deviceItemViews.forEach { item in
            item.removeFromSuperview()
        }
        
        self.deviceItemViews.removeAll()
        
        if self.model.devices?.isEmpty ?? true {
            self.seperatorBottomCopnstraint?.isActive = false
            if self.seperatorBottomCopnstraint != nil {
                self.seperator.removeConstraint(self.seperatorBottomCopnstraint!)
            }
        }
        
        self.model = model
        
        self.createDeviceItemView()
        self.layoutDeviceItemViews()
        
    }
    
    private func initView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLabel)
        self.addSubview(self.toggleSwitch)
        self.addSubview(self.seperator)
        self.createDeviceItemView()
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.toggleSwitch.leadingAnchor, constant: -10),
            
            self.toggleSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            self.toggleSwitch.widthAnchor.constraint(equalToConstant: 40.0),
            self.toggleSwitch.heightAnchor.constraint(equalToConstant: 20.0),
            self.toggleSwitch.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            
            self.seperator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.seperator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.seperator.heightAnchor.constraint(equalToConstant: 1.0),
            self.seperator.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5),
        ])
        
        self.layoutDeviceItemViews()
    }
    
    private func createDeviceItemView() {
        self.model.devices?.forEach { device in
            let view = DeviceItemView(model: device)
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            self.deviceItemViews.append(view)
        }
    }
    
    private func layoutDeviceItemViews() {
        if self.deviceItemViews.count == 0 {
            self.seperatorBottomCopnstraint = self.seperator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
            self.seperatorBottomCopnstraint?.isActive = true
            self.widthAnchor.constraint(equalToConstant: 325).isActive = true
            return
        }
        
        var previousView: NSView = self.seperator
        self.deviceItemViews.forEach { itemView in
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                itemView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
                itemView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 5),
            ])
            
            previousView = itemView
        }
        
        self.deviceItemViews.last?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }
    
    @objc private func didToggled() {
        self.delegate?.didToggled(on: self.toggleSwitch.isOn, model: self.model, contentView: self)
    }
    
    // Lazy loading
    private lazy var titleLabel: NSTextField = {
        let view = NSTextField()
        view.stringValue = self.model.vnName
        view.usesSingleLineMode = false
        view.isEditable = false
        view.isBezeled = false
        view.alignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.sizeToFit()
        return view
    }()
    
    private lazy var toggleSwitch: OGSwitch = {
        let view = OGSwitch()
        view.target = self
        view.action = #selector(didToggled)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var seperator: NSView = {
        let view = NSView()
        view.layer?.backgroundColor = NSColor.yellow.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
