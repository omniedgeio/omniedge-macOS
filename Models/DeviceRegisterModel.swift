//
//  DeviceRegisterModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 3/6/2022.
//

import Foundation

struct DeviceRegisterModel: Decodable {
    let deviceId: String
    let hardwareId: String
    let platform: String
    let deviceName: String
    let createdOn: Date
    let ddbUuid: String?
    let virtualIp: String
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "id"
        case hardwareId = "hardware_id"
        case platform
        case deviceName = "name"
        case createdOn = "created_at"
        case ddbUuid = "ddb_uuid"
        case virtualIp = "virtual_ip"
    }
}
