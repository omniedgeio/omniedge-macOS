//
//  VirtualNetworkModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 20/5/2022.
//

import Foundation

struct VirtualNetworkModel: Decodable {
    let vnId:String
    let vnName: String
    let ipRange: String
    let ddbUuid:String?
    let server: ServerModel
    let devices: [String]
    let users: [UserModel]
    let role: Int
    let usersCount: Int
    let devicesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case vnId = "id"
        case vnName = "name"
        case ipRange = "ip_range"
        case ddbUuid = "ddb_uuid"
        case server
        case devices
        case users
        case role
        case usersCount = "users_count"
        case devicesCount = "devices_count"
    }
}
