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
        super.init(title: String.Empty, action: nil, keyEquivalent: String.Empty)
    }
    
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
