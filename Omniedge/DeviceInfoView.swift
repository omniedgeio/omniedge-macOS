//
//  DeviceInfo.swift
//  Omniedge
//
//  Created by An Li on 2021/2/17.
//

import Cocoa

class DeviceInfoView: NSView,NibLoadable {
    
    @IBOutlet var contentView: NSView!
    
    
    @IBOutlet weak var deviceName: NSTextField!
    
    @IBOutlet weak var ip: NSTextField!
    
    @IBOutlet weak var ping: NSTextField!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadViewFromNib()
    }
}


protocol NibLoadable {
    var contentView: NSView! { get }
}

extension NibLoadable where Self: NSView {
    
    
    
    
    
    func loadViewFromNib() {
        
        guard let myName = type(of: self)
                .className()
                .components(separatedBy: ".")
                .last else {
            return
        }
        
        
        let nib = NSNib(nibNamed: myName,
                        bundle: Bundle(for: type(of: self)))!
        nib.instantiate(withOwner: self, topLevelObjects: nil)
        
        self.frame = contentView.frame
        
        var newConstraints: [NSLayoutConstraint] = []
        
        
        
        for oldConstraint in contentView.constraints {
            let firstItem = oldConstraint.firstItem === contentView ? self : oldConstraint.firstItem
            let secondItem = oldConstraint.secondItem === contentView ? self : oldConstraint.secondItem
            
            newConstraints.append(
                NSLayoutConstraint(item: firstItem as Any,
                                   attribute: oldConstraint.firstAttribute,
                                   relatedBy: oldConstraint.relation,
                                   toItem: secondItem,
                                   attribute: oldConstraint.secondAttribute,
                                   multiplier: oldConstraint.multiplier,
                                   constant: oldConstraint.constant)
            )
        }
        
        for newView in contentView.subviews{
            self.addSubview(newView)
        }
        
        self.addConstraints(newConstraints)
    }
}
