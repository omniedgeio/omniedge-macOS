//
//  AppDelegate.swift
//  Omniedge
//
//  Created by An Li on 2021/1/10.
//

import Cocoa
import OGSwitch
import SwiftUI
import Sparkle
import ServiceManagement
import OAuth2

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    @IBOutlet weak var firstMenuItem: NSMenuItem!
    
    
    @IBOutlet weak var loginItem: NSMenuItem!
    
    @IBOutlet weak var deviceList: NSMenuItem!
    
    
    @IBOutlet weak var updater: SUUpdater!
    
    @IBOutlet weak var autoUpdate: NSMenuItem!
    
    
    var xpcStore: XPCStore?
    
    @IBOutlet weak var customeView: OGSwitch!
    
    var statusItem: NSStatusItem?
    
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func pressAutoUpdate(_ sender: NSMenuItem) {
        UserDefaults.standard.set(sender.state.toggle(), forKey: UserDefaultKeys.AutoUpdate)
        updateUI()
    }
    
    var oauth2 = createOAuth2()
    
    private static func createOAuth2() -> OAuth2CodeGrant{
        return OAuth2CodeGrant(settings: [
            "client_id": BackEndConstants.ClientID,
            "client_secret": BackEndConstants.ClientSecret,
            "authorize_uri":BackEndConstants.LoginURL ,
            "token_uri": BackEndConstants.TokenURL,
            "redirect_uris": [BackEndConstants.CallBackURL],
            "scope": BackEndConstants.Scope,
            "keychain": true,
        ] as OAuth2JSON)
    }

    var dataLoader: OmniEdgeDataLoader?
    
    @IBAction func logInOutItem(_ sender: NSMenuItem) {
        
        if let _ = oauth2.idToken{
            
            oauth2.forgetTokens()
            UserDefaults.standard.setValue(nil, forKey: UserDefaultKeys.NetworkStatus)

           
            
        }else{
            var url = try! oauth2.authorizeURL(params: nil)
            url = URL(string: url.description.removingPercentEncoding!)!
            try! oauth2.authorizer.authorizeEmbedded(with: oauth2.authConfig, at: url)
            oauth2.afterAuthorizeOrFail = { authParameters, error in
                
                self.dataLoader?.queryNetwork(callback: { network, error in
                    UserDefaults.standard.setValue(network, forKey: UserDefaultKeys.NetworkStatus)
                    
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                })
                
               
                
            }
        }
        
        updateUI()
    }
    
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
    }
    
    
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    @objc private func handleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            if let url = URL(string: urlString), "omniedge" == url.scheme && "signin" == url.host {
                self.oauth2.handleRedirectURL(url)
            }
        }
        else {
            NSLog("No valid URL to handle")
        }
        
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
                
        dataLoader = OmniEdgeDataLoader(oauth2: self.oauth2)
        self.xpcStore = XPCStore()
        updateUI()
        
    }
    
    let decoder = JSONDecoder()
    
    func updateUI(){

        isLoggedIn(oauth2.accessToken != nil)
        
        let userDefaults = UserDefaults.standard

        if let autoUpdateFlag =  userDefaults.object(forKey: UserDefaultKeys.AutoUpdate) as? NSControl.StateValue{
            
            autoUpdate.state = autoUpdateFlag
            updater.automaticallyChecksForUpdates =  autoUpdate.state.toBool()
            
        }else{
            autoUpdate.state = .on
            updater.automaticallyChecksForUpdates = true
            userDefaults.set(autoUpdate.state, forKey: UserDefaultKeys.AutoUpdate)
        }
        
        if let networkStatus = userDefaults.object(forKey: UserDefaultKeys.NetworkStatus) as? Data{
            
            let network: NetworkResponse = try! decoder.decode(NetworkResponse.self, from: networkStatus)
            let submenu = NSMenu()

            if let devices = network.vNetwork?.devices{
                for (index, device) in devices.enumerated() {
                    
                    let deviceInfoView = DeviceInfoView()
    //                deviceInfoView.loadViewFromNib()

                    deviceInfoView.deviceName.wantsLayer = true
                    deviceInfoView.deviceName.stringValue =  device.name ?? ""
                    deviceInfoView.ip.stringValue = device.virtualIP ?? ""
                    deviceInfoView.ping.stringValue = "- ms"
                    let menuItem = NSMenuItem()
                    menuItem.view = deviceInfoView
                    submenu.addItem(menuItem)
                    
                    if index != devices.count - 1{
                        submenu.addItem(NSMenuItem.separator())
                    }
                    
                }
            }
            
            
            self.deviceList.submenu = submenu
            
            
            
        }
        
        
    }
    
    private func isLoggedIn(_ isLoggedIn: Bool){
        
        if(isLoggedIn){
            firstMenuItem.view = customeView
            firstMenuItem.isHidden = false
            
            loginItem.title = "Log Out"

        }else{
            firstMenuItem.view = nil
            firstMenuItem.isHidden = true
            
            loginItem.title = "Log In"

            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "📡"
        
        if let menu = menu {
            statusItem?.menu = menu
            menu.delegate = self
        }
        
        
        
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    @IBAction func switchPressed(_ sender: Any) {
        if let button = sender as? OGSwitch{
            switchLabel.stringValue = button.isOn ? "On":"Off"
            
            if(button.isOn){
                self.xpcStore?.helperTool?.install()
            }else{
                self.xpcStore?.helperTool?.uninstall()
            }
            
        }

    }
    

}

