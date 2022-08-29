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
    func didRegisteredDeviceFailed()
}

protocol IVirtualNetworkService {
    var failedRegisteDev: Bool { get }
    
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
    
    var failedRegisteDev: Bool {
        get {
            return self.registerDevFailed
        }
    }
    
    private var httpService: IHttpService
    private var xpcService: IXPCService
    private var deviceRegisterModel: DeviceRegisterModel?
    private var deviceJoinedModel: JoinDeviceMode?
    private var deviceModel: DeviceModel?
    private var lastConnectedVNId: String?
    private var networks: [VirtualNetworkModel] = []
    private var registerDevFailed: Bool = false
    
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
            [weak self] (result: Result<Response<[VirtualNetworkModel]>, OmError>) in
            switch result {
            case .success(let response):
                if(response.code == 200) {
                    self?.didLoadNetworkList(networks: response.data)
                } else {
                    self?.handleError(error: .errCode(response.code, response.message ?? String.Empty))
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
        
        self.terminateActiveTapConnection()
        print("Start connection");
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
            [weak self] (result: Result<Response<DeviceRegisterModel>, OmError>) in
            switch result {
            case .success(let response):
                self?.onDeviceRegister(model: response.data)
            case .failure(let error):
                self?.registerDevFailed = true
                self?.delegate?.didRegisteredDeviceFailed()
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
            [weak self] (result: Result< Response<JoinDeviceMode>, OmError>) in
            switch result {
            case .success(let response):
                self?.onDeviceJoined(model: response.data, virtualNetworkId: vnId)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    // MARK: - Private functions -
    private func didLoadNetworkList(networks: [VirtualNetworkModel]?) {
        guard let networks = networks else {
            return
        }

        self.networks.removeAll()
        self.networks.append(contentsOf: networks)
        self.delegate?.didNetworkListLoaded(networks: networks)
    }
    
    private func hasTuntapInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: "/dev/tap0")
    }
    
    private func onDeviceRegister(model: DeviceRegisterModel?) {
        guard let model = model else {
            return
        }
        registerDevFailed = false
        self.deviceRegisterModel = model
        self.delegate?.didRegisteredDevice(model: model)
    }
    
    private func onDeviceJoined(model: JoinDeviceMode?, virtualNetworkId: String) {
        guard let model = model else {
            return
        }

        self.lastConnectedVNId = virtualNetworkId
        let vnName = self.networks.first { item in
            item.vnId == virtualNetworkId
        }?.vnName
        self.deviceJoinedModel = model
        self.deviceJoinedModel?.setVnId(vnId: virtualNetworkId)
        self.deviceJoinedModel?.setVnName(vnName: vnName ?? String.Empty)

        
        self.delegate?.didJoinedDevice(model: self.deviceJoinedModel!)
    }
    
    private func terminateActiveTapConnection() {
        for _ in 0 ..< 6 {
            let output = runShellAndOutput("ifconfig | grep tap0 | head -c 4")
            if output?.starts(with: "tap") ?? false {
                print("Detected an active tap connection, terminate it");
                self.disconnectNetwork()
                sleep(1)
                //usleep(useconds_t(5 * 1000) * 100)
                print("after 1s delay, check it again");
            } else {
                print("No active connection found");
                break
            }
        }
    }
    
    @discardableResult
    // func runShellAndOutput(_ command: String) -> (Int32, String?) {
    private func runShellAndOutput(_ command: String) -> String? {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        task.waitUntilExit()
        
        return output
        // return (task.terminationStatus, output)
    }

    @discardableResult
    func runShellWithArgsAndOutput(_ args: String...) -> (Int32, String?) {
        let task = Process()

        task.launchPath = "/usr/bin/env"
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        task.waitUntilExit()
        
        return (task.terminationStatus, output)
    }
}
