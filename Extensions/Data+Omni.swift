//
//  Data+Omni.swift
//  Omniedge
//
//  Created by Yanbo Dang on 18/7/2022.
//

import Foundation

extension Data {
    
    func printJson() {
            do {
                let json = try JSONSerialization.jsonObject(with: self, options: [])
                let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    print("Inavlid data")
                    return
                }
                print(jsonString)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
}
