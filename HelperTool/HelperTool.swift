//
//  HelperTool.swift
//  HelperTool
//
//  Created by An Li on 2021/1/17.
//

import Foundation
import n2nMacOS

var keepRunning: Int32 = 1

class HelperToolImpl: HelperTool{
    
    var isConnected = false
    
    func isConnect(completion: @escaping (Bool) -> Void) {
        completion(isConnected)
    }
    
    func version(completion: @escaping (String) -> Void) {
        
        completion(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
    }
    
    
    private var searchingWorkItem: DispatchWorkItem?
    
    
    func install(){
        NSLog("[SMJBS]: \(#function)")
        
        let deviceName = "n2n01111"
        let communityName = "omniedge"
        let encryptKey = "66YRd88kyYdhzk"
        let deviceMac = "DE:AD:BE:EF:F1:10"
        let localIP = "10.254.1.23"
        let superNode = "52.80.139.238:7787"
        
        NSLog("[SMJBS]: \(#function)")

        if(!isConnected){
            searchingWorkItem = DispatchWorkItem {
                NSLog("[SMJBS]: edge start")
                self.isConnected = true
                keepRunning = 1
                quick_edge_init(deviceName, communityName, encryptKey, deviceMac, localIP, superNode, &keepRunning)
                NSLog("[SMJBS]: edge end")
                
            }
            DispatchQueue.global().async(execute: self.searchingWorkItem!)
        }
        
       
        
        NSLog("[SMJBS]: \(#function)")
    }
    func uninstall(){
        NSLog("[SMJBS]: \(#function)")
        keepRunning = 0
        searchingWorkItem?.cancel()
        self.isConnected = false
        
    }
}
