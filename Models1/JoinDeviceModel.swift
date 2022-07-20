//
//  JoinDeviceModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 4/6/2022.
//

import Foundation

struct JoinDeviceMode: Codable {
    
    let communityName: String
    let secretKey: String
    let virtualIp: String
    let subnetMask: String
    let server: ServerThumbModel
    
    enum CodingKeys: String, CodingKey {
        case communityName = "community_name"
        case secretKey = "secret_key"
        case virtualIp = "virtual_ip"
        case subnetMask = "subnet_mask"
        case server
    }
}

struct ServerThumbModel: Codable {
    let name: String
    let host: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case host
        case country
    }
}
