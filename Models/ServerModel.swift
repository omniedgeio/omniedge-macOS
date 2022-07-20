//
//  ServerModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 20/5/2022.
//

import Foundation

struct ServerModel: Decodable {
    let serverId: String
    let serverName: String
    let hostAddr: String
    let countryCode: String
    let type: Int
    
    enum CodingKeys: String, CodingKey {
        case serverId = "id"
        case serverName = "name"
        case hostAddr = "host"
        case countryCode = "country"
        case type
    }
}
