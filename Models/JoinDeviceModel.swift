//
//  JoinDeviceModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 4/6/2022.
//

import Foundation

struct JoinDeviceMode: Decodable {
    
    let communityName: String
    let secretKey: String
    let virtualIp: String
    let subnetMask: String
    
    enum CodingKeys: String, CodingKey {
        case communityName = "community_name"
        case secretKey = "secret_key"
        case virtualIp = "virtual_ip"
        case subnetMask = "subnet_mask"
    }
}
