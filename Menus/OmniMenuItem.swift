//
//  OmniMenuItem.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation
import AppKit

class OmniMenuItem: NSMenuItem {

    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
    }
    
    init(menuView: NSView) {
        super.init(title: Constants.EmptyText, action: nil, keyEquivalent: Constants.EmptyText)
        self.view = menuView
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
