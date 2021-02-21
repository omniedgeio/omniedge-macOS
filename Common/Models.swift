//
//  Models.swift
//  Omniedge
//
//  Created by An Li on 2021/2/21.
//

import Foundation


struct NetworkConfig: Decodable{
    let instanceID: String
    let virtualNetworkID: String
    let communityName: String
    let secretKey: String
    let addr: String
    let publicKey: String
    let virtualIP: String
}
