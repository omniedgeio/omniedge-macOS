//
//  NetworkItemDetailView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 20/7/2022.
//

import Foundation
import OGSwitch

protocol NetworItemDetailViewDelegate: AnyObject {
    func didToggled(on: Bool);
}

class NetworkItemDetailView: BaseView {
    weak public var delegate: NetworItemDetailViewDelegate?
    
    private var seperatorBottomCopnstraint: NSLayoutConstraint?
    private var model: VirtualNetworkModel
    private var deviceItemViews: [OmniLabel] = []
    
    init(model: VirtualNetworkModel) {
        self.model = model
        super.init()
        self.initView()
        self.initLayout()
    }
    
    func toggleOff() {
        self.connSwitch.setOn(isOn: false, animated: true)
    }
    
    func toggleOn() {
        self.connSwitch.setOn(isOn: true, animated: true)
    }
    
    private func initView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.deviceListTitle)
        self.addSubview(self.connSwitch)
        self.addSubview(self.seperator)
        self.createDeviceItemView()
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.connSwitch.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.Margins.margin5),
            self.connSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.Margins.margin5),
            self.connSwitch.widthAnchor.constraint(equalToConstant: 40),
            self.connSwitch.heightAnchor.constraint(equalToConstant: 20),
            
            self.deviceListTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.Margins.margin5),
            self.deviceListTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.Margins.margin5),
            self.deviceListTitle.trailingAnchor.constraint(equalTo: self.connSwitch.leadingAnchor, constant: Constants.Margins.margin5),
            
            self.seperator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.seperator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.seperator.topAnchor.constraint(equalTo: self.connSwitch.bottomAnchor, constant: Constants.Margins.margin5),
            self.seperator.heightAnchor.constraint(equalToConstant: 1.0),
            
            self.widthAnchor.constraint(equalToConstant: 290)
        ])
        
        self.layoutDeviceItemViews()
    }
    
    private func createDeviceItemView() {
        self.model.devices?.forEach { device in
            let view = OmniLabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.stringValue = "\(device.deviceName)  \(device.virtualIp ?? String.Empty)"
            self.deviceItemViews.append(view)
            self.addSubview(view)
        }
    }
    
    private func layoutDeviceItemViews() {
        if self.deviceItemViews.count == 0 {
            self.seperatorBottomCopnstraint = self.seperator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
            self.seperatorBottomCopnstraint?.isActive = true
            return
        }
        
        var previousView: NSView = self.seperator
        self.deviceItemViews.forEach { itemView in
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: self.deviceListTitle.leadingAnchor),
                itemView.trailingAnchor.constraint(equalTo: self.deviceListTitle.trailingAnchor),
                itemView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: Constants.Margins.margin10),
            ])
            
            previousView = itemView
        }
        
        self.deviceItemViews.last?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.Margins.margin10).isActive = true
    }
    
    @objc private func didToggled() {
        self.delegate?.didToggled(on: self.connSwitch.isOn)
    }
    
    // Lazy loading
    private lazy var deviceListTitle: OmniLabel = {
        let view = OmniLabel()
        view.stringValue = "Devices of " + model.vnName
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var connSwitch: OGSwitch = {
        let view = OGSwitch()
        view.target = self
        view.action = #selector(didToggled)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var seperator: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
