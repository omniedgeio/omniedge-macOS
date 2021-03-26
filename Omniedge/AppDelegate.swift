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
import GCDWebServers
import Bugsnag

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
    
    let webServer = GCDWebServer()
    
    @IBOutlet weak var customeView: NSView!
    
    var statusItem: NSStatusItem?
    
    @IBOutlet weak var networkSwitcher: OGSwitch!
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func pressAutoUpdate(_ sender: NSMenuItem) {

        UserDefaults.standard.set(sender.state.toggle(), forKey: UserDefaultKeys.AutoUpdate)
        self.updateUI()
        
    }
    
    var semaphore: DispatchSemaphore?
    
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

            xpcStore?.helperTool?.disconnect()
            
        }else{
            
            var url = try! oauth2.authorizeURL(params: nil)
            url = URL(string: url.description.removingPercentEncoding!)!
            //            try! oauth2.authorizer.authorizeEmbedded(with: oauth2.authConfig, at: url)
            try! oauth2.authorizer.openAuthorizeURLInBrowser(url)
            
            
            oauth2.afterAuthorizeOrFail = { authParameters, error in
                

                if let error = error {
                    alert(title: "Login failed.", description: error.localizedDescription, .critical)
                }
                
                self.semaphore?.signal()
                self.pullDevliceList(callback: self.join)
                
                
            }
        }
        
        self.updateUI()
        
        
    }
    

    
    func join(){
        if let networkStatus = UserDefaults.standard.data(forKey: UserDefaultKeys.NetworkStatus),
           UserDefaults.standard.value(forKey: UserDefaultKeys.NetworkConfig) == nil {
            
            if let network: NetworkResponse = try? decoder.decode(NetworkResponse.self, from: networkStatus){
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
    }
    
    func pullDevliceList(callback: (()->Void)? = nil){
        if let _ = oauth2.accessToken {
            self.dataLoader?.queryNetwork(callback: { result in
                
                switch result{
                case .success(let network):
                    UserDefaults.standard.setValue(network, forKey: UserDefaultKeys.NetworkStatus)
                case .failure(let error):
                    NSLog("Get Device List Error: \(error.localizedDescription)")
                }
                callback?()
                
                DispatchQueue.main.async {
                    self.updateUI()
                }
            })
        }
       
    }
    
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.checkForUpdates(self)
        self.updateUI()
    }
    
    
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        self.xpcStore?.helperTool?.disconnect()
    }
    
    

    
    @objc private func handleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        
        DispatchQueue.main.async {
            self.statusItem?.menu?.cancelTrackingWithoutAnimation()

        }
        
        
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            if let url = URL(string: urlString), "omniedge" == url.scheme && "signin" == url.host {
                self.oauth2.handleRedirectURL(url)
                
            }
        }
        else {
            NSLog("No valid URL to handle")
        }
        
    }
    
    func callbackListening(turnOn: Bool){
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
            
            self.oauth2.handleRedirectURL(request.url)
            self.semaphore = DispatchSemaphore(value: 0)
            self.semaphore?.wait()
            
            if let _ = self.oauth2.idToken {
                let path = Bundle.main.path(forResource: "success.html", ofType: nil)!
                
                return GCDWebServerDataResponse(data: try! Data(contentsOf: URL(string: "file:///\(path)")!), contentType: "text")
               
            }else{
                
                return GCDWebServerErrorResponse(statusCode: 404)

            }
           
            
        })
        
        if turnOn && !webServer.isRunning {
            webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
        }
       
        if !turnOn && webServer.isRunning{
            webServer.stop()
        }
        
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Bugsnag.start()
        initDeviceInformation()
        oauth2.logger = OAuth2DebugLogger(.off)
        
        dataLoader = OmniEdgeDataLoader(oauth2: self.oauth2)
        
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
            
            callbackListening(turnOn: false)
            
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
                
                
                if let network: NetworkResponse = try? decoder.decode(NetworkResponse.self, from: networkStatus){
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
                
               
                
                
            }
            
            //dirty fix align
            
            if self.autoUpdate.state.toBool() {
                self.switcherAlign.constant = 24
                
            }else{
                self.switcherAlign.constant = 14
            }
            
        }else{
            callbackListening(turnOn: true)

            firstMenuItem.view = nil
            firstMenuItem.isHidden = true
            
            self.deviceList.isHidden = true
            
            loginItem.title = "Log In"
            
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(named: "StatusBarIcon")
        
        if let menu = menu {
            statusItem?.menu = menu
            menu.delegate = self
        }
        
        
        
    }
    
    
   
    
    func isTuntapInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: "/dev/tap0")
        
    }
    
    @IBAction func switchPressed(_ sender: OGSwitch) {
        
        
        
        
        if !isTuntapInstalled() {
            sender.setOn(isOn: false, animated: true)
            alert(title: "Tuntap not detected", description: "Tuntap is required to enable the network, please install it form  omniedge.dmg.", .critical)
            return
        }
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
        self.pullDevliceList()
        
    }
    
    
}

