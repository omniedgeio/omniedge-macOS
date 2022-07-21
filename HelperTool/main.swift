//
//  main.swift
//  HelperTool
//
//  Created by An Li on 2021/1/17.
//

import Foundation
import n2nMacOS

let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

NSLog("Version:\(version ?? "None")")
XPCServer.shared.start()
RunLoop.current.run()

