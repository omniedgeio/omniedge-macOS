//
//  DeviceItemView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 20/7/2022.
//

import Foundation
import AppKit

class DeviceItemView: BaseView {
    
    private var model: DeviceRegisterModel
    
    init(model: DeviceRegisterModel) {
        self.model = model
        super.init()
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
    private lazy var titleLabel: OmniLabel = {
        let view = OmniLabel()
        view.stringValue = self.model.deviceName
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var ipRange: OmniLabel = {
        let view = OmniLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var countryFlag: NSImageView = {
        let view = NSImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
