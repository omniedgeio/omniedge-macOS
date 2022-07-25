//
//  VirtualNetworkService.swift
//  Omniedge
//
//  Created by Yanbo Dang on 16/7/2022.
//

import Foundation

protocol VirtualNetworkServiceDelegate: AnyObject {
    func didNetworkListLoaded(networks: [VirtualNetworkModel])
    func didRegisteredDevice(model: DeviceRegisterModel)
    func didJoinedDevice(data: Data)
}

protocol IVirtualNetworkService {
    var delegate: VirtualNetworkServiceDelegate? { get set }
    func loadNetworks()
    func connectNetwork(dataOfNetworkConfig: Data, completed: @escaping (_ successed: Bool) -> Void)
    func disconnectNetwork()
    func registerDevice()
    func joinDeviceInNetwork(vnId: String)
}

class VirtualNetworkService: BaseService, IVirtualNetworkService {
    
    weak var delegate: VirtualNetworkServiceDelegate?
    
    private var httpService: IHttpService
    private var xpcService: IXPCService
    private var deviceRegisterModel: DeviceRegisterModel?
    private var deviceJoinedModel: JoinDeviceMode?
    private var deviceModel: DeviceModel?
    
    init(httpService: IHttpService, xpcService: IXPCService) {
        self.httpService = httpService
        self.xpcService = xpcService
        super.init()
    }
    
    override func initService() {
        self.deviceModel = Utils.getDeviceInfo()
    }
    
    func loadNetworks() {
        
        self.httpService.sendGetRequest(url: ApiEndPoint.virtualNetworkList, completed: {
            [weak self] (result: Result<Response<[VirtualNetworkModel]>, Error>) in
            switch result {
            case .success(let response):
                if(response.code == 200) {
                    self?.didLoadNetworkList(networks: response.data)
                } else {
                    self?.handleError(error: OmniError(errorCode: response.code, message: nil))
                }
            case .failure(let error):
                self?.handleError(error: error)
            }
        })
    }
    
    func connectNetwork(dataOfNetworkConfig: Data, completed: @escaping (_ successed: Bool) -> Void) {
        // check if the tuntapInstalled
        if !self.hasTuntapInstalled() {
            completed(false)
            return
        }
        
        self.xpcService.connect(dataOfNetworkConfig: dataOfNetworkConfig)
    }
    
    func disconnectNetwork() {
        self.xpcService.disconnect()
    }
    
    func registerDevice() {
        self.httpService.sendPostRequest(url: ApiEndPoint.registerDevice, payload: self.deviceModel) {
            [weak self] (result: Result<Response<DeviceRegisterModel>, Error>) in
            switch result {
            case .success(let response):
                self?.onDeviceRegister(model: response.data)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    func joinDeviceInNetwork(vnId: String) {
        guard let deviceId = self.deviceRegisterModel?.deviceId else {
            return
        }
        let payload: [String: String] = ["deviceId" : deviceId]
        let joinUrl = "\(ApiEndPoint.virtualNetworkList)\(vnId)/devices/\(deviceId)/join";
        self.httpService.sendPostRequest(url: joinUrl, payload: payload) {
            [weak self] (result: Result< Response<JoinDeviceMode>, Error>) in
            switch result {
            case .success(let response):
                self?.onDeviceJoined(model: response.data)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    // MARK: - Private functions -
    private func didLoadNetworkList(networks: [VirtualNetworkModel]) {
        self.delegate?.didNetworkListLoaded(networks: networks)
    }
    
    private func hasTuntapInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: "/dev/tap0")
    }
    
    private func onDeviceRegister(model: DeviceRegisterModel) {
        self.deviceRegisterModel = model
        self.delegate?.didRegisteredDevice(model: model)
    }
    
    private func onDeviceJoined(model: JoinDeviceMode) {
        self.deviceJoinedModel = model
        do {
            let data = try JSONEncoder().encode(model)
            self.delegate?.didJoinedDevice(data: data)
        } catch let error {
            self.handleError(error: error)
        }
    }
}
