//
//  DeviceModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 22/5/2022.
//

import Foundation

struct DeviceModel: Codable {
    let deviceName: String
    let deviceUuid: String
    let deviceOS: String
    
    enum CodingKeys: String, CodingKey {
        case deviceName = "name"
        case deviceUuid = "hardware_uuid"
        case deviceOS = "platform"
    }
}
