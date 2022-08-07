//
//  Response.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation
struct Response<T: Decodable>: Decodable {
    let code: Int
    let data: T
    
    enum CodingKeys: String, CodingKey {
        case code
        case data
    }
}
