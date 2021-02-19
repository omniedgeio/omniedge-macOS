//
//  OmniEdgeDataLoader.swift
//  Omniedge
//
//  Created by An Li on 2021/2/16.
//

import Foundation
import OAuth2


class OmniEdgeDataLoader: OAuth2DataLoader{
    
    let graphql = URL(string: BackEndConstants.GraphqlEndpoint)!
    
    func queryNetwork( callback: @escaping ((Data?, Error?) -> Void)) {
        oauth2.logger = OAuth2DebugLogger(.trace)
        var req = self.oauth2.request(forURL: graphql)
        req.setValue(oauth2.idToken, forHTTPHeaderField: "Authorization")
        req.httpMethod = "POST"
        req.httpBody = BackEndConstants.DeviceQuery.data(using: .utf8)
        
        perform(request: req) { response in
            do {
                let dict = try response.responseData()
                
                callback(dict, nil)
                
            }
            catch let error {
               
                callback(nil, error)
                
            }
        }
    }
    
}


enum CodingKeys: CodingKey{
    case data, listVirtualNetworks, items, id, communityName, devices
}

struct NetworkResponse: Decodable{
    
    var vNetwork: VitrualNetwork?
    

    
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        let listVirtualNetworks = try data.nestedContainer(keyedBy: CodingKeys.self, forKey: .listVirtualNetworks)
        var items = try listVirtualNetworks.nestedUnkeyedContainer(forKey: .items)

        vNetwork = try items.decode(VitrualNetwork.self)
    }
    
}

struct VitrualNetwork{
    var id: String?
    var communityName: String?;
    var devices = [Device]()
    
   
}


extension VitrualNetwork: Decodable{
    

    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self,forKey: .id)
        communityName = try container.decodeIfPresent(String.self,forKey: .communityName)
        let devicesJson = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .devices)
        var deviceItems = try devicesJson.nestedUnkeyedContainer(forKey: .items)
        while !deviceItems.isAtEnd{
            devices.append(try deviceItems.decode(Device.self))
        }

        
      }
}

struct Device: Decodable{
    var name: String?
    var id: String?
    var virtualIP: String?
    var description:String?
}
