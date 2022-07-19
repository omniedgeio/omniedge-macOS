//
//  NetworkItemView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 19/7/2022.
//

import Foundation
import AppKit

class NetworkItemView: BaseView {
    override init() {
        super.init()
        self.initView()
        self.initLayout()
    }
    
    convenience init(title: String) {
        self.init()
        self.btnItem.attributedTitle = self.createTitleAttibute(title: title)
        
    }
    
    private func initView() {
        self.addSubview(self.btnItem)
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.btnItem.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.btnItem.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.btnItem.topAnchor.constraint(equalTo: self.topAnchor),
            self.btnItem.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func createTitleAttibute(title: String) -> NSAttributedString {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .left
        
        let attributeText = NSAttributedString(string: title)
        
        return attributeText
    }
    
    @objc private func didItemBtnClicked() {
        
    }
    
    // lazy loading
    private lazy var btnItem: NSButton = {
        let view = NSButton(title: Constants.EmptyText, target: self, action: #selector(didItemBtnClicked))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        view.isBordered = false // This does the trick.
        return view
    }()
}
