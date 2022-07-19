//
//  ContentMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 19/7/2022.
//

import Foundation
import AppKit

class ContentMenuItem: OmniMenuItem {
    
    init() {
        super.init(title: Constants.EmptyText, action: nil, keyEquivalent: Constants.EmptyText)
        self.initMenu()
        self.initLayout()
    }
    
    private func initMenu() {
        self.view = self.contentView
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.contentView.widthAnchor.constraint(equalToConstant: Constants.Size.menuItemWidth233)
        ])
    }
    
    // lazy loading
    lazy var contentView: NSView = {
        let view = NSView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
