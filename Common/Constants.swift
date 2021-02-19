//
//  Constants.swift
//  Omniedge
//
//  Created by An Li on 2021/1/17.
//

import Foundation

struct XPCConstant {
    static let HelperMachLabel = "io.omniedge.mac.Omniedge.HelperTool"
    static let HelperToolVersion = "1.0"

}


struct UserDefaultKeys{


    static let AutoLaunch = "io.omniedge.mac.autolaunch"
    static let AutoUpdate = "io.omniedge.mac.autoupdate"
    static let IDToken = "io.omniedge.mac.id.token"
    static let NetworkStatus = "io.omniedge.mac.network.status"
}


struct BackEndConstants{
    
    static let ClientID = "274vpj278u5j7njhb9up99ibi8"
    static let ClientSecret = "t98n31jmusc3ucci7rql4ojodg7daehjv1nln586p60eu2k4pql"

    static let TokenURL = "https://omniedge-dev.auth.us-east-2.amazoncognito.com/oauth2/token"
    static let LoginURL = "https://omniedge-dev.auth.us-east-2.amazoncognito.com/login"
    static let CallBackURL = "omniedge://signin/"
    static let Scope = "email+openid+phone+profile"
    
    static let GraphqlEndpoint = "https://nhgt5ptb5fhjzgu6qmwf76hhka.appsync-api.us-east-2.amazonaws.com/graphql"
    static let DeviceQuery = """
    {"query":"query {  listVirtualNetworks {    items {      id      ipPrefix      communityName      devices {        items {          id          name          virtualIP           description        }      }    }  }}","variables":{}}
    """
}

let OAuth2AppDidReceiveCallbackNotification = NSNotification.Name(rawValue: "OAuth2AppDidReceiveCallback")
