//
//  CacheService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 23/7/2022.
//

import Foundation

protocol ICacheService {
    func saveValue(value: Any?, key: String)
    func getValue(forKey: String) -> Any?
    func clearValueForKey(key: String)
}

class CacheService: BaseService, ICacheService {
    
    private var userDefault: UserDefaults = UserDefaults.standard
    
    func saveValue(value: Any?, key: String) {
        self.userDefault.setValue(value, forKey: key)
        self.userDefault.synchronize()
    }
    
    func getValue(forKey: String) -> Any? {
        return self.userDefault.value(forKey: forKey)
    }
    
    func clearValueForKey(key: String) {
        self.userDefault.removeObject(forKey: key)
        self.userDefault.synchronize()
    }
}
