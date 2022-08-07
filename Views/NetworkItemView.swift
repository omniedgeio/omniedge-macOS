//
//  NetworkItemView.swift
//  Omniedge
//
//  Created by Yanbo Dang on 19/7/2022.
//

import Foundation
import AppKit

class NetworkItemView: BaseView {

    private var isMouseOver: Bool = false {
        didSet {
            self.backgroundColor = isMouseOver ? .blue : .clear
        }
    }
    
    private var backgroundColor: NSColor? {
        didSet {
            self.setNeedsDisplay(self.bounds)
        }
    }
    
    private var didAddTrackingArea: Bool = false
    
    override init() {
        super.init()
        self.initView()
        self.initLayout()
    }
    
    convenience init(title: String) {
        self.init()
        self.titleLabel.stringValue = title
    }
    
    private func initView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.detailIndicator)
    }
    
    private func initLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.detailIndicator.leadingAnchor, constant: -Constants.Margins.margin10),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.Margins.margin5),
            self.titleLabel.bottomAnchor.constraint(equalTo:self.bottomAnchor, constant: -Constants.Margins.margin5),
            
            self.detailIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.detailIndicator.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.detailIndicator.widthAnchor.constraint(equalTo: self.detailIndicator.heightAnchor)
        ])
        
        self.detailIndicator.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        self.detailIndicator.setContentCompressionResistancePriority(.defaultLow + 1, for: .horizontal)
    }
    
    @objc private func didTitleLabelClicked() {
        return
    }
    
//    override func updateTrackingAreas() {
//        var trackingAreas = self.trackingAreas
//        trackingAreas.removeAll()
//        print(self.bounds)
//        let hoverArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeInActiveApp, .inVisibleRect, .assumeInside, .cursorUpdate], owner: self, userInfo: nil)
//        self.addTrackingArea(hoverArea)
//    }
//
//    override func mouseEntered(with event: NSEvent) {
//        self.isMouseOver = true
//    }
//
//    override func mouseExited(with event: NSEvent) {
//        self.isMouseOver = false
//    }
    
    private lazy var titleLabel: OmniLabel = {
        let view = OmniLabel()
        view.font = NSFont.systemFont(ofSize: 14)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addClick(target: self, action: #selector(didTitleLabelClicked))
        return view
    }()
    
    private lazy var detailIndicator: OmniLabel = {
        let view = OmniLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.stringValue = "〉"
        return view
    }()
}
