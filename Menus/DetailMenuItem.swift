//
//  OmniDetailMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 19/7/2022.
//

import Foundation
import SwiftUI

class DetailMenuItem: ContentMenuItem {
    
    override var title: String {
        get {
            return self.titleLable.stringValue
        }
        set {
            self.titleLable.stringValue = newValue
        }
    }
    
    var detail: String {
        get {
            return self.detailLabel.stringValue
        }
        set {
            self.detailLabel.stringValue = newValue
        }
    }
    
    override init() {
        super.init()
        self.initMenu()
        self.initLayout()
    }
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    private func initMenu() {
        self.contentView.addSubview(self.titleLable)
        self.contentView.addSubview(self.detailLabel)
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.titleLable.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Constants.Margins.margin10),
            self.titleLable.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Constants.Margins.margin10),
            self.titleLable.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Constants.Margins.margin5),
            
            self.detailLabel.leadingAnchor.constraint(equalTo: self.titleLable.leadingAnchor),
            self.detailLabel.trailingAnchor.constraint(equalTo: self.titleLable.trailingAnchor),
            self.detailLabel.topAnchor.constraint(equalTo: self.titleLable.bottomAnchor, constant: Constants.Margins.margin5),
            self.detailLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Constants.Margins.margin5)
        ])
    }
    
    // lazy loading
    private lazy var titleLable: OmniLabel = {
        let view = OmniLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = NSColor.yellow
        return view
    }()
    
    private lazy var detailLabel: OmniLabel = {
        let view = OmniLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = NSColor.white
        return view
    }()
}
