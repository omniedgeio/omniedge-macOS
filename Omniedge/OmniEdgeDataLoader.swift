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
    
    func request( callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
        oauth2.logger = OAuth2DebugLogger(.trace)
        var req = self.oauth2.request(forURL: graphql)
        req.setValue(oauth2.idToken, forHTTPHeaderField: "Authorization")
        req.httpMethod = "POST"
        req.httpBody = BackEndConstants.DeviceQuery.data(using: .utf8)
        
        perform(request: req) { response in
            do {
                let dict = try response.responseJSON()
                DispatchQueue.main.async() {
                    callback(dict, nil)
                }
            }
            catch let error {
                DispatchQueue.main.async() {
                    callback(nil, error)
                }
            }
        }
    }
    
}
