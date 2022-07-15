//
//  OmniEdgeMainMenu.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation
import AppKit

class OmniMainMenu: NSMenu {
    private var mainMenu: NSMenu = NSMenu()
    
    init() {
        super.init(title: Constants.EmptyText)
        self.initMainMenu()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initMainMenu() {
        
        self.mainMenu.addItem(TextMenuItem())
        self.mainMenu.addItem(TextMenuItem())
        self.mainMenu.addItem(TextMenuItem())
    }
}

extension OmniMainMenu: NSMenuDelegate {
    
}
