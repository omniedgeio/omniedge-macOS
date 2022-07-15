//
//  TextMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Cocoa

class TextMenuItem: OmniMenuItem {
    
    override init() {
        super.init()
        self.initMenuItem()
        self.initLayout()
    }
    
    private func initMenuItem() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.menuLable)
        self.view = self.contentView
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Constants.Margins.margin10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Constants.Margins.margin10),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Constants.Margins.margin5),
            
            self.menuLable.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.menuLable.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.menuLable.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: Constants.Margins.margin5),
            self.menuLable.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Constants.Margins.margin5),
            
            self.contentView.widthAnchor.constraint(equalToConstant: Constants.Size.menuItemWidth250)
        ])
    }
    
    // Lazy loading
    private lazy var titleLabel: NSTextField = {
        let view = OmniLabel()
        view.stringValue = "My OmniNetwork Current Device"
        view.textColor = Constants.Colors.C_6C6C6C
        return view
    }()
    
    private lazy var menuLable: NSTextField = {
        let view = OmniLabel()
        view.stringValue = "Yong's Macbook"
        view.textColor = Constants.Colors.C_3D3D3D
        return view
    }()
    
    private lazy var contentView: NSView = {
        let view = NSView()
        view.layer?.backgroundColor = Constants.Colors.C_F1F1F1.cgColor
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }()
}
