//
//  HelperTool.swift
//  HelperTool
//
//  Created by An Li on 2021/1/17.
//

import Foundation
import n2nMacOS

var keepRunning: Int32 = 1
var isConnected = false

class HelperToolImpl: HelperTool{
   
    func isConnect(completion: @escaping (Bool) -> Void) {
        completion(keepRunning == 1 && isConnected)
    }
    
    func version(completion: @escaping (String) -> Void) {
        
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        completion(buildNumber)
    }
    
    
    private var searchingWorkItem: DispatchWorkItem?
    
    
    let decoder = JSONDecoder()
    
    func connect(_ networkConfig: Data, completion: @escaping (Error?)->Void){
        NSLog("[SMJBS]: \(#function)")
        
        
        let config = try! decoder.decode(JoinDeviceMode.self, from: networkConfig)
        
        let deviceName = ProcessInfo.processInfo.hostName
        let communityName = config.communityName
        let encryptKey = config.secretKey
        var deviceMac = "DE:AD:BE:EF:F1:10"
        let localIP = config.virtualIp
        let superNode = config.server.host
        
        if let intfIterator = Utils.findEthernetInterfaces() {
            if let macAddress = Utils.getMACAddress(intfIterator) {
                let macAddressAsString = macAddress.map( { String(format:"%02x", $0) } )
                    .joined(separator: ":")
                deviceMac = macAddressAsString
            }

            IOObjectRelease(intfIterator)
        }
        
        NSLog("[SMJBS]: \(#function)")

        if(!isConnected){
            searchingWorkItem = DispatchWorkItem {
                NSLog("[SMJBS]: edge start")
                isConnected = true
                keepRunning = 1
                quick_edge_init(deviceName, communityName, encryptKey, deviceMac, localIP, superNode, &keepRunning)
                NSLog("[SMJBS]: edge end")
                
            }
            DispatchQueue.global().async(execute: self.searchingWorkItem!)
        }
        
        completion(nil)
        
        NSLog("[SMJBS]: \(#function)")
    }
    func disconnect(){
        NSLog("[SMJBS]: \(#function)")
        keepRunning = 0
        searchingWorkItem?.cancel()
        isConnected = false
        
    }
}
