//
//  OmniLabel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
import AppKit

class OmniLabel: NSTextField {
    
    init() {
        super.init(frame: .zero)
        self.usesSingleLineMode = false
        self.isEditable = false
        self.isBezeled = false
        self.alignment = .left
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
