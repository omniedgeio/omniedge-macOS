//
//  OmniMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation
import AppKit

class OmniMenuItem: NSMenuItem {
    
    init() {
        super.init(title: Constants.EmptyText, action: nil, keyEquivalent: Constants.EmptyText)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
