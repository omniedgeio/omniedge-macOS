//
//  AuthSession.swift
//  Omniedge
//
//  Created by Yanbo Dang on 12/5/2022.
//

import Foundation

struct AuthSession: Decodable {
    
    let sessionId: String
    let authUrl: String
    let expiredDate: Date
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "id"
        case authUrl = "auth_url"
        case expiredDate = "expired_at"
    }
}
