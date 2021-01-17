//
//  main.swift
//  HelperTool
//
//  Created by An Li on 2021/1/17.
//

import Foundation

NSLog("Hello,Log!")
print("Hello, World!")

XPCServer.shared.start()


RunLoop.current.run()
