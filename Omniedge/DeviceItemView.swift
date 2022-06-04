//
//  DeviceItemView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 4/6/2022.
//

import Foundation
import AppKit

class DeviceItemView: NSView {

    private var model: DeviceRegisterModel
    
    init(model: DeviceRegisterModel) {
        self.model = model
        super.init(frame: .zero)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.ipRange)
        self.addSubview(self.countryFlag)
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 5),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.ipRange.leadingAnchor,constant: -10),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 150),
            
            self.ipRange.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.ipRange.trailingAnchor.constraint(equalTo: self.countryFlag.leadingAnchor, constant: -5),
            self.ipRange.widthAnchor.constraint(equalToConstant: 105),
            
            self.countryFlag.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10),
            self.countryFlag.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.countryFlag.widthAnchor.constraint(equalToConstant: 40),
            self.countryFlag.heightAnchor.constraint(equalToConstant:30)
        ])
    }
    
    // Lazy loading
    private lazy var titleLabel: NSTextField = {
        let view = NSTextField()
        view.stringValue = self.model.deviceName
        view.usesSingleLineMode = false
        view.isEditable = false
        view.isBezeled = false
        view.alignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.sizeToFit()
        return view
    }()
    
    private lazy var ipRange: NSTextField = {
        let view = NSTextField()
        view.stringValue = "100.100.100.113"
        view.isEditable = false
        view.isBezeled = false
        view.alignment = .left
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.sizeToFit()
        return view
    }()
    
    private lazy var countryFlag: NSImageView = {
        let view = NSImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
