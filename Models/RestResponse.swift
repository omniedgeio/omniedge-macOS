//
//  RestResponse.swift
//  Omniedge
//
//  Created by Yanbo Dang on 12/5/2022.
//

import Foundation

struct RestResponse<T: Decodable>: Decodable {
    let code: Int
    let data: T
    
    enum CodingKeys: String, CodingKey {
        case code
        case data
    }
}
