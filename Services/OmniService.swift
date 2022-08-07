//
//  AppService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation
import AppKit

protocol OmniServiceDelegate: AnyObject {
    func didLoginSuccess()
    func didLoginFailed()
    func didLogout()
    func didNetworksLoaded(networks: [VirtualNetworkModel])
    func didDeviceRegister(model: DeviceRegisterModel)
}

protocol IOmniService: IService {
    var delegate: OmniServiceDelegate? { get set }
    var networkService: IVirtualNetworkService { get }
    var hasLoggedIn: Bool { get }
    
    func login()
    func logout()
    func getCachedNetworkConfig() -> Data?
    
    func terminate()
}

class OmniService: IOmniService {
    
    var hasLoggedIn: Bool {
        get {
            return self.token != nil
        }
    }
    
    weak var delegate: OmniServiceDelegate?
    
    var networkService: IVirtualNetworkService {
        get {
            guard let virtualNetworkService = self.curVirtualNetworkService else {
                let networkService: IVirtualNetworkService = self.locatorService.resolve()
                self.curVirtualNetworkService = networkService
                self.curVirtualNetworkService?.delegate = self
                return networkService
            }
            
            return virtualNetworkService
        }
    }
    
    private var httpService: IHttpService {
        get {
            
            guard let httpService = self.curHttpService else {
                let httpService: IHttpService = self.locatorService.resolve()
                self.curHttpService = httpService
                return httpService
            }
            
            return httpService
        }
    }
    
    private var authService: IAuthService {
        get {
            guard let authService = self.curAuthService else {
                let authService: IAuthService = self.locatorService.resolve()
                self.curAuthService = authService
                self.curAuthService?.delegate = self
                return authService
            }
            
            return authService
        }
    }
    
    private var locatorService: ILocatorService
    private var curHttpService: IHttpService?
    private var curAuthService: IAuthService?
    private var curVirtualNetworkService: IVirtualNetworkService?
    
    private var token: String?
    
    init(locatorService: ILocatorService) {
        self.locatorService = locatorService
    }
    
    func initService() {
        let xpcService: IXPCService = self.locatorService.resolve()
        let authService = AuthService(httpService: self.httpService)
        let networkService = VirtualNetworkService(httpService: self.httpService, xpcService: xpcService)
        
        self.locatorService.register(instance: authService as IAuthService)
        self.locatorService.register(instance: networkService as IVirtualNetworkService)
        
        xpcService.installAndConnectHeperTool()
    }
    
    func login() {
        self.authService.login()
    }
    
    func logout() {
        self.token = nil
        self.delegate?.didLogout()
        DispatchQueue.main.async {
            (NSApplication.shared.delegate as? AppDelegate)?.didLogin(login: false)
        }
    }
    
    func joinLocalDevice(vnId: String) {
        self.networkService.joinDeviceInNetwork(vnId: vnId)
    }
    
    func getCachedNetworkConfig() -> Data? {
        let cacheService: ICacheService = self.locatorService.resolve()
        let networkConfigData = cacheService.getValue(forKey: UserDefaultKeys.NetworkConfig)
        return networkConfigData as? Data
    }
    
    func terminate() {
        let xpcService: IXPCService = self.locatorService.resolve()
        xpcService.disconnect()
    }
    
    // MARK: - Private functions -
    private func getRemoteNetworkList() {
        self.networkService.loadNetworks()
    }
    
    private func registerLocalDevice() {
        self.networkService.registerDevice()
    }
}

extension OmniService: AuthServiceDelegate {
    func didLoginCompleted(token: String?) {
        self.curHttpService?.token = token
        self.token = token
        var loggedIn = false
        
        if token == nil {
            self.delegate?.didLoginFailed()
        } else {
            self.delegate?.didLoginSuccess()
            self.registerLocalDevice()
            self.getRemoteNetworkList()
            loggedIn = true
        }

        DispatchQueue.main.async {
            (NSApplication.shared.delegate as? AppDelegate)?.didLogin(login: loggedIn)
        }
    }
}

extension OmniService: VirtualNetworkServiceDelegate {
    func didNetworkListLoaded(networks: [VirtualNetworkModel]) {
        self.delegate?.didNetworksLoaded(networks: networks)
    }
    
    func didJoinedDevice(data: Data) {
        // save it
        let cacheService: ICacheService = self.locatorService.resolve()
        cacheService.saveValue(value: data, key: UserDefaultKeys.NetworkConfig)
    
        self.networkService.connectNetwork(dataOfNetworkConfig: data) { success in
            if !success {
                Utils.alert(title: "Tuntap not detected", description: "Tuntap is required to enable the network, please install it according the instruction: https://omniedge.io/docs/article/install/macos.", .critical)
            }
        }
    }
    
    func didRegisteredDevice(model: DeviceRegisterModel) {
        self.delegate?.didDeviceRegister(model: model)
    }
}
