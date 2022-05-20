//
//  UserModel.swift
//  Omniedge
//
//  Created by Yanbo Dang on 20/5/2022.
//

import Foundation

struct UserModel: Decodable {
    let userId: String
    let userName: String
    let email: String
    let userPicture: String?
    let lastLoginIPAddr: String?
    let lastLoginOn: Date
    let status: Int
    let createdOn: Date
    let changedOn: Date
    let cognitoId: String?
    let ddbUuid: String?
    let role: Int
    let joinedOn: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case userName = "name"
        case email
        case userPicture = "picture"
        case lastLoginIPAddr = "last_login_ip"
        case lastLoginOn = "last_login_at"
        case status
        case createdOn = "created_at"
        case changedOn = "updated_at"
        case cognitoId = "cognito_id"
        case ddbUuid = "ddb_uuid"
        case role
        case joinedOn = "joined_at"
    }
    
}
