//
//  XPCClient.swift
//  Omniedge
//
//  Created by An Li on 2021/1/17.
//

import Foundation
import os

class XPCClient {
    
    var connection: NSXPCConnection?
    
    func start() {
        connection = NSXPCConnection(machServiceName: Constant.helperMachLabel,
                                         options: .privileged)
        
        connection?.exportedInterface = NSXPCInterface(with: InstallationClient.self)
        connection?.exportedObject = InstallationClientImpl()
        connection?.remoteObjectInterface = NSXPCInterface(with: HelperTool.self)
        
        connection?.invalidationHandler = connectionInvalidationHandler
        connection?.interruptionHandler = connetionInterruptionHandler
        
        connection?.resume()

        let helperTool = connection?.remoteObjectProxy as? HelperTool
        
        helperTool?.install()
    }
    
    private func connetionInterruptionHandler() {
        NSLog("[XPCTEST] \(type(of: self)): connection has been interrupted XPCTEST")
    }
    
    private func connectionInvalidationHandler() {
        NSLog("[XPCTEST] \(type(of: self)): connection has been invalidated XPCTEST")
    }
}

class InstallationClientImpl: NSObject, InstallationClient {
    
    func installationDidReachProgress(_ progress: Double, description: String?) {
        NSLog("[XPCTEST]: \(#function)")
    }
}
