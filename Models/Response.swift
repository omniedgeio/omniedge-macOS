//
//  Response.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
struct Response<T: Decodable>: Decodable {
    let code: Int
    let data: T?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case data
        case message
    }
}
