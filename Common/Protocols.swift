//
//  Protocols.swift
//  Omniedge
//
//  Created by An Li on 2021/1/17.
//


import Foundation

@objc(HelperTool)
protocol HelperTool {
    
    func version(completion: @escaping(String) -> Void) // change to check version instead of check alive after first release.
    func isConnect(completion: @escaping(Bool) -> Void)
    func install()
    func uninstall()
}

