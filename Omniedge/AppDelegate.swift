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
    
    
    
    @IBOutlet weak var updater: SUUpdater!
    
    @IBOutlet weak var autoUpdate: NSMenuItem!
    
    
    var xpcStore: XPCStore?
    
    @IBOutlet weak var customeView: OGSwitch!
    
    var statusItem: NSStatusItem?
    
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func pressAutoUpdate(_ sender: NSMenuItem) {
        UserDefaults.standard.set(sender.state.toggle(), forKey: UserDefaultKeys.AutoUpdate)
        updateUI()
        
        dataLoader?.request(callback: { json, error in
            print(json)
            print(error)

        })
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
           
            
        }else{
            var url = try! oauth2.authorizeURL(params: nil)
            url = URL(string: url.description.removingPercentEncoding!)!
            try! oauth2.authorizer.authorizeEmbedded(with: oauth2.authConfig, at: url)
            oauth2.afterAuthorizeOrFail = { authParameters, error in
                self.updateUI()
                
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
    
    func updateUI(){
        let userDefaults = UserDefaults.standard
        
        
        if let _ = oauth2.accessToken{
            
            isN2NControlHide(false)
            loginItem.title = "Log Out"
            
        }else{
            
            isN2NControlHide(true)
            loginItem.title = "Log In"
            
        }
        
        
        if let autoUpdateFlag =  userDefaults.object(forKey: UserDefaultKeys.AutoUpdate) as? NSControl.StateValue{
            
            autoUpdate.state = autoUpdateFlag
            updater.automaticallyChecksForUpdates =  autoUpdate.state.toBool()
            
        }else{
            //defaults
            autoUpdate.state = .on
            updater.automaticallyChecksForUpdates = true
            userDefaults.set(autoUpdate.state, forKey: UserDefaultKeys.AutoUpdate)
        }
        
        
    }
    
    private func isN2NControlHide(_ isHidden: Bool){
        
        if(isHidden){
            firstMenuItem.view = nil
            firstMenuItem.isHidden = true
        }else{
            firstMenuItem.view = customeView
            firstMenuItem.isHidden = false
            
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
        
        
        firstMenuItem.view = customeView
        firstMenuItem.isHidden = true
        
        
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

