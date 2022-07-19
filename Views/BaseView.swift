//
//  BaseView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 19/7/2022.
//

import Foundation
import AppKit

class BaseView: NSView {
    
    init() {
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
