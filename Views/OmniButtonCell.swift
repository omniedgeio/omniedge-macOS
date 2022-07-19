//
//  OmniButtonCell.swift
//  Omniedge
//
//  Created by Yanbo Dang on 19/7/2022.
//

import Foundation
import AppKit

// https://gist.github.com/marteinn/fa9301ad349b755da2e6
class OmniButtonCell: NSButtonCell {
    
//    - (NSRect)titleRectForBounds:(NSRect)theRect {
//        NSRect titleFrame = [super titleRectForBounds:theRect];
//        NSSize titleSize = [[self attributedStringValue] size];
//
//        titleFrame.origin.y = theRect.origin.y-(theRect.size.height-titleSize.height)*0.5;
//
//        return titleFrame;
//    }
    
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        var titleFrame = super.titleRect(forBounds: rect)
        titleFrame.origin.x = 0
        
        return titleFrame
    }
}
