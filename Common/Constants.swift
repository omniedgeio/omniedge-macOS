//
//  Constants.swift
//  Omniedge
//
//  Created by An Li on 2021/1/17.
//

import Foundation
import AppKit

struct XPCConstant {
    static let HelperMachLabel = "io.omniedge.mac.Omniedge.HelperTool"
    static let HelperToolVersion = "1.2"

}

let AppBuildIdentifier="io.omniedge.mac.Omniedge"

struct CryptoConstants{
    static let PrivateStoreKey = "io.omniedge.mac.Omniedge.private"
    static let PublicStoreKey = "io.omniedge.mac.Omniedge.public"

}

struct UserDefaultKeys{
    
    static let AutoLaunch = "io.omniedge.mac.autolaunch"
    static let AutoUpdate = "io.omniedge.mac.autoupdate"
    static let IDToken = "io.omniedge.mac.id.token"
    static let NetworkStatus = "io.omniedge.mac.network.status"
    static let DeviceUUID = "io.omniedge.mac.device.UUID"
    static let NetworkConfig = "io.omniedge.mac.network.config"
    static let PublicKey = "io.omniedge.mac.publickey"
    static let Ping = "io.omniedge.mac.ping"
}


struct BackEndConstants{
    
    static let ClientID = "274vpj278u5j7njhb9up99ibi8"
    static let ClientSecret = "t98n31jmusc3ucci7rql4ojodg7daehjv1nln586p60eu2k4pql"

    static let TokenURL = "https://auth-dev.edgecomputing.network/oauth2/token"
    static let LoginURL = "https://auth-dev.edgecomputing.network/login"
    static let CallBackURL = "http://localhost:8080/"
    static let Scope = "email+openid+phone+profile"
    
    static let GraphqlEndpoint = "https://nhgt5ptb5fhjzgu6qmwf76hhka.appsync-api.us-east-2.amazonaws.com/graphql"
    
    // static let RestJoin = "https://3b0loh21sb.execute-api.us-east-2.amazonaws.com/dev"
    static let baseApiEndPoint = "https://dev-api.omniedge.io/api/v1/"
    static let RestJoin = "https://3b0loh21sb.execute-api.us-east-2.amazonaws.com/dev"

    static let DeviceQuery = """
    {"query":"query {  listVirtualNetworks {    items {      id      ipPrefix      communityName      devices {        items {          id          name          virtualIP           description        }      }    }  }}","variables":{}}
    """
}

struct ApiEndPoint {
    
    // dev
    static let baseApi = "https://dev-api.omniedge.io/api/v1/"
    static let wsEndPoint = "wss://dev-wss.omniedge.io"
    
//    // prod
//    static let baseApi = "https://api.omniedge.io/api/v1"
//    static let wsEndPoint = "wss://wss.omniedge.io"
    
    static let authSession = "auth/login/session"
    static let virtualNetworkList = "virtual-networks/"
    static let registerDevice = "devices/register"
}

let OAuth2AppDidReceiveCallbackNotification = NSNotification.Name(rawValue: "OAuth2AppDidReceiveCallback")

struct OmniError: Error {
    let errorCode: Int
    let message: String?
}


struct Constants {
    static let EmptyText: String = ""
    
    struct Colors {
        static let textColorInDarkMode = NSColor(red: 0xDA/0xFF, green: 0xDA/0xFF, blue: 0xDA/0xFF, alpha: 1.0)
        static let textColorInLightMode = NSColor(red: 0x6C/0xFF, green: 0x6C/0xFF, blue: 0x6C/0xFF, alpha: 1.0)
         
        static let C_F1F1F1 = NSColor(red: 0xF1/0xFF, green: 0xF1/0xFF, blue: 0xF1/0xFF, alpha: 1.0)
        static let C_6C6C6C = NSColor(red: 0x6C/0xFF, green: 0x6C/0xFF, blue: 0x6C/0xFF, alpha: 1.0)
        static let C_3D3D3D = NSColor(red: 0x3D/0xFF, green: 0x3D/0xFF, blue: 0x3D/0xFF, alpha: 1.0)
    }
    
    struct Margins {
        static let margin5: CGFloat = 5.0
        static let margin10: CGFloat = 10.0
        static let margin15: CGFloat = 15.0
    }
    
    struct Size {
        static let menuItemWidth233: CGFloat = 233
    }
}
