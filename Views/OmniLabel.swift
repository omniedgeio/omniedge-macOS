//
//  OmniLabel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
import AppKit

class OmniLabel: NSTextField {
    
    private var clickGesture: NSClickGestureRecognizer
    
    init() {
        self.clickGesture = NSClickGestureRecognizer()
        super.init(frame: .zero)
        self.initLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addClick(target: AnyObject, action: Selector) {
        self.clickGesture.target = target
        self.clickGesture.action = action
    }
    
    private func initLabel() {
        self.usesSingleLineMode = false
        self.isEditable = false
        self.isBezeled = false
        self.alignment = .left
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.addGestureRecognizer(self.clickGesture)
    }
}
