//
//  Extensions.swift
//  Omniedge
//
//  Created by An Li on 2021/2/4.
//

import Foundation
import Cocoa
extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}


extension NSControl.StateValue{
    
    public func toBool() -> Bool{
        return self == .on
    }
    
    public func toggle() -> NSControl.StateValue{
        return  self == .on ? .off: .on
    }
}
