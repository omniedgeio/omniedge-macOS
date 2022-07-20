//
//  Utils.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
import ServiceManagement
import AppKit

class Utils {
    
    static func fromHex(hex: String) -> CGColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        return CGColor(red: r, green: g, blue: b, alpha: a)
    }
    
    @discardableResult
    static func blessHelper(label: String, authorization: AuthorizationRef) -> Bool {
        
        var error: Unmanaged<CFError>?
        let blessStatus = SMJobBless(kSMDomainSystemLaunchd, label as CFString, authorization, &error)
        
        if !blessStatus {
            NSLog("[SMJBS]: Helper bless failed with error \(error!.takeUnretainedValue())")
            
        }
        
        return blessStatus
    }
    
    static func askAuthorization() -> AuthorizationRef? {
        
        var auth: AuthorizationRef?
        let status: OSStatus = AuthorizationCreate(nil, nil, [], &auth)
        if status != errAuthorizationSuccess {
            NSLog("[SMJBS]: Authorization failed with status code \(status)")
            
            return nil
        }
        
        return auth
    }
    
    static func alert(title: String, description: String, _ style: NSAlert.Style) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = description
            alert.alertStyle = style
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    static func findEthernetInterfaces() -> io_iterator_t? {

        let matchingDict = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary
        matchingDict["IOPropertyMatch"] = [ "IOPrimaryInterface" : true]

        var matchingServices : io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &matchingServices) != KERN_SUCCESS {
            return nil
        }

        return matchingServices
    }
    
    static func getMACAddress(_ intfIterator : io_iterator_t) -> [UInt8]? {

        var macAddress : [UInt8]?

        var intfService = IOIteratorNext(intfIterator)
        while intfService != 0 {

            var controllerService : io_object_t = 0
            if IORegistryEntryGetParentEntry(intfService, "IOService", &controllerService) == KERN_SUCCESS {

                let dataUM = IORegistryEntryCreateCFProperty(controllerService, "IOMACAddress" as CFString, kCFAllocatorDefault, 0)
                if let data = dataUM?.takeRetainedValue() as? NSData {
                    macAddress = [0, 0, 0, 0, 0, 0]
                    data.getBytes(&macAddress!, length: macAddress!.count)
                }
                IOObjectRelease(controllerService)
            }

            IOObjectRelease(intfService)
            intfService = IOIteratorNext(intfIterator)
        }

        return macAddress
    }
}
