//
//  OmError.swift
//  Omniedge
//
//  Created by Yanbo Dang on 12/8/2022.
//

import Foundation

enum OmError: Error {
    case invalidRsp
    case invalidUrl
    case errCode(Int, String)
    case other(Error)
}
