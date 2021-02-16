//
//  XPCStore.swift
//  Omniedge
//
//  Created by An Li on 2021/1/23.
//

import Foundation
import Cocoa

class XPCStore{
    var XPCConnection: NSXPCConnection?
    var helperTool: HelperTool?
    
    var isConnected: Bool = false {
        didSet {
            NSLog("click")
        }
    }

    
    init(){
        
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
                self.alertInstall()
                
            }
        }
    }
    
    
    private func connetionInterruptionHandler() {
        NSLog("interrupted Connection")

    }
    
    private func connectionInvalidationHandler() {
        DispatchQueue.main.async {
            self.alertInstall()
            
        }
        
    }
    
    func alertInstall(){
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Omniedge needs to install Helper Tool to complete installation."
        let okButton = alert.addButton(withTitle: "OK")
        
        //        okButton.target = self
        //        okButton.action = #selector(installHelperTool(_:))
        alert.window.defaultButtonCell = okButton.cell as? NSButtonCell
        alert.addButton(withTitle: "Cancel")
        let modal = alert.runModal()
        
        switch modal{
        case .OK,
             .alertFirstButtonReturn:
            installHelperTool()
            
        default:
            notAbleToStart(nil)
        }
    }
    
    
    func notAbleToStart(_ message: String?){
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = message ?? "Omniedge not able to start."
        alert.addButton(withTitle: "Exit")
        alert.runModal()
        
        NSRunningApplication.current.terminate()
    }
    
    
    
    func installHelperTool(){
        
        disconnect()
        guard let auth = Util.askAuthorization() else {
            fatalError("Authorization not acquired.")
        }
        
        if(!Util.blessHelper(label: XPCConstant.HelperMachLabel, authorization: auth)){
            notAbleToStart("Install HelperTool failed.")
        }
        connectToXPC()
        
    }
    
}
