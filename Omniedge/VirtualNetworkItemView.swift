//
//  VirtualNetworkItemView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 21/5/2022.
//

import Cocoa
import OGSwitch

protocol VirtualNetworItemViewDelegate: AnyObject {
    func didToggled(on: Bool, model: VirtualNetworkModel);
}

class VirtualNetworkItemView: NSView {

    weak public var delegate: VirtualNetworItemViewDelegate?
    
    private var model: VirtualNetworkModel
    
    init(model: VirtualNetworkModel) {
        self.model = model
        super.init(frame: .zero)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLabel)
        self.addSubview(self.ipRangeLable)
        self.addSubview(self.toggleSwitch)
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 150),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.ipRangeLable.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 20),
            self.ipRangeLable.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.ipRangeLable.widthAnchor.constraint(equalToConstant: 150),
            
            self.toggleSwitch.leadingAnchor.constraint(equalTo: self.ipRangeLable.trailingAnchor),
            self.toggleSwitch.centerYAnchor.constraint(equalTo: self.ipRangeLable.centerYAnchor),
            self.toggleSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            self.toggleSwitch.widthAnchor.constraint(equalToConstant: 60.0),
            self.toggleSwitch.heightAnchor.constraint(equalToConstant: 30.0),
            
            self.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func didToggled() {
        self.delegate?.didToggled(on: self.toggleSwitch.isOn, model: self.model)
    }
    
    // Lazy loading
    private lazy var titleLabel: NSTextField = {
        let view = NSTextField()
        view.stringValue = self.model.vnName
        view.isEditable = false
        view.isBezeled = false
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var ipRangeLable: NSTextField = {
        let view = NSTextField()
        view.stringValue = self.model.ipRange
        view.isEditable = false
        view.isBezeled = false
        view.alignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var toggleSwitch: OGSwitch = {
        let view = OGSwitch()
        view.target = self
        view.action = #selector(didToggled)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
}
