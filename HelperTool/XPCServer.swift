//
//  XPCServer.swift
//  HelperTool
//
//  Created by An Li on 2021/1/17.
//

import Foundation

class XPCServer: NSObject {
    
    internal static let shared = XPCServer()
    
    private var listener: NSXPCListener?
    
    internal func start() {
        listener = NSXPCListener(machServiceName: XPCConstant.HelperMachLabel)
        listener?.delegate = self
        listener?.resume()
    }
    
    private func connetionInterruptionHandler() {
        NSLog("[SMJBS]: \(#function)")
    }
    
    private func connectionInvalidationHandler() {
        NSLog("[SMJBS]: \(#function)")
    }
    
//    private func isValidClient(forConnection connection: NSXPCConnection) -> Bool {
//
//        var token = connection.auditToken;
//        let tokenData = Data(bytes: &token, count: MemoryLayout.size(ofValue:token))
//        let attributes = [kSecGuestAttributeAudit : tokenData]
//
//        // Check which flags you need
//        let flags: SecCSFlags = []
//        var code: SecCode? = nil
//        var status = SecCodeCopyGuestWithAttributes(nil, attributes as CFDictionary, flags, &code)
//
//        if status != errSecSuccess {
//            return false
//        }
//
//        guard let dynamicCode = code else {
//            return false
//        }
//        // in this sample we duplicate the requirements from the Info.plist for simplicity
//        // in a commercial application you could want to put the requirements in one place, for example in Active Compilation Conditions (Swift), or in preprocessor definitions (C, Objective-C)
//        let entitlements = "identifier \"com.smjobblesssample.uiapplication\" and anchor apple generic and certificate leaf[subject.CN] = \"Mac Developer: mail@example.com (ABCDEFGHIJ)\""
//        var requirement: SecRequirement?
//
//        status = SecRequirementCreateWithString(entitlements as CFString, flags, &requirement)
//
//        if status != errSecSuccess {
//            return false
//        }
//
//        status = SecCodeCheckValidity(dynamicCode, flags, requirement)
//
//        return status == errSecSuccess
//    }
}

extension XPCServer: NSXPCListenerDelegate {
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        NSLog("[SMJBS]: \(#function)")
        
//        if (!isValidClient(forConnection: newConnection)) {
//            NSLog("[SMJBS]: Client is not valid")
//            return false
//        }
        
        NSLog("[SMJBS]: Client is valid")
        
        let helperTool = HelperToolImpl()
        
        newConnection.exportedInterface = NSXPCInterface(with: HelperTool.self)
        newConnection.exportedObject = helperTool
                
        newConnection.interruptionHandler = connetionInterruptionHandler
        newConnection.invalidationHandler = connectionInvalidationHandler
        
        newConnection.resume()
                
        return true
    }
}
