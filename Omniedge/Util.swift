//
//  Util.swift
//  Omniedge
//
//  Created by An Li on 2021/1/17.
//

import SecurityFoundation
import ServiceManagement
import Cocoa

struct Util {
    
    static func askAuthorization() -> AuthorizationRef? {
        
        var auth: AuthorizationRef?
        let status: OSStatus = AuthorizationCreate(nil, nil, [], &auth)
        if status != errAuthorizationSuccess {
            NSLog("[SMJBS]: Authorization failed with status code \(status)")
            
            return nil
        }
        
        return auth
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
}


func alert(title: String, description: String, _ style: NSAlert.Style) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = description
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    
}


func FindEthernetInterfaces() -> io_iterator_t? {

    let matchingDict = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary
    matchingDict["IOPropertyMatch"] = [ "IOPrimaryInterface" : true]

    var matchingServices : io_iterator_t = 0
    if IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &matchingServices) != KERN_SUCCESS {
        return nil
    }

    return matchingServices
}

func GetMACAddress(_ intfIterator : io_iterator_t) -> [UInt8]? {

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


