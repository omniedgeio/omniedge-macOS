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

@available(macOS 10.15, *)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var switcherAlign: NSLayoutConstraint!
    
    @IBOutlet weak var loginItem: NSMenuItem!
    
    @IBOutlet weak var updater: SUUpdater!
    
    @IBOutlet weak var autoUpdate: NSMenuItem!
    
    @IBOutlet weak var menuItemVirtualNetwork: NSMenuItem!
    var xpcStore: XPCStore?
    
    let webServer = GCDWebServer()
    
    @IBOutlet weak var customeView: NSView!
    
    var statusItem: NSStatusItem?
    
    @IBOutlet weak var networkSwitcher: OGSwitch!
    
    @IBOutlet weak var switchLabel: NSTextField!
    
    @IBAction func dashboard(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://omniedge.io/dashboard")!)
    }
    
    @IBAction func talktous(_ sender: NSMenuItem) {
        let service=NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients=["support@omniedge.io"]
        service.subject="OmniEdge macOS Support"
        service.perform(withItems: [""])
    }
    
    @IBAction func pressAutoUpdate(_ sender: NSMenuItem) {

        UserDefaults.standard.set(sender.state.toggle(), forKey: UserDefaultKeys.AutoUpdate)
        self.updateUI()
        
    }
    
    var semaphore: DispatchSemaphore?
    
    //var oauth2 = createOAuth2()
    
    private var oauth2: OAuth2CodeGrant?
    private var webSocketSessionTask: URLSessionWebSocketTask?
    private var jwtToken: String?
    private var virtalNetworkList: [VirtualNetworkModel] = []
    private var virtualNetworkContainerMenu: NSMenu?
    private var deviceRegisterModel: DeviceRegisterModel?
    private var virtualNetworkMenuItems: [NSMenuItem] = []
    
    private static func createOAuth2(authUrl: String) -> OAuth2CodeGrant{
        return OAuth2CodeGrant(settings: [
            "client_id": BackEndConstants.ClientID,
            "client_secret": BackEndConstants.ClientSecret,
            "authorize_uri":authUrl, // BackEndConstants.LoginURL ,
            "token_uri": BackEndConstants.TokenURL,
            "redirect_uris": [BackEndConstants.CallBackURL],
            "scope": BackEndConstants.Scope,
            "keychain": true,
        ] as OAuth2JSON)
    }
    
    var dataLoader: OmniEdgeDataLoader?
    var dataLoader1: OmniEdgeDataLoader1 = OmniEdgeDataLoader1()
    
    @IBAction func logInOutItem(_ sender: NSMenuItem) {
        
        if self.loginItem.title == "Log Out" {
            self.isLoggedIn(false)
            return
        }
        
        self.getAuthSessionCode { authUrl in
            
            guard let url = URL(string: authUrl) else {
                return
            }
            
            NSWorkspace.shared.open(url)
            
//            self.oauth2 = AppDelegate.createOAuth2(authUrl: authUrl)
//            guard let oauth2 = self.oauth2 else {
//                return
//            }
//
//            oauth2.logger = OAuth2DebugLogger(.off)
//            self.dataLoader = OmniEdgeDataLoader(oauth2: oauth2)
//            if let _ = oauth2.idToken{
//
//                oauth2.forgetTokens()
//                let storage = HTTPCookieStorage.shared
//                storage.cookies?.forEach() { storage.deleteCookie($0) }
//                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.NetworkStatus)
//                UserDefaults.standard.removeObject(forKey: UserDefaultKeys.NetworkConfig)
//
//                self.xpcStore?.helperTool?.disconnect()
//
//            }else{
//
//                var url = try! oauth2.authorizeURL(params: nil)
//                url = URL(string: url.description.removingPercentEncoding!)!
//                //            try! oauth2.authorizer.authorizeEmbedded(with: oauth2.authConfig, at: url)
//                try! oauth2.authorizer.openAuthorizeURLInBrowser(url)
//
//
//                oauth2.afterAuthorizeOrFail = { authParameters, error in
//
//
//                    if let error = error {
//                        alert(title: "Login failed.", description: error.localizedDescription, .critical)
//                    }
//
//                    self.semaphore?.signal()
//                    self.pullDevliceList(callback: self.join)
//                }
//            }
            
            self.updateUI()
        }
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
    
    func pullDevliceList(callback: (()->Void)? = nil) {
        
        guard let jwtToken = jwtToken else {
            return
        }
        
        self.queryNetworkList {
            self.populateVirtalNetworkMenuItems()
        }

//        if let _ = oauth2?.accessToken {
//            self.dataLoader?.queryNetwork(callback: { result in
//
//                switch result{
//                case .success(let network):
//                    UserDefaults.standard.setValue(network, forKey: UserDefaultKeys.NetworkStatus)
//                case .failure(let error):
//                    NSLog("Get Device List Error: \(error.localizedDescription)")
//                }
//                callback?()
//
//                DispatchQueue.main.async {
//                    self.updateUI()
//                }
//            })
//        }
       
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
                self.oauth2?.handleRedirectURL(url)
                
            }
        }
        else {
            NSLog("No valid URL to handle")
        }
        
    }
    
    func callbackListening(turnOn: Bool){
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
            
            self.oauth2?.handleRedirectURL(request.url)
            self.semaphore = DispatchSemaphore(value: 0)
            self.semaphore?.wait()
            
            if let _ = self.oauth2?.idToken {
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
        
        isLoggedIn(self.oauth2?.accessToken != nil)
        
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
            loginItem.title = "Log Out"
        
            
            let submenu = NSMenu()
            var ip: String?
            if let networkConfig = UserDefaults.standard.data(forKey: UserDefaultKeys.NetworkConfig){
                
                guard let localHost  = try? JSONDecoder().decode(JoinDeviceMode.self, from: networkConfig) else {
                    return
                }
                
                DispatchQueue.main.async {
                    let deviceInfoView = DeviceInfoView()
                    deviceInfoView.deviceName.wantsLayer = true
                    deviceInfoView.deviceName.stringValue =  ProcessInfo.processInfo.hostName
                    deviceInfoView.ip.stringValue = localHost.virtualIp
                    
                    ip = localHost.virtualIp
                    deviceInfoView.updateUI()
                    let menuItem = NSMenuItem()
                    menuItem.view = deviceInfoView
                    submenu.addItem(menuItem)
                    submenu.addItem(NSMenuItem.separator())
                }
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
                }
            }
            
            //dirty fix align
            
            if self.autoUpdate.state.toBool() {
                self.switcherAlign.constant = 24
                
            }else{
                self.switcherAlign.constant = 14
            }
            
            self.registerDevice()
            
        }else{
            callbackListening(turnOn: true)
            loginItem.title = "Log In"
            self.virtalNetworkList.removeAll()
            self.virtualNetworkMenuItems.forEach { menuItem in
                self.menu.removeItem(menuItem)
            }
            self.virtualNetworkMenuItems.removeAll()
        }
    }
    
    private func registerDevice() {
        guard let model = self.getDeviceInfo(),
        let token = self.jwtToken else {
            return
        }
        
        self.dataLoader1.registerDevice(token: token, deviceInfo: model) { result in
            switch result {
            case .success(let deviceRegisterModel):
                self.deviceRegisterModel = deviceRegisterModel
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getDeviceInfo() -> DeviceModel? {
        let deviceName = ProcessInfo.processInfo.hostName
        // let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        guard let hardwareUUID = self.getHardwareUUID() else {
            return nil
        }
        
        return DeviceModel(deviceName: deviceName, deviceUuid: hardwareUUID, deviceOS: "macOS")
    }
    
    private func getHardwareUUID() -> String? {
        let dev = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, dev)
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0)
        IOObjectRelease(platformExpert)
        let ser: CFTypeRef? = serialNumberAsCFString?.takeUnretainedValue()
        
        guard let result = ser as? String else {
            return nil
        }
        
        return result
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
        let existed = FileManager.default.fileExists(atPath: "/dev/tap0")
        return FileManager.default.fileExists(atPath: "/dev/tap0")
    }
    
    func menuWillOpen(_ menu: NSMenu){
        // self.pullDevliceList()
    }
    
    private func getAuthSessionCode(completed: @escaping (String) -> Void ) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        guard let url = URL(string: ApiEndPoint.baseApi + ApiEndPoint.authSession) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) {[weak self] (data, response, error) in
            guard let jsonData = data else {
                return
            }
            
            do {
                let decoder1 = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder1.dateDecodingStrategy = .formatted(dateFormatter)
                
                let restReponse = try decoder1.decode(RestResponse<AuthSession>.self, from: jsonData)
                self?.monitorSessionCodeWSEvent(sessionCode: restReponse.data.sessionId) { msgData in
                    
                    guard let data = msgData,
                          let obj = try? JSONDecoder().decode(Dictionary<String, String>.self, from: data) else {
                        return
                    }
                    
                    self?.jwtToken = obj["token"]
                    self?.pullDevliceList()
                    self?.isLoggedIn(true)
                }
                
                completed(restReponse.data.authUrl)
            } catch let error {
                print("error:\(error)")
            }
            
            return
        }
        
        task.resume()
    }

    private func monitorSessionCodeWSEvent(sessionCode: String, receiverHandler: @escaping (Data?) -> Void) {
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        self.webSocketSessionTask = urlSession.webSocketTask(with: URL(string: "ws://18.191.169.4:8081/login/session/\(sessionCode)")!)
        self.webSocketSessionTask?.resume()
                
        self.webSocketSessionTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                    case .string(let text):
                        print("Received string: \(text)")
                    receiverHandler(text.data(using: .utf8))
                    case .data(let data):
                        print("Received data: \(data)")
                        receiverHandler(data)
                    @unknown default:
                        fatalError()
                }
            case .failure(let error):
                print(error)
            }
        }
        
        let request: [String:String] = ["type":"auth:session"]
        guard let jsonData = try? JSONEncoder().encode(request),
              let jsonText = String(data: jsonData, encoding: .utf8)
              else {
            return
        }
        
        self.webSocketSessionTask?.send(.string(jsonText)) { error in
            if error != nil {
                print(error!)
                return
            }
            
            print("successfully sent: \(jsonText)")
        }
    }
        
    private func populateVirtalNetworkMenuItems() {
        if self.virtualNetworkContainerMenu != nil {
            return
        }
        
        DispatchQueue.main.async {
            let vnMenuItemIndex = self.menu.index(of: self.menuItemVirtualNetwork)
            var index = 1
            self.virtalNetworkList.forEach { vnItem in
                let menuItem = NSMenuItem(title: vnItem.vnName, action: nil, keyEquivalent: "")
                self.menu.insertItem(menuItem, at: vnMenuItemIndex + index)
                index += 1
                
                let detailMenu = NSMenu()
                let detailMenuItem = NSMenuItem(title: vnItem.vnName, action: nil, keyEquivalent: "")
                let contentView = VirtualNetworkItemView(model: vnItem)
                contentView.delegate = self
                detailMenuItem.view = contentView
                detailMenu.addItem(detailMenuItem)
                
                menuItem.submenu = detailMenu
                
                self.virtualNetworkMenuItems.append(menuItem)
            }
        }
    }
    
    private func queryNetworkList(callback: (() -> Void)?) {
        
        self.virtalNetworkList.removeAll()
        
        guard let jwtToken = jwtToken else {
            return
        }
        
        self.dataLoader1.queryNetwork(token: jwtToken, callback: { result in
            switch result {
            case .success(let networkers):
                self.virtalNetworkList = networkers
                if callback != nil {
                    callback!()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    private func connectVirtualNetwork(on: Bool, switchCtrl: OGSwitch) -> Bool {

        if(on && !self.isTuntapInstalled()){
            switchCtrl.setOn(isOn: false, animated: true)
            alert(title: "Tuntap not detected", description: "Tuntap is required to enable the network, please install it form  omniedge.dmg.", .critical)
            return false
        }
        
        if(on){
            
            guard let networkConfig = UserDefaults.standard.data(forKey: UserDefaultKeys.NetworkConfig) else {
                return false
            }
            self.xpcStore?.helperTool?.connect(networkConfig){ err in
                if err != nil {
                    print(err!)
                }
            }
        } else {
            self.xpcStore?.helperTool?.disconnect()
        }
        
        return true
    }
    
}

@available(macOS 10.15, *)
extension AppDelegate: VirtualNetworItemViewDelegate {
    
    internal func didToggled(on: Bool, model: VirtualNetworkModel, contentView: VirtualNetworkItemView) {
        if(!on){
            _ = self.connectVirtualNetwork(on: on, switchCtrl: contentView.switcher)
            return
        }
        
        guard let token = self.jwtToken,
              let deviceId = self.deviceRegisterModel?.deviceId else {
            return
        }
        
        let virtualNetworkId = model.vnId
        self.dataLoader1.joinDevice(token: token, deviceId: deviceId, networkUuid: model.vnId) { result in
            
            switch result {
            case .success(let joinDeviceRsp):
                let networkconfigData = try? JSONEncoder().encode(joinDeviceRsp)
                UserDefaults.standard.setValue(networkconfigData, forKey: UserDefaultKeys.NetworkConfig)
                UserDefaults.standard.synchronize()
                _ = self.connectVirtualNetwork(on: true, switchCtrl: contentView.switcher)
                self.queryNetworkList{
                    guard let virtualNetworkModel = self.virtalNetworkList.first(where: {$0.vnId == virtualNetworkId}) else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        contentView.updateModel(model: virtualNetworkModel)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

