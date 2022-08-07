//
//  BaseService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation

class BaseService {
    
    init() {
        self.initService()
    }
    
    func initService() {
        
    }
    
    func handleError(error: Error){
        print(error)
    }
}
