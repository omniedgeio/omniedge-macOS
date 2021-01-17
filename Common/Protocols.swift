//
//  Protocols.swift
//  Omniedge
//
//  Created by An Li on 2021/1/17.
//


import Foundation

@objc protocol HelperTool {
    func install()
    func uninstall()
}

@objc public protocol InstallationClient {
    func installationDidReachProgress(_ progress: Double, description: String?)
}
