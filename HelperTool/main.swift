//
//  main.swift
//  HelperTool
//
//  Created by An Li on 2021/1/17.
//

import Foundation
import n2n

NSLog("Hello,Log!")
print("Hello, World!")


let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

NSLog("Version:\(version ?? "None")")
XPCServer.shared.start()


RunLoop.current.run()




//RunLoop.current.run()

