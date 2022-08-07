//
//  LocatorService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation

protocol ILocatorService {
    func register<T>(instance: T)
    func register<T>(recipe: @escaping () -> T)
    func resolve<T>() -> T
}

final class LocatorService: ILocatorService {
    enum RegistryRec{
        case Instance(Any)
        case Recipe(() -> Any)
        
        func unwap() -> Any{
            switch self{
            case .Instance(let instance):
                return instance
            case .Recipe(let recipe):
                return recipe()
            }
        }
    }
    
    lazy private var repository: Dictionary<String, RegistryRec> = [:]
    
    private static var instance : LocatorService = {
        return LocatorService()
    }()
    
    private init(){
    }
    
    class func shareInstance() -> LocatorService {
        return instance
    }
    
    func register<T>(instance: T) {
        let key = typeNmae(some: T.self)
        self.repository[key] = .Instance(instance)
    }
    
    func register<T>(recipe: @escaping () -> T) {
        let key = typeNmae(some: T.self)
        self.repository[key] = .Recipe(recipe)
    }
    
    func resolve<T>() -> T {
        let key = self.typeNmae(some: T.self)
        var instance : T? = nil
        if let record = self.repository[key]{
            instance = record.unwap() as? T
            switch record {
            case .Recipe:
                if let instance = instance {
                    self.register(instance: instance)
                }
            default:
                break
            }
        }
        
        guard let instance = instance else {
            fatalError()
        }
        
        return instance
    }
    
    private func typeNmae(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
}
