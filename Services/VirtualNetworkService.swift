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
    func didJoinedDevice(model: JoinDeviceMode)
}

protocol IVirtualNetworkService {
    var delegate: VirtualNetworkServiceDelegate? { get set }
    var curConnectedNetworkId: String? { get }
    func loadNetworks()
    func connectNetwork(dataOfNetworkConfig: Data, completed: @escaping (_ successed: Bool) -> Void)
    func disconnectNetwork()
    func registerDevice()
    func joinDeviceInNetwork(vnId: String)
}

class VirtualNetworkService: BaseService, IVirtualNetworkService {
    
    weak var delegate: VirtualNetworkServiceDelegate?
    
    var curConnectedNetworkId: String? {
        get {
            return self.lastConnectedVNId
        }
    }
    
    private var httpService: IHttpService
    private var xpcService: IXPCService
    private var deviceRegisterModel: DeviceRegisterModel?
    private var deviceJoinedModel: JoinDeviceMode?
    private var deviceModel: DeviceModel?
    private var lastConnectedVNId: String?
    private var networks: [VirtualNetworkModel] = []
    
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
        
        self.xpcService.connect(dataOfNetworkConfig: dataOfNetworkConfig) { (success, error) in
            completed(success)
            guard let error = error else {
                return
            }
            print(error)
        }
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
        if self.lastConnectedVNId != nil && self.lastConnectedVNId! != vnId {
            self.disconnectNetwork()
        }
        
        guard let deviceId = self.deviceRegisterModel?.deviceId else {
            return
        }
        let payload: [String: String] = ["deviceId" : deviceId]
        let joinUrl = "\(ApiEndPoint.virtualNetworkList)\(vnId)/devices/\(deviceId)/join";
        self.httpService.sendPostRequest(url: joinUrl, payload: payload) {
            [weak self] (result: Result< Response<JoinDeviceMode>, Error>) in
            switch result {
            case .success(let response):
                self?.onDeviceJoined(model: response.data, virtualNetworkId: vnId)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    // MARK: - Private functions -
    private func didLoadNetworkList(networks: [VirtualNetworkModel]) {
        self.networks.removeAll()
        self.networks.append(contentsOf: networks)
        self.delegate?.didNetworkListLoaded(networks: networks)
    }
    
    private func hasTuntapInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: "/dev/tap0")
    }
    
    private func onDeviceRegister(model: DeviceRegisterModel) {
        self.deviceRegisterModel = model
        self.delegate?.didRegisteredDevice(model: model)
    }
    
    private func onDeviceJoined(model: JoinDeviceMode, virtualNetworkId: String) {
        self.lastConnectedVNId = virtualNetworkId
        let vnName = self.networks.first { item in
            item.vnId == virtualNetworkId
        }?.vnName
        self.deviceJoinedModel = model
        self.deviceJoinedModel?.setVnId(vnId: virtualNetworkId)
        self.deviceJoinedModel?.setVnName(vnName: vnName ?? String.Empty)

        
        self.delegate?.didJoinedDevice(model: self.deviceJoinedModel!)
    }
}
