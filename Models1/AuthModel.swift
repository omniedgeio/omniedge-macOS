//
//  AuthModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation

struct AuthModel: Decodable {
    
    let sessionId: String
    let authUrl: String
    let expiredDate: Date
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "id"
        case authUrl = "auth_url"
        case expiredDate = "expired_at"
    }
}
