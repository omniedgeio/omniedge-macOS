//
//  XCPService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation
import AppKit

protocol IXPCService: IService {
    func installAndConnectHeperTool()
}

class XPCService: BaseService, IXPCService {
    private var XPCConnection: NSXPCConnection?
    private var helperTool: HelperTool?
    
    func installAndConnectHeperTool() {
        if  !FileManager.default.fileExists(atPath: "/Library/PrivilegedHelperTools/\(XPCConstant.HelperMachLabel)"){
            
            self.alertInstall("Omniedge needs to install Helper Tool to complete installation.")
        }
        
        self.connectToXPC()
    }
    
    private func disconnect(){
        XPCConnection?.invalidationHandler = nil
        XPCConnection?.interruptionHandler = nil
        self.XPCConnection = nil
    }
    
    private func connectToXPC(){
        
        self.XPCConnection = NSXPCConnection(machServiceName: XPCConstant.HelperMachLabel,
                                             options: .privileged)
        
        XPCConnection?.remoteObjectInterface = NSXPCInterface(with: HelperTool.self)
        
        XPCConnection?.invalidationHandler = connectionInvalidationHandler
        XPCConnection?.interruptionHandler = connetionInterruptionHandler
        
        XPCConnection?.resume()
        
        self.helperTool = XPCConnection?.remoteObjectProxy as? HelperTool
        self.helperTool?.version(completion: checkHelperVersion)
    }
    
    private func checkHelperVersion(ver: String){
        NSLog("Current Helper verions:\(ver)")
        
        if ver != XPCConstant.HelperToolVersion{
            DispatchQueue.main.async {
                self.alertInstall("Omniedge needs to upgrade Helper Tool.")
                
            }
        }
    }
    
    
    private func connetionInterruptionHandler() {
        NSLog("interrupted Connection")
        
    }
    
    private func connectionInvalidationHandler() {
        NSLog("Invalid Connection")
    }
    
    private func alertInstall(_ message: String){
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = message
        let okButton = alert.addButton(withTitle: "OK")
        alert.window.defaultButtonCell = okButton.cell as? NSButtonCell
        alert.addButton(withTitle: "Cancel")
        let modal = alert.runModal()
        
        switch modal {
        case .OK, .alertFirstButtonReturn:
            self.installHelperTool()
        default:
            self.notAbleToStart(nil)
        }
    }
    
    
    private func notAbleToStart(_ message: String?){
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = message ?? "Omniedge not able to start."
        alert.addButton(withTitle: "Exit")
        alert.runModal()
        
        NSRunningApplication.current.terminate()
    }
    
    
    
    private func installHelperTool(){
        
        self.disconnect()
        guard let auth = Utils.askAuthorization() else {
            fatalError("Authorization not acquired.")
        }
        
        if(!Utils.blessHelper(label: XPCConstant.HelperMachLabel, authorization: auth)){
            self.notAbleToStart("Install HelperTool failed.")
        }
        
        self.connectToXPC()
        
    }
}
