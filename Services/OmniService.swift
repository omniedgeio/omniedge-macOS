//
//  AppService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 15/7/2022.
//

import Foundation

protocol OmniServiceDelegate: AnyObject {
    func didLoginSuccess()
    func didLoginFailed()
    func didLogout()
    
    func didNetworksLoaded(networks: [VirtualNetworkModel])
    func didDeviceRegister(model: DeviceRegisterModel)
}

protocol IOmniService: IService {
    var delegate: OmniServiceDelegate? { get set }
    var hasLoggedIn: Bool { get }
    
    func login()
    func logout()
    
    func terminate()
}

class OmniService: IOmniService {
    
    var hasLoggedIn: Bool {
        get {
            return self.token != nil
        }
    }
    
    weak var delegate: OmniServiceDelegate?
    
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
    
    private var networkService: IVirtualNetworkService {
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
    
    private var deviceService: IDeviceService {
        get {
            guard let deviceService = self.curDeviceService else {
                let deviceService:IDeviceService = self.locatorService.resolve()
                self.curDeviceService = deviceService
                self.curDeviceService?.delegate = self
                return deviceService
            }
            
            return deviceService
        }
    }
    
    private var locatorService: ILocatorService
    private var curHttpService: IHttpService?
    private var curAuthService: IAuthService?
    private var curVirtualNetworkService: IVirtualNetworkService?
    private var curDeviceService: IDeviceService?
    
    private var token: String?
    
    init(locatorService: ILocatorService) {
        self.locatorService = locatorService
    }
    
    func initService() {
        
        let authService = AuthService(httpService: self.httpService)
        let networkService = VirtualNetworkService(httpService: self.httpService)
        let deviceService = DeviceService(httpService: self.httpService)
        self.locatorService.register(instance: authService as IAuthService)
        self.locatorService.register(instance: networkService as IVirtualNetworkService)
        self.locatorService.register(instance: deviceService as IDeviceService)
        
        let xpcService: IXPCService = self.locatorService.resolve()
        xpcService.installAndConnectHeperTool()
    }
    
    func login() {
        self.authService.login()
    }
    
    func logout() {
        self.token = nil
        self.delegate?.didLogout()
    }
    
    func joinLocalDevice(networkUuid: String) {
        self.deviceService.joinDeviceInNetwork(networkUuid: networkUuid)
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
        self.deviceService.registerDevice()
    }
}

extension OmniService: AuthServiceDelegate {
    func didLoginCompleted(token: String?) {
        self.curHttpService?.token = token
        
        self.token = token
        if token == nil {
            self.delegate?.didLoginFailed()
            return
        }

        self.delegate?.didLoginSuccess()
        self.registerLocalDevice()
        self.getRemoteNetworkList()
    }
}

extension OmniService: VirtualNetworkServiceDelegate {
    func didNetworkListLoaded(networks: [VirtualNetworkModel]) {
        self.delegate?.didNetworksLoaded(networks: networks)
    }
}

extension OmniService: DeviceServiceDelegate {
    func didRegisteredDevice(model: DeviceRegisterModel) {
        self.delegate?.didDeviceRegister(model: model)
    }
    
    func didJoinedDevice() {
        
    }
}
