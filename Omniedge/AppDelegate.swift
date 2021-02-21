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
    
    @IBOutlet weak var switcherAlign: NSLayoutConstraint!
    
    @IBOutlet weak var loginItem: NSMenuItem!
    
    @IBOutlet weak var deviceList: NSMenuItem!
    
    
    @IBOutlet weak var updater: SUUpdater!
    
    @IBOutlet weak var autoUpdate: NSMenuItem!
    
    
    var xpcStore: XPCStore?
    
    @IBOutlet weak var customeView: NSView!
    
    var statusItem: NSStatusItem?
    
    @IBOutlet weak var networkSwitcher: OGSwitch!
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func pressAutoUpdate(_ sender: NSMenuItem) {
        UserDefaults.standard.set(sender.state.toggle(), forKey: UserDefaultKeys.AutoUpdate)
        self.updateUI()
        
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
            let storage = HTTPCookieStorage.shared
            storage.cookies?.forEach() { storage.deleteCookie($0) }
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.NetworkStatus)
            UserDefaults.standard.removeObject(forKey: UserDefaultKeys.NetworkConfig)
            
        }else{
            
            var url = try! oauth2.authorizeURL(params: nil)
            url = URL(string: url.description.removingPercentEncoding!)!
            try! oauth2.authorizer.authorizeEmbedded(with: oauth2.authConfig, at: url)
            oauth2.afterAuthorizeOrFail = { authParameters, error in
                self.pullDevliceList(fromTimer: false,callback: self.join)
                
            }
        }
        
        self.updateUI()
        
        
    }
    
    var timer : Timer?
    
    func join(){
        if let networkStatus = UserDefaults.standard.data(forKey: UserDefaultKeys.NetworkStatus),
           UserDefaults.standard.value(forKey: UserDefaultKeys.NetworkConfig) == nil {
            
            let network: NetworkResponse = try! decoder.decode(NetworkResponse.self, from: networkStatus)
            guard let instanceID = UserDefaults.standard.string(forKey: UserDefaultKeys.DeviceUUID) else { return }
            
            guard let virtualNetworkID = network.vNetwork?.communityName else { return }
            
            let name = ProcessInfo.processInfo.hostName
            
            let description = ProcessInfo.processInfo.operatingSystemVersionString
            guard let networkID = network.vNetwork?.id else{ return }
            
            let storePubTag = CryptoConstants.PublicStoreKey.data(using: .utf8)!
            let getPubQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                              kSecAttrApplicationTag as String: storePubTag,
                                              kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                              kSecReturnRef as String: false]
            
            var item: CFTypeRef?
            var error: Unmanaged<CFError>?
            
            SecItemCopyMatching(getPubQuery as CFDictionary, &item)
            let publicKey = SecKeyCopyExternalRepresentation(item as! SecKey, &error)! as Data
            
            
            let joinNetwork = JoinNetworkRequest(instanceID: instanceID, virtualNetworkID: virtualNetworkID, name: name, userAgent: "macOS", description: description, publicKey: publicKey.base64EncodedString())
            self.dataLoader?.join(joinNetwork: joinNetwork, networkId: networkID){ result in
                
                switch result {
                case .success(let data):
                    UserDefaults.standard.setValue(data, forKey: UserDefaultKeys.NetworkConfig)
                case .failure(let error):
                    NSLog("Join network failed: \(error.localizedDescription)")
                    alert(title: "Join network failed", description: error.localizedDescription, .critical)
                }
                
                
                
            }
            
            
        }
    }
    
    func pullDevliceList(fromTimer:Bool, callback: @escaping (()->Void)){
        self.dataLoader?.queryNetwork(callback: { result in
            
            switch result{
            case .success(let network):
                UserDefaults.standard.setValue(network, forKey: UserDefaultKeys.NetworkStatus)
            case .failure(let error):
                NSLog("Get Device List Error: \(error.localizedDescription)")
                if !fromTimer {
                    alert(title:"Get Device List Error", description: error.localizedDescription, .critical)
                }
                
            }
            callback()
            DispatchQueue.main.async {
                self.updateUI()
            }
        })
    }
    
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
        self.updateUI()
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
        
        NSLog("\(ProcessInfo.processInfo.hostName)")
        
        initDeviceInformation()
        oauth2.logger = OAuth2DebugLogger(.trace)
        
        dataLoader = OmniEdgeDataLoader(oauth2: self.oauth2)
        
        self.timer  = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { timer in
            print("pulling")
            self.pullDevliceList(fromTimer: true){}
        })
        
        self.xpcStore = XPCStore()
        self.updateUI()
        
        
    }
    
    func initDeviceInformation(){
        if UserDefaults.standard.string(forKey: UserDefaultKeys.DeviceUUID) == nil {
            UserDefaults.standard.setValue(UUID().uuidString, forKey: UserDefaultKeys.DeviceUUID)
        }
        
        let storePubTag = CryptoConstants.PublicStoreKey.data(using: .utf8)!
        let getPubQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                          kSecAttrApplicationTag as String: storePubTag,
                                          kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                          kSecReturnRef as String: false]
        
        var item: CFTypeRef?
        var error: Unmanaged<CFError>?
        
        var status = SecItemCopyMatching(getPubQuery as CFDictionary, &item)
        
        if status != errSecSuccess {
            
            let tag = AppBuildIdentifier.data(using: .utf8)!
            let attributes: [String: Any] =
                [kSecAttrKeyType as String:             kSecAttrKeyTypeRSA,
                 kSecAttrKeySizeInBits as String:      2048,
                 kSecPrivateKeyAttrs as String:
                    [kSecAttrIsPermanent as String:    true,
                     kSecAttrApplicationTag as String: tag]
                ]
            
            guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                alert(title: "Start Failed", description: "Cannot create private key: \((error!.takeRetainedValue() as Error).localizedDescription)", .critical)
                return
            }
            
            
            let storePriTag = CryptoConstants.PrivateStoreKey.data(using: .utf8)!
            let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: storePriTag,
                                           kSecValueRef as String: privateKey]
            
            status = SecItemAdd(addquery as CFDictionary, nil)
            
            guard status == errSecSuccess || status == errSecDuplicateItem else {
                alert(title: "Start Failed", description: "Cannot store private key in keystore: \(SecCopyErrorMessageString(status,nil) ?? "" as CFString )", .critical)
                return
                
            }
            
            guard let publicKey = SecKeyCopyPublicKey(privateKey) else{
                alert(title: "Start Failed", description: "Create Public Key failed.", .critical)
                return
            }
            
            
            let addPubquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                              kSecAttrApplicationTag as String: storePubTag,
                                              kSecValueRef as String: publicKey]
            
            status = SecItemAdd(addPubquery as CFDictionary, nil)
            guard status == errSecSuccess || status == errSecDuplicateItem  else {
                alert(title: "Start Failed", description: "Cannot store public key in keystore.", .critical)
                return
                
            }
        }
        
        
        
        
    }
    
    let decoder = JSONDecoder()
    
    func updateUI(){
        
        isLoggedIn(oauth2.accessToken != nil)
        
        self.xpcStore?.helperTool?.isConnect{
            if $0 {
                DispatchQueue.main.async {
                    self.networkSwitcher.setOn(isOn: true, animated: false)
                }
            }
        }
        
        let userDefaults = UserDefaults.standard
        
        if let autoUpdateFlag =  userDefaults.object(forKey: UserDefaultKeys.AutoUpdate) as? NSControl.StateValue{
            
            autoUpdate.state = autoUpdateFlag
            updater.automaticallyChecksForUpdates =  autoUpdate.state.toBool()
            
        }else{
            autoUpdate.state = .on
            updater.automaticallyChecksForUpdates = true
            userDefaults.set(autoUpdate.state, forKey: UserDefaultKeys.AutoUpdate)
        }
        
    }
    
    private func isLoggedIn(_ isLoggedIn: Bool){
        
        if(isLoggedIn){
            firstMenuItem.view = customeView
            firstMenuItem.isHidden = false
            
            loginItem.title = "Log Out"
            
            let submenu = NSMenu()
            var ip: String?
            if let networkConfig = UserDefaults.standard.data(forKey: UserDefaultKeys.NetworkConfig){
                
                let localHost: NetworkConfig  = try! decoder.decode(NetworkConfig.self, from: networkConfig)
                let deviceInfoView = DeviceInfoView()
                deviceInfoView.deviceName.wantsLayer = true
                deviceInfoView.deviceName.stringValue =  ProcessInfo.processInfo.hostName
                deviceInfoView.ip.stringValue = localHost.virtualIP
                
                ip = localHost.virtualIP
                deviceInfoView.updateUI()
                let menuItem = NSMenuItem()
                menuItem.view = deviceInfoView
                submenu.addItem(menuItem)
                submenu.addItem(NSMenuItem.separator())
            }
            
            
            if let networkStatus = UserDefaults.standard.data(forKey: UserDefaultKeys.NetworkStatus){
                
                let hostId = UserDefaults.standard.string(forKey: UserDefaultKeys.DeviceUUID)!
                
                
                let network: NetworkResponse = try! decoder.decode(NetworkResponse.self, from: networkStatus)
                
                if let devices = network.vNetwork?.devices{
                    for  device in devices {
                        
                        if let ip = ip, device.virtualIP == ip{
                            continue
                        }
                        
                        let deviceInfoView = DeviceInfoView()
                        deviceInfoView.deviceName.wantsLayer = true
                        deviceInfoView.deviceName.stringValue =  device.name ?? ""
                        deviceInfoView.ip.stringValue = device.virtualIP ?? ""
                        deviceInfoView.updateUI()
                        let menuItem = NSMenuItem()
                        menuItem.view = deviceInfoView
                        submenu.addItem(menuItem)
                        
                        submenu.addItem(NSMenuItem.separator())
                        
                        
                    }
                }
                
                
                self.deviceList.submenu = submenu
                self.deviceList.isHidden = false
                
                
            }
            
            //dirty fix align
            
            if self.autoUpdate.state.toBool() {
                self.switcherAlign.constant = 24
                
            }else{
                self.switcherAlign.constant = 14
            }
            
        }else{
            firstMenuItem.view = nil
            firstMenuItem.isHidden = true
            
            self.deviceList.isHidden = true
            
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
    
    @IBAction func switchPressed(_ sender: OGSwitch) {
        
        switchLabel.stringValue = sender.isOn ? "On":"Off"

        
        if(sender.isOn){
            if let networkConfig = UserDefaults.standard.data(forKey: UserDefaultKeys.NetworkConfig){
                
                
                self.xpcStore?.helperTool?.connect(networkConfig){ err in
                    
                    if err != nil{
                        
                    }
                    
                }
            }
        }else{
            self.xpcStore?.helperTool?.disconnect()
        }
        
        
        
    }
    
    func menuWillOpen(_ menu: NSMenu){
        DispatchQueue.main.async {
            self.updateUI()
        }
        
    }
    
    
}

